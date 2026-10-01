import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../progress/progress_state.dart';
import 'widgets/goal_progress_card.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(exerciseProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          progress.when(
            data: (list) => Column(
              children: [
                for (final (exercise, p) in list)
                  GoalProgressCard(exercise: exercise, progress: p),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Couldn\'t load progress: $e'),
          ),
        ],
      ),
    );
  }
}
