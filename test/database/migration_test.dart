import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_trainer/database/app_database.dart';

// Exactly what schema 1 created, captured from the app before the change.
const _schema1 = [
  'CREATE TABLE "exercises" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"name" TEXT NOT NULL, "unit" TEXT NOT NULL, "goal_total" REAL NOT NULL, '
      '"goal_continuous" REAL NOT NULL, "deadline" TEXT NOT NULL)',
  'CREATE TABLE "schedule_rules" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"exercise_id" INTEGER NOT NULL REFERENCES exercises (id), '
      '"type" INTEGER NOT NULL, "interval_days" INTEGER NULL, '
      '"weekday_mask" INTEGER NULL, "start_date" TEXT NOT NULL, '
      '"end_date" TEXT NULL)',
  'CREATE TABLE "sessions" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
      '"exercise_id" INTEGER NOT NULL REFERENCES exercises (id), '
      '"date" TEXT NOT NULL, "target_total" REAL NULL, '
      '"target_continuous" REAL NULL, "actual_total" REAL NULL, '
      '"actual_continuous" REAL NULL, "sets" TEXT NULL, "note" TEXT NULL, '
      '"status_override" INTEGER NULL)',
  'CREATE TABLE "weight_entries" ("date" TEXT NOT NULL, "kg" REAL NOT NULL, '
      '"note" TEXT NULL, PRIMARY KEY ("date"))',
  'CREATE UNIQUE INDEX session_exercise_day ON sessions (exercise_id, date)',
];

/// A schema-1 database with some data in it.
AppDatabase openSchema1Database() => AppDatabase(NativeDatabase.memory(
      setup: (raw) {
        for (final sql in _schema1) {
          raw.execute(sql);
        }
        raw.execute(
          "INSERT INTO exercises VALUES "
          "(1, 'Running', 'km', 5, 2, '2026-12-31'), "
          "(2, 'Squats', 'reps', 1000, 200, '2026-12-31')",
        );
        raw.execute(
          'INSERT INTO sessions (id, exercise_id, date, target_total, '
          'target_continuous, actual_total, actual_continuous, sets) VALUES '
          "(1, 1, '2026-09-02', 3, 1, 4, 1.5, NULL), "
          "(2, 1, '2026-09-04', NULL, NULL, NULL, 1.2, NULL), "
          "(3, 2, '2026-09-03', 100, 40, 95, 40, '[40,30,25]')",
        );
        raw.execute("INSERT INTO weight_entries VALUES ('2026-09-02', 88.4, NULL)");
        raw.execute('PRAGMA user_version = 1');
      },
    ));

void main() {
  test('an older database is wiped and starts fresh', () async {
    final db = openSchema1Database();
    addTearDown(db.close);

    final exercises = await db.select(db.exercises).get();
    expect(exercises.map((e) => e.name), ['Running', 'Squats', 'Push-ups']);
    expect(await db.select(db.sessions).get(), isEmpty);
    expect(await db.select(db.weightEntries).get(), isEmpty);
    expect(await db.select(db.scheduleRules).get(), isEmpty);
  });

  test('a fresh install seeds Running with all three goals', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final running = (await db.select(db.exercises).get())
        .firstWhere((e) => e.name == 'Running');
    expect((running.goalTotal, running.goalRunning, running.goalContinuous),
        (8.0, 5.0, 2.0));
  });
}
