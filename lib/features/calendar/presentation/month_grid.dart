import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_utils.dart';
import '../../tasks/presentation/day_detail_sheet.dart';
import '../../tasks/providers/tasks_providers.dart';
import '../providers/calendar_provider.dart';
import 'widgets/day_cell.dart';

final DateTime kAnchorMonth = DateTime(2020);
const int kAnchorPageIndex = 1200;
const int kTotalPages = 2400;

int pageIndexFor(DateTime monthStart) =>
    monthsBetween(kAnchorMonth, monthStartOf(monthStart)) + kAnchorPageIndex;

DateTime monthForPage(int page) =>
    addMonths(kAnchorMonth, page - kAnchorPageIndex);

class MonthGrid extends ConsumerWidget {
  const MonthGrid({super.key, required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final first = monthStartOf(month);
    final offset = firstWeekdayOffset(first);
    final dayCount = daysInMonth(first);
    final rows = (offset + dayCount) > 35 ? 6 : 5;
    final today = dateOnly(DateTime.now());
    final calendar = ref.watch(calendarProvider);
    final progress = ref.watch(monthProgressProvider(first)).value;

    return LayoutBuilder(builder: (context, constraints) {
      const spacing = 4.0;
      final cellW = (constraints.maxWidth - 6 * spacing) / 7;
      final cellH =
          (constraints.maxHeight - (rows - 1) * spacing) / rows;

      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: cellW / cellH,
        ),
        itemCount: offset + dayCount,
        itemBuilder: (context, index) {
          if (index < offset) return const SizedBox.shrink();
          final day = index - offset + 1;
          final date = DateTime(first.year, first.month, day);
          final epoch = epochDayOf(date);

          return DayCell(
            key: ValueKey('cell-$epoch'),
            date: date,
            inMonth: true,
            progress: progress?[epoch],
            isSelected: calendar.selectedDate == date,
            isToday: today == date,
            onTap: () => _openDay(context, ref, date),
          );
        },
      );
    });
  }

  void _openDay(BuildContext context, WidgetRef ref, DateTime date) {
    ref.read(calendarProvider.notifier).select(date);
    showDayDetailSheet(context, date);
  }
}

