import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_trainer/database/app_database.dart';
import 'package:personal_trainer/schedule/schedule_rule_repository.dart';

const running = 1;

void main() {
  late AppDatabase db;
  late ScheduleRuleRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ScheduleRuleRepository(db);
  });

  tearDown(() => db.close());

  test('ending a rule sets its end date', () async {
    final id = await repo.addEveryNDays(
        exerciseId: running, intervalDays: 2, start: DateTime(2026, 10, 1));
    await repo.endRule(id, DateTime(2026, 10, 9));
    final rule = (await repo.getAll()).single;
    expect(rule.endDate, '2026-10-09');
  });

  test('ending a rule before it started removes it', () async {
    final id = await repo.addEveryNDays(
        exerciseId: running, intervalDays: 2, start: DateTime(2026, 10, 10));
    await repo.endRule(id, DateTime(2026, 10, 9));
    expect(await repo.getAll(), isEmpty);
  });

  test('weekday rules store the mask', () async {
    await repo.addWeekdays(
      exerciseId: running,
      weekdays: {DateTime.monday, DateTime.friday},
      start: DateTime(2026, 10, 5),
    );
    final rule = (await repo.getAll()).single;
    expect(rule.weekdayMask, 1 | (1 << 4));
  });
}