import 'package:shared_preferences/shared_preferences.dart';

/// Persists My Schedule (and related prefs) locally.
class ScheduleStore {
  ScheduleStore(this._prefs);

  static const _bookmarksKey = 'schedule.bookmarked_session_ids';
  static const _remindersKey = 'schedule.reminder_session_ids';
  static const _followedKey = 'schedule.followed_speaker_ids';
  static const _ratingsKey = 'schedule.session_ratings';

  final SharedPreferences _prefs;

  static Future<ScheduleStore> open() async {
    final prefs = await SharedPreferences.getInstance();
    return ScheduleStore(prefs);
  }

  Set<String> readBookmarks() => (_prefs.getStringList(_bookmarksKey) ?? const []).toSet();

  Set<String> readReminders() => (_prefs.getStringList(_remindersKey) ?? const []).toSet();

  Set<String> readFollowedSpeakers() => (_prefs.getStringList(_followedKey) ?? const []).toSet();

  Map<String, int> readRatings() {
    final raw = _prefs.getStringList(_ratingsKey) ?? const [];
    final map = <String, int>{};
    for (final entry in raw) {
      final parts = entry.split('=');
      if (parts.length != 2) continue;
      final rating = int.tryParse(parts[1]);
      if (rating == null) continue;
      map[parts[0]] = rating;
    }
    return map;
  }

  Future<void> writeBookmarks(Set<String> ids) => _prefs.setStringList(_bookmarksKey, ids.toList()..sort());

  Future<void> writeReminders(Set<String> ids) => _prefs.setStringList(_remindersKey, ids.toList()..sort());

  Future<void> writeFollowedSpeakers(Set<String> ids) => _prefs.setStringList(_followedKey, ids.toList()..sort());

  Future<void> writeRatings(Map<String, int> ratings) {
    final entries = ratings.entries.map((e) => '${e.key}=${e.value}').toList()..sort();
    return _prefs.setStringList(_ratingsKey, entries);
  }
}
