import 'package:drift/drift.dart';

import '../core/dates.dart';
import '../database/app_database.dart';
import '../database/tables.dart';
import 'schedule_engine.dart';

class ScheduleRuleRepository {
  ScheduleRuleRepository(this._db);

  final AppDatabase _db;

  Stream<List<ScheduleRule>> watchAll() =>
      _db.select(_db.scheduleRules).watch();

  Future<List<ScheduleRule>> getAll() => _db.select(_db.scheduleRules).get();

  Future<int> addEveryNDays({
    required int exerciseId,
    required int intervalDays,
    required DateTime start,
  }) {
    assert(intervalDays >= 1);
    return _db.into(_db.scheduleRules).insert(
      ScheduleRulesCompanion.insert(
        exerciseId: exerciseId,
        type: ScheduleType.everyNDays,
        intervalDays: Value(intervalDays),
        startDate: dayKey(start),
      ),
    );
  }

  Future<int> addWeekdays({
    required int exerciseId,
    required Set<int> weekdays,
    required DateTime start,
  }) {
    assert(weekdays.isNotEmpty);
    return _db.into(_db.scheduleRules).insert(
      ScheduleRulesCompanion.insert(
        exerciseId: exerciseId,
        type: ScheduleType.weekdays,
        weekdayMask: Value(weekdayMaskOf(weekdays)),
        startDate: dayKey(start),
      ),
    );
  }

  /// Stops a rule after [lastDay]. If [lastDay] is before the rule started,
  /// the rule never applied to any day, so it's removed instead.
  Future<void> endRule(int ruleId, DateTime lastDay) async {
    final query = _db.select(_db.scheduleRules)
      ..where((r) => r.id.equals(ruleId));
    final rule = await query.getSingle();

    if (lastDay.isBefore(parseDay(rule.startDate))) {
      await (_db.delete(_db.scheduleRules)..where((r) => r.id.equals(ruleId)))
          .go();
    } else {
      await (_db.update(_db.scheduleRules)..where((r) => r.id.equals(ruleId)))
          .write(ScheduleRulesCompanion(endDate: Value(dayKey(lastDay))));
    }
  }
}