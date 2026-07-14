import 'package:flutter/material.dart';
import 'package:fluttercon2026/_utils/colors.dart';

class Speaker {
  const Speaker({
    required this.id,
    required this.name,
    required this.title,
    required this.company,
    required this.imageUrl,
    required this.bio,
    required this.tags,
    this.tagLine = '',
    this.twitterUrl,
    this.linkedinUrl,
    this.websiteUrl,
    this.sessionIds = const [],
  });

  final String id;
  final String name;
  final String title;
  final String company;
  final String imageUrl;
  final String bio;
  final List<String> tags;
  final String tagLine;
  final String? twitterUrl;
  final String? linkedinUrl;
  final String? websiteUrl;
  final List<String> sessionIds;

  String get roleLine {
    if (title.isNotEmpty && company.isNotEmpty) return '$title • $company';
    if (tagLine.isNotEmpty) return tagLine;
    if (title.isNotEmpty) return title;
    if (company.isNotEmpty) return company;
    return 'Speaker';
  }

  String get sortLetter {
    final parts = name.trim().split(RegExp(r'\s+'));
    final last = parts.isEmpty ? '?' : parts.last;
    return last[0].toUpperCase();
  }
}

class Session {
  const Session({
    required this.id,
    required this.title,
    required this.track,
    required this.room,
    required this.day,
    required this.start,
    required this.end,
    required this.speakerIds,
    required this.description,
    required this.accentColor,
    this.isBreak = false,
    this.breakLocation,
    this.headerImageUrl,
    this.capacityFilled,
    this.capacityTotal,
    this.typeLabel,
    this.tags = const [],
    this.relatedSessionIds = const [],
  });

  final String id;
  final String title;

  /// Track Selection from Sessionize (e.g. Fluttercon, flutter@scale track).
  final String? track;
  final String room;
  final DateTime day;
  final DateTime start;
  final DateTime end;
  final List<String> speakerIds;
  final String description;
  final int accentColor;
  final bool isBreak;
  final String? breakLocation;
  final String? headerImageUrl;
  final int? capacityFilled;
  final int? capacityTotal;

  /// Session format (Keynote, Workshop, Session, …).
  final String? typeLabel;
  final List<String> tags;
  final List<String> relatedSessionIds;

  bool overlaps(Session other) {
    if (isBreak || other.isBreak) return false;
    if (!_sameDay(day, other.day)) return false;
    return start.isBefore(other.end) && other.start.isBefore(end);
  }

  static bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

class ConferenceDay {
  const ConferenceDay({required this.date, required this.weekdayShort, required this.dateLabel});

  final DateTime date;
  final String weekdayShort;
  final String dateLabel;
}

Color accentForTrack(String? track) {
  final key = (track ?? '').toLowerCase();
  if (key.contains('scale')) return AppColors.chart2;
  if (key.contains('techlead')) return AppColors.chart4;
  if (key.contains('unsolved') || key.contains('unconference')) {
    return AppColors.chart5;
  }
  if (key.contains('agentic')) return AppColors.chart3;
  if (key.contains('fluttercon')) return AppColors.primary;
  return AppColors.primary;
}

String displayTrackLabel(String track) {
  final lower = track.toLowerCase();
  if (lower == 'fluttercon') return 'FlutterCon';
  if (lower.contains('scale')) return 'Flutter @ Scale';
  if (lower.contains('techlead')) return 'TechLead';
  if (lower.contains('unsolved') || lower.contains('unconference')) {
    return 'Unconference';
  }
  if (lower.contains('agentic')) return 'Agentic';
  return track;
}
