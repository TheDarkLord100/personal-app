import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dates.dart';
import '../core/today_state.dart';
import '../database/app_database.dart';
import '../database/database_state.dart';
import '../database/tables.dart';
import '../exercises/exercises_state.dart';
import '../schedule/schedule_engine.dart';
import '../schedule/schedule_rule_repository.dart';
import '../schedule/schedule_state.dart';
import 'session_repository.dart';
import 'session_status.dart';
import 'target_suggestion.dart';

/// One exercise on one day, as the UI shows it.
class DaySession {
  const DaySession({
    required this.exercise,
    required this.date,
    required this.session,
    required this.scheduled,
    required this.status,
  });

  final Exercise exercise;
  final DateTime date;

  /// Null when the day is scheduled but nothing has been planned or logged.
  final Session? session;

  /// False for a session on a day its schedule doesn't cover
  /// (an extra workout, or one left over from an old rule).
  final bool scheduled;

  /// Null when not due yet.
  final SessionStatus? status;
}

/// Merges scheduled days with stored rows for [from]..[to], sorted by date
/// and then exercise.
List<DaySession> buildDaySessions({
  required List<Exercise> exercises,
  required List<ScheduleRule> rules,
  required List<Session> sessions,
  required DateTime from,
  required DateTime to,
  required DateTime today,
}) {
  final exercisesById = {for (final e in exercises) e.id: e};
  final rowsByKey = {for (final s in sessions) (s.exerciseId, s.date): s};
  final covered = <(int, String)>{};
  final result = <DaySession>[];

  for (final occurrence in occurrencesBetween(rules, from, to)) {
    final exercise = exercisesById[occurrence.exerciseId];
    if (exercise == null) continue;
    final key = (occurrence.exerciseId, dayKey(occurrence.date));
    covered.add(key);
    final row = rowsByKey[key];
    result.add(DaySession(
      exercise: exercise,
      date: occurrence.date,
      session: row,
      scheduled: true,
      status: statusFor(row, occurrence.date, today),
    ));
  }

  for (final row in sessions) {
    if (covered.contains((row.exerciseId, row.date))) continue;
    final exercise = exercisesById[row.exerciseId];
    final date = parseDay(row.date);
    if (exercise == null || date.isBefore(from) || date.isAfter(to)) continue;
    result.add(DaySession(
      exercise: exercise,
      date: date,
      session: row,
      scheduled: false,
      status: statusFor(row, date, today),
    ));
  }

  result.sort((a, b) {
    final byDate = a.date.compareTo(b.date);
    return byDate != 0 ? byDate : a.exercise.id.compareTo(b.exercise.id);
  });
  return result;
}

({double total, double continuous}) totalsFromSets(List<num> sets) => (
total: sets.fold(0.0, (sum, s) => sum + s),
continuous:
sets.isEmpty ? 0.0 : sets.map((s) => s.toDouble()).reduce(math.max),
);

// ---------------------------------------------------------------------------
// Providers

final sessionRepositoryProvider = Provider<SessionRepository>(
      (ref) => SessionRepository(ref.watch(appDatabaseProvider)),
);

final allSessionsProvider = StreamProvider<List<Session>>(
      (ref) => ref.watch(sessionRepositoryProvider).watchAll(),
);

final _sessionRowsProvider = StreamProvider.autoDispose
    .family<List<Session>, (DateTime, DateTime)>(
      (ref, range) =>
      ref.watch(sessionRepositoryProvider).watchBetween(range.$1, range.$2),
);

/// Sessions for a date range, inclusive. Today screen: (today, today).
final daySessionsProvider = FutureProvider.autoDispose
    .family<List<DaySession>, (DateTime, DateTime)>((ref, range) async {
  final exercisesFuture = ref.watch(exercisesProvider.future);
  final rulesFuture = ref.watch(scheduleRulesProvider.future);
  final rowsFuture = ref.watch(_sessionRowsProvider(range).future);
  final today = ref.watch(todayProvider);

  return buildDaySessions(
    exercises: await exercisesFuture,
    rules: await rulesFuture,
    sessions: await rowsFuture,
    from: range.$1,
    to: range.$2,
    today: today,
  );
});

/// Pre-filled targets for one exercise on one day.
final targetSuggestionProvider = FutureProvider.autoDispose
    .family<TargetSuggestion?, (int, DateTime)>((ref, args) async {
  final (exerciseId, day) = args;
  final exercisesFuture = ref.watch(exercisesProvider.future);
  final rulesFuture = ref.watch(scheduleRulesProvider.future);
  final repo = ref.watch(sessionRepositoryProvider);

  final exercise =
  (await exercisesFuture).firstWhere((e) => e.id == exerciseId);
  final ownRules =
  (await rulesFuture).where((r) => r.exerciseId == exerciseId).toList();
  final remaining =
      occurrencesBetween(ownRules, day, parseDay(exercise.deadline)).length;

  return suggestTarget(
    exercise: exercise,
    recentLogged: await repo.recentLogged(exerciseId, before: day),
    remainingSessions: math.max(remaining, 1),
  );
});

// ---------------------------------------------------------------------------
// Actions

class SessionActions {
  SessionActions(this._sessions, this._rules);

  final SessionRepository _sessions;
  final ScheduleRuleRepository _rules;

  Future<void> setTargets(
      int exerciseId,
      DateTime day, {
        double? total,
        double? continuous,
        double? running,
      }) =>
      _sessions.setTargets(exerciseId, day,
          total: total, continuous: continuous, running: running);

  /// Sets targets on the next [count] scheduled days from [from], skipping
  /// days that are already logged. Returns the days it set.
  Future<List<DateTime>> setTargetsForNext({
    required int exerciseId,
    required DateTime from,
    required int count,
    double? total,
    double? continuous,
    double? running,
  }) async {
    final rules = await _rules.getAll();
    final picked = <DateTime>[];
    var cursor = from;

    while (picked.length < count) {
      final batch = nextOccurrences(rules, exerciseId, cursor, count);
      if (batch.isEmpty) break;
      for (final day in batch) {
        if (!_isLogged(await _sessions.find(exerciseId, day))) {
          picked.add(day);
          if (picked.length == count) break;
        }
      }
      cursor = addDays(batch.last, 1);
    }

    await _sessions.setTargetsOn(exerciseId, picked,
        total: total, continuous: continuous, running: running);
    return picked;
  }

  /// If [sets] is given, total and continuous are derived from it.
  Future<void> log(
      int exerciseId,
      DateTime day, {
        double? total,
        double? continuous,
        double? running,
        List<num>? sets,
        String? note,
      }) {
    final hasSets = sets != null && sets.isNotEmpty;
    final fromSets = hasSets ? totalsFromSets(sets) : null;
    final trimmedNote = note?.trim();

    return _sessions.logActuals(
      exerciseId,
      day,
      total: fromSets?.total ?? total,
      continuous: fromSets?.continuous ?? continuous,
      running: running,
      sets: hasSets ? sets : null,
      note: (trimmedNote == null || trimmedNote.isEmpty) ? null : trimmedNote,
    );
  }

  Future<void> clearLog(int exerciseId, DateTime day) =>
      _sessions.clearLog(exerciseId, day);

  Future<void> setStatusOverride(
      int exerciseId,
      DateTime day,
      SessionStatus? status,
      ) =>
      _sessions.setStatusOverride(exerciseId, day, status);

  bool _isLogged(Session? s) =>
      s != null &&
          (s.actualTotal != null ||
              s.actualContinuous != null ||
              s.actualRunning != null);
}

final sessionActionsProvider = Provider<SessionActions>(
      (ref) => SessionActions(
    ref.watch(sessionRepositoryProvider),
    ref.watch(scheduleRuleRepositoryProvider),
  ),
);