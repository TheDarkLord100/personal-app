import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/today_state.dart';
import '../database/database_state.dart';
import '../exercises/exercise_repository.dart';
import '../exercises/exercises_state.dart';
import '../sessions/session_repository.dart';
import '../sessions/sessions_state.dart';
import '../weight/weight_repository.dart';
import '../weight/weight_state.dart';
import 'backup_service.dart';
import 'csv_exporter.dart' as csv;

final backupServiceProvider = Provider<BackupService>(
      (ref) => BackupService(ref.watch(appDatabaseProvider)),
);

/// Builds export file contents and restores backups. Saving and picking
/// files is up to the UI.
class ExportActions {
  ExportActions(
      this._exercises, this._sessions, this._weight, this._backup, this._today);

  final ExerciseRepository _exercises;
  final SessionRepository _sessions;
  final WeightRepository _weight;
  final BackupService _backup;
  final DateTime _today;

  Future<String> backupJson() => _backup.exportJson(now: DateTime.now());

  /// Throws [FormatException] with a readable message for a bad file.
  BackupData readBackup(String text) => _backup.parse(text);

  /// Replaces all data. Streams update the UI on their own afterwards.
  Future<void> restore(BackupData data) => _backup.restore(data);

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
    ref.watch(backupServiceProvider),
    ref.watch(todayProvider),
  ),
);
