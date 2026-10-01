import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/format.dart';
import '../../database/app_database.dart';
import '../../database/tables.dart';
import '../../progress/progress_calculator.dart';
import 'session_tile.dart';

/// One exercise's goal: best so far against the goal, for total and
/// continuous, and whether each is on track.
class GoalProgressCard extends StatelessWidget {
  const GoalProgressCard({
    super.key,
    required this.exercise,
    required this.progress,
  });

  final Exercise exercise;
  final ExerciseProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final running = progress.running;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(exercise.name, style: theme.textTheme.titleMedium),
                ),
                Text('by ${formatDayKey(exercise.deadline)}',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 16),
            _MetricProgressRow(
                label: running == null ? 'Total' : 'Total (walk + run)',
                metric: progress.total,
                unit: exercise.unit),
            if (running != null) ...[
              const SizedBox(height: 16),
              _MetricProgressRow(
                  label: 'Running', metric: running, unit: exercise.unit),
            ],
            const SizedBox(height: 16),
            _MetricProgressRow(
                label: 'Continuous',
                metric: progress.continuous,
                unit: exercise.unit),
          ],
        ),
      ),
    );
  }
}

class _MetricProgressRow extends StatelessWidget {
  const _MetricProgressRow({
    required this.label,
    required this.metric,
    required this.unit,
  });

  final String label;
  final MetricProgress metric;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final best = metric.best == null ? '–' : formatNumber(metric.best!);
    final percent = (metric.fraction * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(label, style: theme.textTheme.labelLarge),
            const Spacer(),
            Text('$best / ${formatAmount(metric.goal, unit)} · $percent%',
                style: theme.textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: metric.fraction,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        _TrackLabel(metric: metric, unit: unit),
      ],
    );
  }
}

/// Icon + label, so the verdict never relies on colour alone.
class _TrackLabel extends StatelessWidget {
  const _TrackLabel({required this.metric, required this.unit});

  final MetricProgress metric;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (IconData icon, String text, Color color) = switch (metric.onTrack) {
      null => (
      Icons.info_outline,
      'Log a session to start tracking',
      theme.colorScheme.onSurfaceVariant,
      ),
      true when metric.fraction >= 1 => (
      Icons.emoji_events_outlined,
      'Goal reached',
      statusColor(context, SessionStatus.overachieved),
      ),
      true => (
      Icons.check_circle_outline,
      'On track',
      statusColor(context, SessionStatus.done),
      ),
      false => (
      Icons.trending_down,
      'Behind, expected '
          '${formatAmount(metric.expectedToday!, unit)} by today',
      statusColor(context, SessionStatus.partial),
      ),
    };

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: theme.textTheme.bodySmall?.copyWith(color: color)),
        ),
      ],
    );
  }
}
