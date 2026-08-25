import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/qenat_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../providers/calendar_provider.dart';
import 'month_grid.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: kAnchorPageIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncPage(CalendarState next) {
    if (!_controller.hasClients) return;
    final target = pageIndexFor(next.focusedMonth);
    final current = _controller.page?.round() ?? target;
    if (current == target) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(target);
    } else {
      _controller.animateToPage(
        target,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<QenatColors>()!;
    final state = ref.watch(calendarProvider);
    ref.listen(calendarProvider, (prev, next) {
      if (prev != null && prev.focusedMonth != next.focusedMonth) {
        _syncPage(next);
      }
    });

    final currentMonth = monthStartOf(DateTime.now());
    final isCurrentMonth = state.focusedMonth == currentMonth;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monthTitle(state.focusedMonth),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: colors.ink),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Plan the day. Keep the rhythm.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: colors.inkFaded),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  child: isCurrentMonth
                      ? const SizedBox.shrink()
                      : Padding(
                          key: const ValueKey('today-button'),
                          padding: const EdgeInsets.only(right: 4),
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                ref.read(calendarProvider.notifier).jumpToToday(),
                            icon: const Icon(Icons.today_rounded, size: 16),
                            label: const Text('Today'),
                          ),
                        ),
                ),
                IconButton(
                  tooltip: 'Previous month',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref
                        .read(calendarProvider.notifier)
                        .setFocusedMonth(addMonths(state.focusedMonth, -1));
                  },
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                IconButton(
                  tooltip: 'Next month',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref
                        .read(calendarProvider.notifier)
                        .setFocusedMonth(addMonths(state.focusedMonth, 1));
                  },
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                for (final letter in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                  Expanded(
                    child: Center(
                      child: Text(
                        letter,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                              color: colors.inkFaded,
                              letterSpacing: 1.2,
                              fontSize: 11,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: PageView.builder(
                  controller: _controller,
                  itemCount: kTotalPages,
                  onPageChanged: (page) => ref
                      .read(calendarProvider.notifier)
                      .setFocusedMonth(monthForPage(page)),
                  itemBuilder: (context, page) =>
                      MonthGrid(month: monthForPage(page)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
      );
  }
}
