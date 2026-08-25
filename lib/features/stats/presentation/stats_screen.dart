import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/qenat_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../providers/stats_providers.dart';
import '../../tasks/domain/day_progress.dart';
import '../../tasks/providers/tasks_providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<QenatColors>()!;
    final progressAsync = ref.watch(recentProgressProvider);
    final chartDays = ref.watch(chartWindowProvider);
    final summary = ref.watch(statsSummaryProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
      children: [
        Text('Insights',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: colors.ink)),
        const SizedBox(height: 2),
        Text('How your days weave together.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: colors.inkFaded)),
        const SizedBox(height: 18),
        if (summary == null)
          _buildSkeleton(colors)
        else if (summary.plannedDays30 == 0 && summary.currentStreak == 0)
          _buildEmptyState(context, colors)
        else
          Column(children: [
            Row(
              children: [
                Expanded(
                  child: _StreakCard(
                    value: summary.currentStreak,
                    caption: 'CURRENT STREAK',
                    sublabel: summary.currentStreak == 1
                        ? 'day in a row'
                        : 'days in a row',
                    accent: colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StreakCard(
                    value: summary.bestStreak,
                    caption: 'BEST RUN',
                    sublabel: summary.bestStreak == 1
                        ? 'day in a row'
                        : 'days in a row',
                    accent: colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _AverageBar(
                label: 'LAST 7 DAYS',
                rate: summary.average7,
                plannedDays: summary.plannedDays7,
                colors: colors),
            const SizedBox(height: 10),
            _AverageBar(
                label: 'LAST 30 DAYS',
                rate: summary.average30,
                plannedDays: summary.plannedDays30,
                colors: colors),
          ]),
        const SizedBox(height: 16),
        progressAsync.when(
          loading: () => _buildChartSkeleton(colors),
          error: (e, _) => _buildChartSkeleton(colors),
          data: (progress) {
            if (progress.isEmpty) return _buildChartSkeleton(colors);
            return _MonthlyChart(
                progress: progress, days: chartDays, colors: colors);
          },
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Icon(Icons.info_outline_rounded,
                size: 15, color: colors.inkFaded),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'A day joins a streak at ${(QenatColors.streakThreshold * 100).round()}% completion. Averages count planned days only.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: colors.inkFaded),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeleton(QenatColors colors) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _SkeletonCard(height: 110, colors: colors)),
            const SizedBox(width: 12),
            Expanded(child: _SkeletonCard(height: 110, colors: colors)),
          ],
        ),
        const SizedBox(height: 12),
        _SkeletonCard(height: 80, colors: colors),
        const SizedBox(height: 10),
        _SkeletonCard(height: 80, colors: colors),
      ],
    );
  }

  Widget _buildChartSkeleton(QenatColors colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 10),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineWarm.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 200,
            height: 12,
            decoration: BoxDecoration(
              color: colors.stoneCell.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                30,
                (i) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Container(
                      height: (20 + (i * 3.7) % 80),
                      decoration: BoxDecoration(
                        color: colors.stoneCell.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, QenatColors colors) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineWarm.withValues(alpha: 0.7)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.stoneCell.withValues(alpha: 0.55),
            ),
            child: Icon(Icons.insights_rounded, size: 30, color: colors.green),
          ),
          const SizedBox(height: 16),
          Text(
            'No insights yet',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: colors.ink),
          ),
          const SizedBox(height: 6),
          Text(
            'Add and complete some tasks to see your patterns emerge.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: colors.inkFaded),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard({required this.height, required this.colors});

  final double height;
  final QenatColors colors;

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.colors.surfaceCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: widget.colors.outlineWarm.withValues(alpha: 0.7)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(color: widget.colors.stoneCell.withValues(alpha: 0.3)),
                ),
                Positioned(
                  left: -100 + (_shimmer.value * 400),
                  top: 0,
                  bottom: 0,
                  width: 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.colors.surfaceCard.withValues(alpha: 0.0),
                          widget.colors.surfaceCard.withValues(alpha: 0.5),
                          widget.colors.surfaceCard.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.value,
    required this.caption,
    required this.sublabel,
    required this.accent,
  });

  final int value;
  final String caption;
  final String sublabel;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<QenatColors>()!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineWarm.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(caption,
              style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: accent)),
          const SizedBox(height: 8),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Text('$v',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(color: colors.ink)),
          ),
          Text(sublabel,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colors.inkFaded)),
        ],
      ),
    );
  }
}

class _AverageBar extends StatelessWidget {
  const _AverageBar({
    required this.label,
    required this.rate,
    required this.plannedDays,
    required this.colors,
  });

  final String label;
  final double rate;
  final int plannedDays;
  final QenatColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineWarm.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: colors.inkFaded)),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: rate),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => Text(
                  '${(v * 100).round()}%',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: plannedDays == 0
                        ? colors.inkFaded
                        : QenatColors.anchorForRate(v),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 9,
              child: Stack(
                children: [
                  Container(color: colors.stoneCell.withValues(alpha: 0.5)),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: rate.clamp(0.0, 1.0)),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => FractionallySizedBox(
                      widthFactor: v,
                      child: Container(
                          color: plannedDays == 0
                              ? colors.stoneCell
                              : QenatColors.fillForRate(rate,
                                  base: colors.surfaceCard)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text('$plannedDays planned day${plannedDays == 1 ? '' : 's'}',
              style: TextStyle(
                  fontSize: 11,
                  color: colors.inkFaded.withValues(alpha: 0.85))),
        ],
      ),
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart({
    required this.progress,
    required this.days,
    required this.colors,
  });

  final Map<int, DayProgress> progress;
  final List<int> days;
  final QenatColors colors;

  @override
  Widget build(BuildContext context) {
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < days.length; i++) {
      final p = progress[days[i]];
      final hasTasks = p?.hasTasks ?? false;
      final rate = hasTasks ? p!.rate : 0.0;
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: hasTasks ? (rate * 100).clamp(4, 100).toDouble() : 3,
              width: 9,
              borderRadius: BorderRadius.circular(4),
              color: hasTasks
                  ? QenatColors.anchorForRate(rate)
                  : colors.outlineWarm.withValues(alpha: 0.55),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 10),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineWarm.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text('DAILY COMPLETION — LAST 30 DAYS',
                style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: colors.inkFaded)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: 100,
                alignment: BarChartAlignment.spaceBetween,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => colors.ink,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = dateFromEpochDay(days[groupIndex]);
                      final p = progress[epochDayOf(day)];
                      final pct =
                          (p != null && p.hasTasks) ? (p.rate * 100).round() : 0;
                      return BarTooltipItem(
                        '${shortDayTitle(day)} · $pct%',
                        const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        space: 6,
                        child: Text(
                          '${dateFromEpochDay(days[value.toInt()]).day}',
                          style:
                              TextStyle(fontSize: 10, color: colors.inkFaded),
                        ),
                      ),
                    ),
                  ),
                ),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: colors.outlineWarm.withValues(alpha: 0.45),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: groups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
