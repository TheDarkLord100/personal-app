import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dates.dart';
import '../core/today_state.dart';
import '../database/tables.dart';
import '../exercises/exercises_state.dart';
import '../sessions/sessions_state.dart';
import 'widgets/log_session_sheet.dart';
import 'widgets/session_tile.dart';
import 'widgets/set_targets_sheet.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  /// Weeks away from the current one: -1 is last week, 1 is next week.
  int _weekOffset = 0;

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    final monday = addDays(today, 1 - today.weekday + 7 * _weekOffset);
    final sunday = addDays(monday, 6);
    final sessions = ref.watch(daySessionsProvider((monday, sunday)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan'),
        actions: [
          if (_weekOffset != 0)
            TextButton(
              onPressed: () => setState(() => _weekOffset = 0),
              child: const Text('This week'),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _setTargets,
        icon: const Icon(Icons.flag_outlined),
        label: const Text('Set targets'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _weekOffset--),
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous week',
              ),
              Expanded(
                child: Text(
                  '${formatShortDate(monday)} – ${formatShortDate(sunday)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _weekOffset++),
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next week',
              ),
            ],
          ),
          sessions.when(
            data: (list) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WeekSummary(list),
                for (var i = 0; i < 7; i++)
                  _DaySection(
                    day: addDays(monday, i),
                    isToday: addDays(monday, i) == today,
                    sessions: [
                      for (final ds in list)
                        if (ds.date == addDays(monday, i)) ds,
                    ],
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

  Future<void> _setTargets() async {
    final exercises = await ref.read(exercisesProvider.future);
    if (!mounted || exercises.isEmpty) return;
    await showSetTargetsSheet(context, exercises: exercises);
  }
}

/// e.g. "3 done · 1 partial · 2 upcoming". Hidden when the week is empty.
class _WeekSummary extends StatelessWidget {
  const _WeekSummary(this.sessions);

  final List<DaySession> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final order = [
      SessionStatus.overachieved,
      SessionStatus.done,
      SessionStatus.partial,
      SessionStatus.missed,
      null,
    ];
    final parts = [
      for (final status in order)
        if (sessions.where((ds) => ds.status == status).length case final n
            when n > 0)
          '$n ${statusLabel(status).toLowerCase()}',
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        parts.join(' · '),
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.day,
    required this.isToday,
    required this.sessions,
  });

  final DateTime day;
  final bool isToday;
  final List<DaySession> sessions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isToday ? '${formatShortDate(day)} · Today' : formatShortDate(day),
            style: theme.textTheme.titleSmall?.copyWith(
                color: isToday ? theme.colorScheme.secondary : null),
          ),
          const SizedBox(height: 8),
          if (sessions.isEmpty)
            Text('Rest day', style: muted)
          else
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final ds in sessions) _PlanRow(ds),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow(this.daySession);

  final DaySession daySession;

  @override
  Widget build(BuildContext context) {
    final session = daySession.session;
    final unit = daySession.exercise.unit;
    final target =
        describeAmounts(session?.targetTotal, session?.targetContinuous, unit,
            running: session?.targetRunning);
    final did =
        describeAmounts(session?.actualTotal, session?.actualContinuous, unit,
            running: session?.actualRunning);

    return ListTile(
      title: Text(daySession.scheduled
          ? daySession.exercise.name
          : '${daySession.exercise.name} · Extra'),
      subtitle: Text([
        target == null ? 'No target' : 'Target: $target',
        if (did != null) 'Did: $did',
      ].join('\n')),
      trailing: StatusChip(status: daySession.status),
      onTap: () => showLogSessionSheet(
        context,
        exercise: daySession.exercise,
        date: daySession.date,
        session: session,
      ),
    );
  }
}
