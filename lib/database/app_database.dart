import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../core/constants.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Exercises, ScheduleRules, Sessions, WeightEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'goal_tracker'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedGoals();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _seedGoals() async {
    await batch((b) {
      b.insertAll(exercises, [
        ExercisesCompanion.insert(
          name: 'Running',
          unit: 'km',
          goalTotal: 5,
          goalContinuous: 2,
          deadline: goalDeadline,
        ),
        ExercisesCompanion.insert(
          name: 'Squats',
          unit: 'reps',
          goalTotal: 1000,
          goalContinuous: 200,
          deadline: goalDeadline,
        ),
        ExercisesCompanion.insert(
          name: 'Push-ups',
          unit: 'reps',
          goalTotal: 200,
          goalContinuous: 50,
          deadline: goalDeadline,
        ),
      ]);
    });
  }
}