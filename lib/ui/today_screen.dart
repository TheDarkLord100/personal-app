import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dates.dart';
import '../core/format.dart';
import '../core/today_state.dart';
import '../database/app_database.dart';
import '../exercises/exercises_state.dart';
import '../progress/progress_state.dart';
import '../sessions/sessions_state.dart';
import '../weight/weight_state.dart';
import 'widgets/log_session_sheet.dart';
import 'widgets/session_tile.dart';
import 'widgets/weight_checkin_sheet.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final sessions = ref.watch(daySessionsProvider((today, today)));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(formatLongDate(today))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _logExtra(context, ref, today, sessions.value ?? const []),
        icon: const Icon(Icons.add),
        label: const Text('Extra workout'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          const _WeightCard(),
          const SizedBox(height: 24),
          Text('Sessions', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          sessions.when(
            data: (list) => list.isEmpty
                ? const _EmptyToday()
                : Column(
              children: [
                for (final ds in list)
                  SessionTile(
                    daySession: ds,
                    onTap: () => showLogSessionSheet(
                      context,
                      exercise: ds.exercise,
                      date: ds.date,
                      session: ds.session,
                    ),
                  ),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Couldn\'t load sessions: $e'),
          ),
        ],
      ),
    );
  }

  Future<void> _logExtra(
      BuildContext context,
      WidgetRef ref,
      DateTime today,
      List<DaySession> todays,
      ) async {
    final exercises = await ref.read(exercisesProvider.future);
    if (!context.mounted) return;

    final picked = await showModalBottomSheet<Exercise>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final e in exercises)
              ListTile(
                title: Text(e.name),
                onTap: () => Navigator.of(sheetContext).pop(e),
              ),
          ],
        ),
      ),
    );
    if (picked == null || !context.mounted) return;

    final existing = todays
        .where((ds) => ds.exercise.id == picked.id)
        .firstOrNull
        ?.session;
    await showLogSessionSheet(context,
        exercise: picked, date: today, session: existing);
  }
}

class _WeightCard extends ConsumerWidget {
  const _WeightCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final entry = ref.watch(todayWeightProvider).value;
    final latest = ref.watch(weightPointsProvider).value?.lastOrNull;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const Icon(Icons.monitor_weight_outlined),
        title: Text(entry == null ? 'Not weighed in yet' : formatKg(entry.kg)),
        subtitle: Text(latest == null
            ? 'Log your first reading to start the trend'
            : '7-day average ${formatKg(latest.average)}'),
        trailing: entry == null
            ? const Icon(Icons.add_circle_outline)
            : const Icon(Icons.edit_outlined),
        onTap: () => showWeightCheckinSheet(
          context,
          date: today,
          existing: entry,
          lastKg: latest?.kg,
        ),
      ),
    );
  }
}

class _EmptyToday extends StatelessWidget {
  const _EmptyToday();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        'Nothing scheduled today. Set up your schedule in Settings, '
            'or log an extra workout below.',
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}