import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dates.dart';
import '../core/today_state.dart';
import '../database/app_database.dart';
import '../database/database_state.dart';
import 'weight_repository.dart';

final weightRepositoryProvider = Provider<WeightRepository>(
      (ref) => WeightRepository(ref.watch(appDatabaseProvider)),
);

final weightHistoryProvider = StreamProvider<List<WeightEntry>>(
      (ref) => ref.watch(weightRepositoryProvider).watchAll(),
);

/// Today's weigh-in, or null if not done yet.
final todayWeightProvider = FutureProvider<WeightEntry?>((ref) async {
  final historyFuture = ref.watch(weightHistoryProvider.future);
  final key = dayKey(ref.watch(todayProvider));
  for (final entry in (await historyFuture).reversed) {
    if (entry.date == key) return entry;
    if (entry.date.compareTo(key) < 0) break;
  }
  return null;
});