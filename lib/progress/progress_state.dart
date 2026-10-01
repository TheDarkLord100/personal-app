import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../core/dates.dart';
import '../core/today_state.dart';
import '../database/app_database.dart';
import '../exercises/exercises_state.dart';
import '../sessions/sessions_state.dart';
import '../weight/weight_state.dart';
import 'progress_calculator.dart';

final exerciseProgressProvider =
FutureProvider<List<(Exercise, ExerciseProgress)>>((ref) async {
  final exercisesFuture = ref.watch(exercisesProvider.future);
  final sessionsFuture = ref.watch(allSessionsProvider.future);
  final today = ref.watch(todayProvider);

  final sessions = await sessionsFuture;
  return [
    for (final e in await exercisesFuture) (e, progressFor(e, sessions, today)),
  ];
});

final weightPointsProvider = FutureProvider<List<WeightPoint>>((ref) async {
  final historyFuture = ref.watch(weightHistoryProvider.future);
  return withMovingAverage(await historyFuture);
});

final weightPaceProvider = FutureProvider<WeightPace?>((ref) async {
  final pointsFuture = ref.watch(weightPointsProvider.future);
  final today = ref.watch(todayProvider);
  return weightPace(
    await pointsFuture,
    deadline: parseDay(goalDeadline),
    today: today,
  );
});