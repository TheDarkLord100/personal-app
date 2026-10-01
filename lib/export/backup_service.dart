import 'dart:convert';

import '../database/app_database.dart';

/// Bump when the backup layout itself changes (not the tables).
const backupFormatVersion = 1;

const _appTag = 'personal_trainer';

/// Everything in the database, as read from a backup file.
class BackupData {
  const BackupData({
    required this.schemaVersion,
    required this.exportedAt,
    required this.exercises,
    required this.scheduleRules,
    required this.sessions,
    required this.weightEntries,
  });

  final int schemaVersion;
  final String exportedAt;
  final List<Exercise> exercises;
  final List<ScheduleRule> scheduleRules;
  final List<Session> sessions;
  final List<WeightEntry> weightEntries;
}

/// Writes the whole database to JSON and reads it back. Rows keep their ids
/// so references between tables survive a restore.
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  Future<String> exportJson({required DateTime now}) async {
    // One transaction so the four tables are read as a consistent snapshot.
    final tables = await _db.transaction(() async => (
      exercises: await _db.select(_db.exercises).get(),
      rules: await _db.select(_db.scheduleRules).get(),
      sessions: await _db.select(_db.sessions).get(),
      weight: await _db.select(_db.weightEntries).get(),
    ));

    return const JsonEncoder.withIndent('  ').convert({
      'app': _appTag,
      'formatVersion': backupFormatVersion,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': now.toIso8601String(),
      'exercises': [for (final r in tables.exercises) r.toJson()],
      'scheduleRules': [for (final r in tables.rules) r.toJson()],
      'sessions': [for (final r in tables.sessions) r.toJson()],
      'weightEntries': [for (final r in tables.weight) r.toJson()],
    });
  }

  /// Replaces everything in the database with [data], in one transaction:
  /// if any row fails, nothing changes.
  Future<void> restore(BackupData data) => _db.transaction(() async {
    // Children before parents: foreign keys are on.
    await _db.delete(_db.sessions).go();
    await _db.delete(_db.scheduleRules).go();
    await _db.delete(_db.weightEntries).go();
    await _db.delete(_db.exercises).go();

    await _db.batch((b) {
      b.insertAll(_db.exercises, data.exercises);
      b.insertAll(_db.scheduleRules, data.scheduleRules);
      b.insertAll(_db.sessions, data.sessions);
      b.insertAll(_db.weightEntries, data.weightEntries);
    });
  });

  /// Reads and checks a backup file completely, without touching the
  /// database. Throws [FormatException] with a readable message if the
  /// file isn't a backup this version of the app can restore.
  BackupData parse(String text) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw const FormatException('This file isn\'t valid JSON.');
    }
    if (decoded is! Map<String, dynamic> || decoded['app'] != _appTag) {
      throw const FormatException('This file isn\'t a Personal Trainer backup.');
    }
    final map = decoded;

    final format = map['formatVersion'];
    final schema = map['schemaVersion'];
    if (format is! int || schema is! int) {
      throw const FormatException('The backup is missing its version.');
    }
    if (format > backupFormatVersion || schema > _db.schemaVersion) {
      throw const FormatException(
          'This backup was made by a newer version of the app.');
    }

    try {
      List<T> rows<T>(String key, T Function(Map<String, dynamic>) fromJson) =>
          [for (final r in map[key] as List) fromJson(r as Map<String, dynamic>)];

      return BackupData(
        schemaVersion: schema,
        exportedAt: map['exportedAt'] as String? ?? '',
        exercises: rows('exercises', Exercise.fromJson),
        scheduleRules: rows('scheduleRules', ScheduleRule.fromJson),
        sessions: rows('sessions', Session.fromJson),
        weightEntries: rows('weightEntries', WeightEntry.fromJson),
      );
    } catch (_) {
      throw const FormatException('The backup is incomplete or damaged.');
    }
  }
}
