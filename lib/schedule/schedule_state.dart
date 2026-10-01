import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dates.dart';
import '../database/app_database.dart';
import '../database/database_state.dart';
import 'schedule_rule_repository.dart';

final scheduleRuleRepositoryProvider = Provider<ScheduleRuleRepository>(
      (ref) => ScheduleRuleRepository(ref.watch(appDatabaseProvider)),
);

final scheduleRulesProvider = StreamProvider<List<ScheduleRule>>(
      (ref) => ref.watch(scheduleRuleRepositoryProvider).watchAll(),
);

class ScheduleActions {
  ScheduleActions(this._db, this._rules);

  final AppDatabase _db;
  final ScheduleRuleRepository _rules;

  Future<int> addEveryNDays({
    required int exerciseId,
    required int intervalDays,
    required DateTime start,
  }) =>
      _rules.addEveryNDays(
          exerciseId: exerciseId, intervalDays: intervalDays, start: start);

  Future<int> addWeekdays({
    required int exerciseId,
    required Set<int> weekdays,
    required DateTime start,
  }) =>
      _rules.addWeekdays(
          exerciseId: exerciseId, weekdays: weekdays, start: start);

  Future<void> stop(int ruleId, {required DateTime lastDay}) =>
      _rules.endRule(ruleId, lastDay);

  /// Editing a rule: the old one ends the day before [from] and the new one
  /// starts on [from], atomically.
  Future<int> replaceWithEveryNDays({
    required int oldRuleId,
    required int exerciseId,
    required int intervalDays,
    required DateTime from,
  }) =>
      _db.transaction(() async {
        await _rules.endRule(oldRuleId, addDays(from, -1));
        return _rules.addEveryNDays(
            exerciseId: exerciseId, intervalDays: intervalDays, start: from);
      });

  Future<int> replaceWithWeekdays({
    required int oldRuleId,
    required int exerciseId,
    required Set<int> weekdays,
    required DateTime from,
  }) =>
      _db.transaction(() async {
        await _rules.endRule(oldRuleId, addDays(from, -1));
        return _rules.addWeekdays(
            exerciseId: exerciseId, weekdays: weekdays, start: from);
      });
}

final scheduleActionsProvider = Provider<ScheduleActions>(
      (ref) => ScheduleActions(
    ref.watch(appDatabaseProvider),
    ref.watch(scheduleRuleRepositoryProvider),
  ),
);