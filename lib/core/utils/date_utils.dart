import 'package:intl/intl.dart';

int epochDayOf(DateTime d) {
  final utc = DateTime.utc(d.year, d.month, d.day);
  return utc.difference(DateTime.utc(1970)).inDays;
}

DateTime dateFromEpochDay(int epochDay) =>
    DateTime.utc(1970).add(Duration(days: epochDay));

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime monthStartOf(DateTime d) => DateTime(d.year, d.month);

DateTime addMonths(DateTime month, int count) =>
    DateTime(month.year, month.month + count);

int monthsBetween(DateTime from, DateTime to) =>
    (to.year - from.year) * 12 + to.month - from.month;

int daysInMonth(DateTime month) =>
    DateTime(month.year, month.month + 1, 0).day;

int firstWeekdayOffset(DateTime month) =>
    DateTime(month.year, month.month, 1).weekday - DateTime.monday;

String monthTitle(DateTime month) => DateFormat('MMMM yyyy').format(month);

String fullDayTitle(DateTime d) => DateFormat('EEEE, MMMM d').format(d);

String shortDayTitle(DateTime d) => DateFormat('MMM d').format(d);

String formatMinuteOfDay(int minute) {
  final h = minute ~/ 60;
  final m = minute % 60;
  final suffix = h >= 12 ? 'PM' : 'AM';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${m.toString().padLeft(2, '0')} $suffix';
}
