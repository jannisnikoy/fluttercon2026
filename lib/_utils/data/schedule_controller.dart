import 'package:flutter/foundation.dart';
import 'package:fluttercon2026/_utils/data/conference_data.dart';
import 'package:fluttercon2026/_utils/data/models.dart';
import 'package:fluttercon2026/_utils/data/schedule_store.dart';

class ScheduleConflict {
  const ScheduleConflict({required this.sessionA, required this.sessionB});

  final Session sessionA;
  final Session sessionB;
}

class ScheduleController extends ChangeNotifier {
  ScheduleController(this._store) {
    _hydrate();
  }

  final ScheduleStore _store;

  final Set<String> _bookmarkedIds = {};
  final Set<String> _remindersOn = {};
  final Set<String> _followedSpeakerIds = {};
  final Map<String, int> _ratings = {};

  Set<String> get bookmarkedIds => Set.unmodifiable(_bookmarkedIds);
  Set<String> get followedSpeakerIds => Set.unmodifiable(_followedSpeakerIds);

  bool isBookmarked(String sessionId) => _bookmarkedIds.contains(sessionId);

  bool isReminderOn(String sessionId) => _remindersOn.contains(sessionId);

  bool isFollowing(String speakerId) => _followedSpeakerIds.contains(speakerId);

  int? ratingFor(String sessionId) => _ratings[sessionId];

  List<Session> get bookmarkedSessions {
    return ConferenceData.sessions.where((s) => _bookmarkedIds.contains(s.id) && !s.isBreak).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  Map<DateTime, List<Session>> get bookmarkedByDay {
    final map = <DateTime, List<Session>>{};
    for (final session in bookmarkedSessions) {
      final key = DateTime(session.day.year, session.day.month, session.day.day);
      map.putIfAbsent(key, () => []).add(session);
    }
    return map;
  }

  List<ScheduleConflict> get conflicts {
    final booked = bookmarkedSessions;
    final result = <ScheduleConflict>[];
    for (var i = 0; i < booked.length; i++) {
      for (var j = i + 1; j < booked.length; j++) {
        if (booked[i].overlaps(booked[j])) {
          result.add(ScheduleConflict(sessionA: booked[i], sessionB: booked[j]));
        }
      }
    }
    return result;
  }

  bool hasConflict(String sessionId) {
    return conflicts.any((c) => c.sessionA.id == sessionId || c.sessionB.id == sessionId);
  }

  void _hydrate() {
    final knownSessionIds = ConferenceData.sessions.map((s) => s.id).toSet();
    final knownSpeakerIds = ConferenceData.speakers.map((s) => s.id).toSet();

    _bookmarkedIds
      ..clear()
      ..addAll(_store.readBookmarks().where(knownSessionIds.contains));
    _remindersOn
      ..clear()
      ..addAll(_store.readReminders().where((id) => _bookmarkedIds.contains(id) && knownSessionIds.contains(id)));
    _followedSpeakerIds
      ..clear()
      ..addAll(_store.readFollowedSpeakers().where(knownSpeakerIds.contains));
    _ratings
      ..clear()
      ..addAll(Map.fromEntries(_store.readRatings().entries.where((e) => knownSessionIds.contains(e.key))));
  }

  Future<void> _persistSchedule() async {
    await Future.wait([_store.writeBookmarks(_bookmarkedIds), _store.writeReminders(_remindersOn)]);
  }

  Future<void> _persistFollowed() => _store.writeFollowedSpeakers(_followedSpeakerIds);

  Future<void> _persistRatings() => _store.writeRatings(_ratings);

  Future<void> toggleBookmark(String sessionId) async {
    if (_bookmarkedIds.contains(sessionId)) {
      _bookmarkedIds.remove(sessionId);
      _remindersOn.remove(sessionId);
    } else {
      _bookmarkedIds.add(sessionId);
      _remindersOn.add(sessionId);
    }
    notifyListeners();
    await _persistSchedule();
  }

  Future<void> removeFromSchedule(String sessionId) async {
    _bookmarkedIds.remove(sessionId);
    _remindersOn.remove(sessionId);
    notifyListeners();
    await _persistSchedule();
  }

  Future<void> toggleReminder(String sessionId) async {
    if (!_bookmarkedIds.contains(sessionId)) return;
    if (_remindersOn.contains(sessionId)) {
      _remindersOn.remove(sessionId);
    } else {
      _remindersOn.add(sessionId);
    }
    notifyListeners();
    await _persistSchedule();
  }

  Future<void> toggleFollowSpeaker(String speakerId) async {
    if (_followedSpeakerIds.contains(speakerId)) {
      _followedSpeakerIds.remove(speakerId);
    } else {
      _followedSpeakerIds.add(speakerId);
    }
    notifyListeners();
    await _persistFollowed();
  }

  Future<void> setRating(String sessionId, int rating) async {
    _ratings[sessionId] = rating.clamp(1, 5);
    notifyListeners();
    await _persistRatings();
  }

  Future<void> resolveConflict(String keepId, String removeId) {
    return removeFromSchedule(removeId);
  }
}
