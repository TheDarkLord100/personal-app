import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/today_state.dart';
import '../exercises/exercise_repository.dart';
import '../exercises/exercises_state.dart';
import '../sessions/session_repository.dart';
import '../sessions/sessions_state.dart';
import '../weight/weight_repository.dart';
import '../weight/weight_state.dart';
import 'csv_exporter.dart' as csv;

/// Builds export file contents. Saving them is up to the UI.
class ExportActions {
  ExportActions(this._exercises, this._sessions, this._weight, this._today);

  final ExerciseRepository _exercises;
  final SessionRepository _sessions;
  final WeightRepository _weight;
  final DateTime _today;

  Future<String> sessionsCsv() async => csv.sessionsCsv(
    await _sessions.all(),
    await _exercises.getAll(),
    _today,
  );

  Future<String> weightCsv() async => csv.weightCsv(await _weight.all());
}

final exportActionsProvider = Provider<ExportActions>(
      (ref) => ExportActions(
    ref.watch(exerciseRepositoryProvider),
    ref.watch(sessionRepositoryProvider),
    ref.watch(weightRepositoryProvider),
    ref.watch(todayProvider),
  ),
);
