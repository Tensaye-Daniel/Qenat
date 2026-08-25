import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qenat/core/utils/date_utils.dart';
import 'package:qenat/features/stats/providers/stats_providers.dart';
import 'package:qenat/features/tasks/domain/day_progress.dart';
import 'package:qenat/features/tasks/providers/tasks_providers.dart';

void main() {
  test('statsSummaryProvider derives streaks and averages', () async {
    final today = epochDayOf(DateTime.now());
    Map<int, DayProgress> progressOf(Map<int, (int, int)> totals) => {
          for (final e in totals.entries)
            e.key:
                DayProgress(total: e.value.$1, completed: e.value.$2),
        };

    final container = ProviderContainer(
      overrides: [
        recentProgressProvider.overrideWith((ref) {
          return Stream.value(progressOf({
            today: (2, 2),
            today - 1: (4, 4),
            today - 2: (5, 4),
            today - 3: (2, 0),
            today - 7: (1, 1),
            500: (10, 10),
            501: (10, 10),
            502: (10, 10),
          }));
        }),
      ],
    );
    addTearDown(container.dispose);

    await container.read(recentProgressProvider.future);
    final summary = container.read(statsSummaryProvider);

    expect(summary, isNotNull);
    expect(summary!.currentStreak, 3);
    expect(summary.bestStreak, 3);
    expect(summary.plannedDays30, 5);
    expect(summary.plannedDays7, 4);
    expect(summary.average30, closeTo((1 + 1 + 0.8 + 0 + 1) / 5, 1e-9));
    expect(summary.average7, closeTo((1 + 1 + 0.8 + 0) / 4, 1e-9));
  });

  test('chartWindowProvider returns the trailing 30-day window',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final days = container.read(chartWindowProvider);
    expect(days, hasLength(30));
    expect(days.last - days.first, 29);
  });
}
