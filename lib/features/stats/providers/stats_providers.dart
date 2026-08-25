import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_utils.dart';
import '../logic/streak_calculator.dart';
import '../../tasks/domain/day_progress.dart';
import '../../tasks/providers/tasks_providers.dart';

class StatsSummary {
  final int currentStreak;
  final int bestStreak;
  final double average7;
  final double average30;
  final int plannedDays7;
  final int plannedDays30;

  const StatsSummary({
    required this.currentStreak,
    required this.bestStreak,
    required this.average7,
    required this.average30,
    required this.plannedDays7,
    required this.plannedDays30,
  });
}

double _averagePlanned(
    Map<int, DayProgress> progress, int fromDay, int toDay) {
  var sum = 0.0;
  var count = 0;
  for (var d = fromDay; d <= toDay; d++) {
    final p = progress[d];
    if (p != null && p.hasTasks) {
      sum += p.rate;
      count++;
    }
  }
  return count == 0 ? 0 : sum / count;
}

int _plannedCount(Map<int, DayProgress> progress, int fromDay, int toDay) {
  var count = 0;
  for (var d = fromDay; d <= toDay; d++) {
    if (progress[d]?.hasTasks ?? false) count++;
  }
  return count;
}

final statsSummaryProvider = Provider<StatsSummary?>((ref) {
  final progressAsync = ref.watch(recentProgressProvider);
  return progressAsync.whenOrNull(data: (progress) {
    final today = epochDayOf(DateTime.now());
    final rates = <int, double>{
      for (final e in progress.entries)
        if (e.value.hasTasks) e.key: e.value.rate,
    };
    final streaks = StreakCalculator.compute(rates, todayEpoch: today);
    return StatsSummary(
      currentStreak: streaks.current,
      bestStreak: streaks.best,
      average7: _averagePlanned(progress, today - 6, today),
      average30: _averagePlanned(progress, today - 29, today),
      plannedDays7: _plannedCount(progress, today - 6, today),
      plannedDays30: _plannedCount(progress, today - 29, today),
    );
  });
});

final chartWindowProvider = Provider<List<int>>((ref) {
  final today = epochDayOf(DateTime.now());
  return List.generate(30, (i) => today - 29 + i);
});
