import 'dart:convert';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_trainer/database/app_database.dart';
import 'package:personal_trainer/database/tables.dart';
import 'package:personal_trainer/export/backup_service.dart';
import 'package:personal_trainer/schedule/schedule_rule_repository.dart';
import 'package:personal_trainer/sessions/session_repository.dart';
import 'package:personal_trainer/weight/weight_repository.dart';

const running = 1; // Seeded first in onCreate.
const squats = 2;

DateTime d(int month, int day) => DateTime(2026, month, day);

void main() {
  // The restore tests open a second, separate in-memory database on purpose.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late BackupService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    service = BackupService(db);
  });

  tearDown(() => db.close());

  Future<void> addSomeData() async {
    await ScheduleRuleRepository(db)
        .addWeekdays(exerciseId: squats, weekdays: {1, 3, 5}, start: d(9, 1));
    final sessions = SessionRepository(db);
    await sessions.setTargets(running, d(9, 2), total: 2.5, continuous: 1);
    await sessions.logActuals(running, d(9, 2),
        total: 3, continuous: 1.2, note: 'windy, "tough"');
    await sessions.logActuals(squats, d(9, 3), total: 95, continuous: 40,
        sets: [40, 30, 25]);
    await sessions.setStatusOverride(squats, d(9, 3), SessionStatus.done);
    final weight = WeightRepository(db);
    await weight.log(d(9, 2), 88.4);
    await weight.log(d(9, 3), 88.1, note: 'after run');
  }

  test('a backup reads back to exactly the same rows', () async {
    await addSomeData();
    final json = await service.exportJson(now: DateTime(2026, 10, 1, 9, 30));
    final data = service.parse(json);

    expect(data.exercises, await db.select(db.exercises).get());
    expect(data.scheduleRules, await db.select(db.scheduleRules).get());
    expect(data.sessions, await db.select(db.sessions).get());
    expect(data.weightEntries, await db.select(db.weightEntries).get());
    expect(data.sessions, hasLength(2));
    expect(data.weightEntries, hasLength(2));
  });

  test('the header records app, versions and time', () async {
    final json = await service.exportJson(now: DateTime(2026, 10, 1, 9, 30));
    final map = jsonDecode(json) as Map<String, dynamic>;
    expect(map['app'], 'personal_trainer');
    expect(map['formatVersion'], backupFormatVersion);
    expect(map['schemaVersion'], db.schemaVersion);
    expect(map['exportedAt'], '2026-10-01T09:30:00.000');
  });

  group('restore', () {
    late AppDatabase other;
    late BackupService otherService;

    setUp(() {
      other = AppDatabase(NativeDatabase.memory());
      otherService = BackupService(other);
    });

    tearDown(() => other.close());

    test('replaces everything with the backup', () async {
      await addSomeData();
      final backup = service.parse(
          await service.exportJson(now: DateTime(2026, 10, 1)));

      // Different data in the target, all of which should go.
      await WeightRepository(other).log(d(8, 1), 95);
      await SessionRepository(other)
          .logActuals(running, d(8, 1), total: 1);

      await otherService.restore(backup);

      expect(await other.select(other.exercises).get(), backup.exercises);
      expect(await other.select(other.scheduleRules).get(),
          backup.scheduleRules);
      expect(await other.select(other.sessions).get(), backup.sessions);
      expect(await other.select(other.weightEntries).get(),
          backup.weightEntries);
    });

    test('new rows after a restore get fresh ids', () async {
      await addSomeData();
      final backup = service.parse(
          await service.exportJson(now: DateTime(2026, 10, 1)));
      await otherService.restore(backup);

      await SessionRepository(other).setTargets(running, d(9, 10), total: 3);

      final ids = (await other.select(other.sessions).get()).map((s) => s.id);
      expect(ids.toSet(), hasLength(3));
    });

    test('a failing restore leaves the data untouched', () async {
      await addSomeData();
      final before = await db.select(db.sessions).get();
      final backup = service.parse(
          await service.exportJson(now: DateTime(2026, 10, 1)));

      // A session pointing at an exercise that isn't in the backup.
      final broken = BackupData(
        schemaVersion: backup.schemaVersion,
        exportedAt: backup.exportedAt,
        exercises: backup.exercises,
        scheduleRules: backup.scheduleRules,
        sessions: [
          const Session(id: 50, exerciseId: 99, date: '2026-09-09'),
        ],
        weightEntries: backup.weightEntries,
      );

      await expectLater(service.restore(broken), throwsA(anything));
      expect(await db.select(db.sessions).get(), before);
      expect(await db.select(db.exercises).get(), hasLength(3));
    });
  });

  group('parse rejects', () {
    Future<Map<String, dynamic>> validBackup() async =>
        jsonDecode(await service.exportJson(now: DateTime(2026, 10, 1)))
        as Map<String, dynamic>;

    void expectRejected(String text, String message) => expect(
          () => service.parse(text),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', message)),
        );

    test('text that isn\'t JSON', () {
      expectRejected('not json', 'This file isn\'t valid JSON.');
    });

    test('JSON from something else', () {
      expectRejected('{"hello": 1}',
          'This file isn\'t a Personal Trainer backup.');
    });

    test('a backup from a newer app version', () async {
      final map = await validBackup()..['formatVersion'] = backupFormatVersion + 1;
      expectRejected(jsonEncode(map),
          'This backup was made by a newer version of the app.');
    });

    test('a newer database schema', () async {
      final map = await validBackup()..['schemaVersion'] = db.schemaVersion + 1;
      expectRejected(jsonEncode(map),
          'This backup was made by a newer version of the app.');
    });

    test('a missing table', () async {
      final map = await validBackup()..remove('sessions');
      expectRejected(jsonEncode(map), 'The backup is incomplete or damaged.');
    });

    test('a damaged row', () async {
      final map = await validBackup();
      map['exercises'] = [
        {'id': 1, 'name': 'Running'},
      ];
      expectRejected(jsonEncode(map), 'The backup is incomplete or damaged.');
    });
  });
}
