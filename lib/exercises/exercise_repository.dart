import 'package:drift/drift.dart';

import '../core/dates.dart';
import '../database/app_database.dart';

class ExerciseRepository {
  ExerciseRepository(this._db);

  final AppDatabase _db;

  Stream<List<Exercise>> watchAll() {
    final query = _db.select(_db.exercises)
      ..orderBy([(e) => OrderingTerm.asc(e.id)]);
    return query.watch();
  }

  Future<List<Exercise>> getAll() {
    final query = _db.select(_db.exercises)
      ..orderBy([(e) => OrderingTerm.asc(e.id)]);
    return query.get();
  }

  Future<int> add({
    required String name,
    required String unit,
    required double goalTotal,
    required double goalContinuous,
    required DateTime deadline,
  }) =>
      _db.into(_db.exercises).insert(
        ExercisesCompanion.insert(
          name: name,
          unit: unit,
          goalTotal: goalTotal,
          goalContinuous: goalContinuous,
          deadline: dayKey(deadline),
        ),
      );

  /// Updates only the fields you pass; the rest stay as they are.
  Future<void> updateGoal(
      int id, {
        double? goalTotal,
        double? goalContinuous,
        DateTime? deadline,
      }) =>
      (_db.update(_db.exercises)..where((e) => e.id.equals(id))).write(
        ExercisesCompanion(
          goalTotal: Value.absentIfNull(goalTotal),
          goalContinuous: Value.absentIfNull(goalContinuous),
          deadline: Value.absentIfNull(
              deadline == null ? null : dayKey(deadline)),
        ),
      );
}