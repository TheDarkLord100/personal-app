import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/dates.dart';
import '../database/app_database.dart';
import '../database/tables.dart';

class SessionRepository {
  SessionRepository(this._db);

  final AppDatabase _db;

  $SessionsTable get _sessions => _db.sessions;

  Stream<List<Session>> watchBetween(DateTime from, DateTime to) {
    final query = _db.select(_sessions)
      ..where((s) => s.date.isBetweenValues(dayKey(from), dayKey(to)))
      ..orderBy([(s) => OrderingTerm.asc(s.date)]);
    return query.watch();
  }

  Stream<List<Session>> watchAll() {
    final query = _db.select(_sessions)
      ..orderBy([
            (s) => OrderingTerm.asc(s.date),
            (s) => OrderingTerm.asc(s.exerciseId),
      ]);
    return query.watch();
  }

  Future<Session?> find(int exerciseId, DateTime day) {
    final query = _db.select(_sessions)
      ..where((s) =>
      s.exerciseId.equals(exerciseId) & s.date.equals(dayKey(day)));
    return query.getSingleOrNull();
  }

  /// Sets both targets for one day. Passing null clears that target.
  Future<void> setTargets(
      int exerciseId,
      DateTime day, {
        double? total,
        double? continuous,
      }) =>
      setTargetsOn(exerciseId, [day], total: total, continuous: continuous);

  /// Sets the same targets on several days at once, e.g. the next 3 runs.
  Future<void> setTargetsOn(
      int exerciseId,
      List<DateTime> days, {
        double? total,
        double? continuous,
      }) {
    return _db.transaction(() async {
      for (final day in days) {
        await _upsert(
          exerciseId,
          day,
          SessionsCompanion(
            targetTotal: Value(total),
            targetContinuous: Value(continuous),
          ),
        );
      }
    });
  }

  /// Records what you actually did. Targets on the same day are untouched.
  Future<void> logActuals(
      int exerciseId,
      DateTime day, {
        double? total,
        double? continuous,
        List<num>? sets,
        String? note,
      }) =>
      _upsert(
        exerciseId,
        day,
        SessionsCompanion(
          actualTotal: Value(total),
          actualContinuous: Value(continuous),
          sets: Value(sets == null ? null : jsonEncode(sets)),
          note: Value(note),
        ),
      );

  /// Removes a log (actuals, sets, note, override) but keeps the targets.
  Future<void> clearLog(int exerciseId, DateTime day) => _upsert(
    exerciseId,
    day,
    const SessionsCompanion(
      actualTotal: Value(null),
      actualContinuous: Value(null),
      sets: Value(null),
      note: Value(null),
      statusOverride: Value(null),
    ),
  );

  /// Pass null to go back to the computed status.
  Future<void> setStatusOverride(
      int exerciseId,
      DateTime day,
      SessionStatus? status,
      ) =>
      _upsert(
        exerciseId,
        day,
        SessionsCompanion(statusOverride: Value(status)),
      );

  /// Most recent sessions with something logged, strictly before [before],
  /// newest first. Used for target suggestions.
  Future<List<Session>> recentLogged(
      int exerciseId, {
        required DateTime before,
        int limit = 5,
      }) {
    final query = _db.select(_sessions)
      ..where((s) =>
      s.exerciseId.equals(exerciseId) &
      s.date.isSmallerThanValue(dayKey(before)) &
      (s.actualTotal.isNotNull() | s.actualContinuous.isNotNull()))
      ..orderBy([(s) => OrderingTerm.desc(s.date)])
      ..limit(limit);
    return query.get();
  }

  /// Everything, oldest first. Used for CSV export and backup.
  Future<List<Session>> all() {
    final query = _db.select(_sessions)
      ..orderBy([
            (s) => OrderingTerm.asc(s.date),
            (s) => OrderingTerm.asc(s.exerciseId),
      ]);
    return query.get();
  }

  /// Inserts the row if it doesn't exist; otherwise updates only the
  /// columns present in [changes].
  Future<void> _upsert(
      int exerciseId,
      DateTime day,
      SessionsCompanion changes,
      ) {
    return _db.into(_sessions).insert(
      changes.copyWith(
        exerciseId: Value(exerciseId),
        date: Value(dayKey(day)),
      ),
      onConflict: DoUpdate(
            (_) => changes,
        target: [_sessions.exerciseId, _sessions.date],
      ),
    );
  }
}

extension SessionSets on Session {
  List<double> get setList => sets == null
      ? const []
      : (jsonDecode(sets!) as List)
      .map((e) => (e as num).toDouble())
      .toList();
}