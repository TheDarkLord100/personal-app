import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/database_state.dart';
import 'exercise_repository.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>(
      (ref) => ExerciseRepository(ref.watch(appDatabaseProvider)),
);

final exercisesProvider = StreamProvider<List<Exercise>>(
      (ref) => ref.watch(exerciseRepositoryProvider).watchAll(),
);