import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_utils.dart';

class CalendarState {
  final DateTime focusedMonth;
  final DateTime selectedDate;

  const CalendarState({required this.focusedMonth, required this.selectedDate});

  @override
  bool operator ==(Object other) =>
      other is CalendarState &&
      other.focusedMonth == focusedMonth &&
      other.selectedDate == selectedDate;

  @override
  int get hashCode => Object.hash(focusedMonth, selectedDate);
}

class CalendarNotifier extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    final now = dateOnly(DateTime.now());
    return CalendarState(focusedMonth: monthStartOf(now), selectedDate: now);
  }

  void select(DateTime date) {
    state = CalendarState(
        focusedMonth: state.focusedMonth, selectedDate: dateOnly(date));
  }

  void setFocusedMonth(DateTime month) {
    state = CalendarState(
        focusedMonth: monthStartOf(month), selectedDate: state.selectedDate);
  }

  void jumpToToday() {
    final now = dateOnly(DateTime.now());
    state = CalendarState(
        focusedMonth: monthStartOf(now), selectedDate: now);
  }
}

final calendarProvider =
    NotifierProvider<CalendarNotifier, CalendarState>(CalendarNotifier.new);
