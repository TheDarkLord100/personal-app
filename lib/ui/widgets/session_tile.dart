import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../database/tables.dart';
import '../../sessions/sessions_state.dart';

String statusLabel(SessionStatus? status) => switch (status) {
  null => 'Upcoming',
  SessionStatus.missed => 'Missed',
  SessionStatus.partial => 'Partial',
  SessionStatus.done => 'Done',
  SessionStatus.overachieved => 'Overachieved',
};

IconData statusIcon(SessionStatus? status) => switch (status) {
  null => Icons.schedule,
  SessionStatus.missed => Icons.close,
  SessionStatus.partial => Icons.timelapse,
  SessionStatus.done => Icons.check,
  SessionStatus.overachieved => Icons.keyboard_double_arrow_up,
};

Color statusColor(BuildContext context, SessionStatus? status) {
  final scheme = Theme.of(context).colorScheme;
  return switch (status) {
    null => scheme.onSurfaceVariant,
    SessionStatus.missed => scheme.error,
    SessionStatus.partial => const Color(0xFFFBBF24),
    SessionStatus.done => const Color(0xFF34D399),
    SessionStatus.overachieved => scheme.primary,
  };
}

/// "6 km total, 4 km running, 1.5 km continuous", leaving out missing
/// ones; null when all are missing.
String? describeAmounts(
    double? total,
    double? continuous,
    String unit, {
      double? running,
    }) {
  final parts = [
    if (total != null) '${formatAmount(total, unit)} total',
    if (running != null) '${formatAmount(running, unit)} running',
    if (continuous != null) '${formatAmount(continuous, unit)} continuous',
  ];
  return parts.isEmpty ? null : parts.join(', ');
}

class SessionTile extends StatelessWidget {
  const SessionTile({super.key, required this.daySession, required this.onTap});

  final DaySession daySession;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = daySession.session;
    final unit = daySession.exercise.unit;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(daySession.exercise.name,
                        style: theme.textTheme.titleMedium),
                  ),
                  if (!daySession.scheduled)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text('Extra',
                          style: theme.textTheme.labelMedium
                              ?.copyWith(color: theme.colorScheme.outline)),
                    ),
                  StatusChip(status: daySession.status),
                ],
              ),
              const SizedBox(height: 12),
              _MetricRow(
                label: 'Target',
                text: describeAmounts(
                    session?.targetTotal, session?.targetContinuous, unit,
                    running: session?.targetRunning) ??
                    'Not set',
              ),
              const SizedBox(height: 4),
              _MetricRow(
                label: 'Did',
                text: describeAmounts(
                    session?.actualTotal, session?.actualContinuous, unit,
                    running: session?.actualRunning) ??
                    'Not logged',
              ),
              if (session?.note != null) ...[
                const SizedBox(height: 8),
                Text(session!.note!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final SessionStatus? status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon(status), size: 16, color: color),
          const SizedBox(width: 4),
          Text(statusLabel(status),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 56,
          child: Text(label,
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}