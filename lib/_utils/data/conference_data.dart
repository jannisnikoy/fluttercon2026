import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'models.dart';

/// Local Sessionize dump scraped from
/// https://www.flutterconusa.dev/fluttercon-agenda
/// (API: sessionize.com/api/v2/qed220fq).
abstract final class ConferenceData {
  static const venueName = 'FlutterCon USA';
  static const venueLocation = 'Orlando, FL';
  static const venueAddress = 'OCCC West Concourse, Orlando, Florida';
  static const agendaSourceUrl = 'https://www.flutterconusa.dev/fluttercon-agenda';

  static List<ConferenceDay> days = const [];
  static List<Speaker> speakers = const [];
  static List<Session> sessions = const [];
  static List<String> trackFilters = const ['All Tracks'];
  static List<String> speakerFilters = const ['All'];

  static final Map<String, Speaker> _speakersById = {};
  static final Map<String, Session> _sessionsById = {};

  static bool get isLoaded => sessions.isNotEmpty || speakers.isNotEmpty;

  static Future<void> load() async {
    if (isLoaded) return;

    final sessionsRaw = jsonDecode(await rootBundle.loadString('assets/data/sessions.json')) as List<dynamic>;
    final speakersRaw = jsonDecode(await rootBundle.loadString('assets/data/speakers.json')) as List<dynamic>;

    final parsedSpeakers = speakersRaw.cast<Map<String, dynamic>>().map(_parseSpeaker).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final parsedSessions = <Session>[];
    final dayDates = <DateTime>{};
    final trackNames = <String>{};

    for (final dayJson in sessionsRaw.cast<Map<String, dynamic>>()) {
      final dayDate = DateTime.parse(dayJson['date'] as String);
      dayDates.add(DateTime(dayDate.year, dayDate.month, dayDate.day));

      for (final roomJson in (dayJson['rooms'] as List<dynamic>).cast<Map<String, dynamic>>()) {
        for (final sessionJson in (roomJson['sessions'] as List<dynamic>).cast<Map<String, dynamic>>()) {
          final session = _parseSession(sessionJson);
          parsedSessions.add(session);
          if (session.track != null && session.track!.isNotEmpty) {
            trackNames.add(session.track!);
          }
        }
      }
    }

    parsedSessions.sort((a, b) => a.start.compareTo(b.start));
    _attachRelatedSessions(parsedSessions);

    days = (dayDates.toList()..sort()).map(_toConferenceDay).toList();

    speakers = parsedSpeakers;
    sessions = parsedSessions;

    _speakersById
      ..clear()
      ..addEntries(speakers.map((s) => MapEntry(s.id, s)));
    _sessionsById
      ..clear()
      ..addEntries(sessions.map((s) => MapEntry(s.id, s)));

    speakers = [
      for (final speaker in speakers)
        Speaker(
          id: speaker.id,
          name: speaker.name,
          title: speaker.title,
          company: speaker.company,
          imageUrl: speaker.imageUrl,
          bio: speaker.bio,
          tags: {
            ...speaker.tags,
            for (final sessionId in speaker.sessionIds)
              if (_sessionsById[sessionId]?.track != null) displayTrackLabel(_sessionsById[sessionId]!.track!),
            for (final sessionId in speaker.sessionIds)
              if (_sessionsById[sessionId]?.typeLabel == 'Keynote') 'Keynote',
          }.toList(),
          tagLine: speaker.tagLine,
          twitterUrl: speaker.twitterUrl,
          linkedinUrl: speaker.linkedinUrl,
          websiteUrl: speaker.websiteUrl,
          sessionIds: speaker.sessionIds,
        ),
    ];
    _speakersById
      ..clear()
      ..addEntries(speakers.map((s) => MapEntry(s.id, s)));

    final orderedTracks = trackNames.toList()..sort((a, b) => displayTrackLabel(a).compareTo(displayTrackLabel(b)));
    trackFilters = ['All Tracks', ...orderedTracks.map(displayTrackLabel)];

    speakerFilters = ['All', ...orderedTracks.map(displayTrackLabel)];
  }

  static ConferenceDay _toConferenceDay(DateTime date) {
    return ConferenceDay(
      date: date,
      weekdayShort: DateFormat('E').format(date),
      dateLabel: DateFormat('MMM d').format(date),
    );
  }

  static Speaker speakerById(String id) {
    final speaker = _speakersById[id];
    if (speaker != null) return speaker;
    return Speaker(id: id, name: 'Unknown Speaker', title: '', company: '', imageUrl: '', bio: '', tags: const []);
  }

  static Speaker? maybeSpeaker(String id) => _speakersById[id];

  static Session sessionById(String id) {
    final session = _sessionsById[id];
    if (session != null) return session;
    throw StateError('Unknown session: $id');
  }

  static Session? maybeSession(String id) => _sessionsById[id];

  static List<Session> sessionsForDay(DateTime day) {
    return sessions.where((s) => s.day.year == day.year && s.day.month == day.month && s.day.day == day.day).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  static List<Session> sessionsForSpeaker(String speakerId) {
    final byId = {
      for (final id in (maybeSpeaker(speakerId)?.sessionIds ?? const []))
        if (_sessionsById.containsKey(id)) id: _sessionsById[id]!,
    };
    for (final session in sessions) {
      if (!session.isBreak && session.speakerIds.contains(speakerId)) {
        byId[session.id] = session;
      }
    }
    return byId.values.toList()..sort((a, b) => a.start.compareTo(b.start));
  }

  static List<Speaker> coSpeakers(String speakerId) {
    final ids = <String>{};
    for (final session in sessionsForSpeaker(speakerId)) {
      for (final id in session.speakerIds) {
        if (id != speakerId) ids.add(id);
      }
    }
    return ids.map(speakerById).where((s) => s.name != 'Unknown Speaker').toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  static bool matchesTrackFilter(Session session, String filter) {
    if (filter == 'All Tracks' || filter == 'All') return true;
    final track = session.track;
    if (track == null) return session.isBreak;
    return displayTrackLabel(track) == filter;
  }

  static bool speakerMatchesFilter(Speaker speaker, String filter) {
    if (filter == 'All') return true;
    for (final sessionId in speaker.sessionIds) {
      final session = _sessionsById[sessionId];
      if (session != null && matchesTrackFilter(session, filter)) {
        return true;
      }
    }
    return speaker.tags.any((t) => displayTrackLabel(t) == filter || t == filter);
  }

  static Speaker _parseSpeaker(Map<String, dynamic> json) {
    final answers = (json['questionAnswers'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
    String? answerFor(String question) {
      for (final qa in answers) {
        if ((qa['question'] as String?) == question) {
          final answer = qa['answer'] as String?;
          if (answer != null && answer.trim().isNotEmpty) return answer.trim();
        }
      }
      return null;
    }

    final links = (json['links'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
    String? linkOf(String type) {
      for (final link in links) {
        if ((link['linkType'] as String?) == type) {
          return link['url'] as String?;
        }
      }
      return null;
    }

    final tagLine = (json['tagLine'] as String?)?.trim() ?? '';
    var title = answerFor('Job Title') ?? '';
    var company = answerFor('Company Name') ?? '';
    if ((title.isEmpty || company.isEmpty) && tagLine.contains(',')) {
      final parts = tagLine.split(',');
      if (title.isEmpty) title = parts.first.trim();
      if (company.isEmpty && parts.length > 1) {
        company = parts.sublist(1).join(',').trim();
      }
    }

    final sessionIds = (json['sessions'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map((s) => '${s['id']}')
        .toList();

    final tags = <String>[if (json['isTopSpeaker'] == true) 'Keynote'];

    return Speaker(
      id: json['id'] as String,
      name: (json['fullName'] as String?)?.trim().isNotEmpty == true
          ? json['fullName'] as String
          : '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      title: title,
      company: company,
      imageUrl: (json['profilePicture'] as String?) ?? '',
      bio: (json['bio'] as String?)?.trim() ?? '',
      tags: tags,
      tagLine: tagLine,
      twitterUrl: linkOf('Twitter'),
      linkedinUrl: linkOf('LinkedIn'),
      websiteUrl: linkOf('Blog') ?? linkOf('Company_Website'),
      sessionIds: sessionIds,
    );
  }

  static Session _parseSession(Map<String, dynamic> json) {
    final start = DateTime.parse(json['startsAt'] as String);
    final end = DateTime.parse(json['endsAt'] as String);
    final isService = json['isServiceSession'] == true;
    final categories = (json['categories'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

    String? categoryItem(String categoryName) {
      for (final category in categories) {
        if (category['name'] == categoryName) {
          final items = (category['categoryItems'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
          if (items.isNotEmpty) return items.first['name'] as String?;
        }
      }
      return null;
    }

    List<String> categoryItems(String categoryName) {
      for (final category in categories) {
        if (category['name'] == categoryName) {
          return (category['categoryItems'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>()
              .map((i) => i['name'] as String)
              .toList();
        }
      }
      return const [];
    }

    final track = categoryItem('Track Selection');
    final format = categoryItem('Session format');
    final tags = categoryItems('Tags');
    final room = (json['room'] as String?) ?? '';
    final speakerIds = (json['speakers'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map((s) => s['id'] as String)
        .toList();

    return Session(
      id: '${json['id']}',
      title: json['title'] as String,
      track: track,
      room: room,
      day: DateTime(start.year, start.month, start.day),
      start: start,
      end: end,
      speakerIds: speakerIds,
      description: (json['description'] as String?)?.trim() ?? '',
      accentColor: accentForTrack(track).toARGB32(),
      isBreak: isService,
      breakLocation: isService ? room : null,
      typeLabel: format,
      tags: tags,
    );
  }

  static void _attachRelatedSessions(List<Session> all) {
    for (var i = 0; i < all.length; i++) {
      final session = all[i];
      if (session.isBreak) continue;

      final related = all
          .where(
            (other) => other.id != session.id && !other.isBreak && other.track != null && other.track == session.track,
          )
          .take(2)
          .map((s) => s.id)
          .toList();

      all[i] = Session(
        id: session.id,
        title: session.title,
        track: session.track,
        room: session.room,
        day: session.day,
        start: session.start,
        end: session.end,
        speakerIds: session.speakerIds,
        description: session.description,
        accentColor: session.accentColor,
        isBreak: session.isBreak,
        breakLocation: session.breakLocation,
        headerImageUrl: session.headerImageUrl,
        capacityFilled: session.capacityFilled,
        capacityTotal: session.capacityTotal,
        typeLabel: session.typeLabel,
        tags: session.tags,
        relatedSessionIds: related,
      );
    }
  }
}
