import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/dates.dart';
import '../../core/format.dart';
import '../../database/tables.dart';
import '../../progress/progress_calculator.dart';
import '../../progress/progress_state.dart';
import 'session_tile.dart';

/// Weight readings with the 7-day average, the goal line, and the weekly
/// pace needed vs recent.
class WeightProgressCard extends ConsumerWidget {
  const WeightProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final points = ref.watch(weightPointsProvider);
    final pace = ref.watch(weightPaceProvider).value;
    final muted = theme.textTheme.bodyMedium
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

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
                  child: Text('Weight', style: theme.textTheme.titleMedium),
                ),
                Text(
                  'Goal ${formatKg(weightGoalKg)} '
                      'by ${formatDayKey(goalDeadline)}',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),
            points.when(
              data: (list) => list.isEmpty
                  ? Text(
                  'Log your weight on the Today screen to see the trend.',
                  style: muted)
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 200, child: _WeightChart(list)),
                  const SizedBox(height: 12),
                  const _Legend(),
                  if (pace != null) ...[
                    const SizedBox(height: 16),
                    _PaceSummary(pace),
                  ],
                ],
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Couldn\'t load weight: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  const _WeightChart(this.points);

  final List<WeightPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final labelStyle = theme.textTheme.labelSmall
        ?.copyWith(color: scheme.onSurfaceVariant);

    // x is days since the first reading, so gaps in logging show as gaps.
    final first = points.first.date;
    double x(WeightPoint p) => daysBetween(first, p.date).toDouble();
    final span = x(points.last);

    // Keep the goal line in view.
    final values = [for (final p in points) ...[p.kg, p.average], weightGoalKg];
    final minY = (values.reduce((a, b) => a < b ? a : b) - 1).floorToDouble();
    final maxY = (values.reduce((a, b) => a > b ? a : b) + 1).ceilToDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: span < 1 ? 1 : span,
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: scheme.outlineVariant, strokeWidth: 0.5),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(formatNumber(value), style: labelStyle),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: span < 4 ? 1 : (span / 4).ceilToDouble(),
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                // dd/MM
                child: Text(
                    formatDate(addDays(first, value.round())).substring(0, 5),
                    style: labelStyle),
              ),
            ),
          ),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: weightGoalKg,
              color: statusColor(context, SessionStatus.done),
              strokeWidth: 1.5,
              dashArray: [6, 4],
            ),
          ],
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => scheme.inverseSurface,
            getTooltipItems: (spots) => [
              for (final s in spots)
                LineTooltipItem(
                  s.barIndex == 0
                      ? '${formatShortDate(addDays(first, s.x.round()))}\n'
                      '${formatKg(s.y)}'
                      : '7-day avg ${formatKg(s.y)}',
                  TextStyle(color: scheme.onInverseSurface, fontSize: 12),
                ),
            ],
          ),
        ),
        lineBarsData: [
          // Daily readings: dots only.
          LineChartBarData(
            spots: [for (final p in points) FlSpot(x(p), p.kg)],
            color: Colors.transparent,
            barWidth: 0,
            dotData: FlDotData(
              getDotPainter: (_, _, _, _) =>
                  FlDotCirclePainter(radius: 3, color: scheme.outline),
            ),
          ),
          // 7-day average: line only.
          LineChartBarData(
            spots: [for (final p in points) FlSpot(x(p), p.average)],
            color: scheme.primary,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    Widget item(Widget swatch, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [swatch, const SizedBox(width: 6), Text(label, style: style)],
    );
    Widget bar(Color color, double height, {double width = 16}) =>
        Container(width: width, height: height, color: color);
    final goalColor = statusColor(context, SessionStatus.done);

    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        item(
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
                color: theme.colorScheme.outline, shape: BoxShape.circle),
          ),
          'Daily',
        ),
        item(bar(theme.colorScheme.primary, 2.5), '7-day average'),
        item(
          // Dashed, like the goal line.
          Row(mainAxisSize: MainAxisSize.min, children: [
            bar(goalColor, 1.5, width: 6),
            const SizedBox(width: 4),
            bar(goalColor, 1.5, width: 6),
          ]),
          'Goal',
        ),
      ],
    );
  }
}

class _PaceSummary extends StatelessWidget {
  const _PaceSummary(this.pace);

  final WeightPace pace;

  /// e.g. "-0.40 kg/week" or "+0.15 kg/week".
  static String _perWeek(double v) =>
      '${v > 0 ? '+' : ''}${v.toStringAsFixed(2)} kg/week';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needed = pace.kgPerWeekNeeded;
    final recent = pace.kgPerWeekRecent;

    final verdict = _verdict(context, needed, recent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PaceRow('7-day average', formatKg(pace.currentAverage)),
        _PaceRow('Needed', needed == null ? 'Deadline passed' : _perWeek(needed)),
        _PaceRow('Recent',
            recent == null ? 'Need a week of data' : _perWeek(recent)),
        if (verdict != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(verdict.$1, size: 16, color: verdict.$3),
              const SizedBox(width: 6),
              Expanded(
                child: Text(verdict.$2,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: verdict.$3)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Icon + label + colour, or null when there isn't enough to judge.
  (IconData, String, Color)? _verdict(
      BuildContext context, double? needed, double? recent) {
    if ((pace.currentAverage - weightGoalKg).abs() < 0.5) {
      return (
      Icons.emoji_events_outlined,
      'At goal',
      statusColor(context, SessionStatus.overachieved),
      );
    }
    if (needed == null || recent == null) return null;
    // On pace: moving the right way, at least as fast as needed.
    final onPace = recent * needed > 0 && recent.abs() >= needed.abs();
    return onPace
        ? (
    Icons.check_circle_outline,
    'On pace',
    statusColor(context, SessionStatus.done),
    )
        : (
    Icons.trending_down,
    'Behind pace',
    statusColor(context, SessionStatus.partial),
    );
  }
}

class _PaceRow extends StatelessWidget {
  const _PaceRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const Spacer(),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
