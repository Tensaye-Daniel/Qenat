import 'package:flutter_test/flutter_test.dart';
import 'package:qenat/core/db/database.dart';
import 'package:qenat/features/tasks/domain/day_progress.dart';

Task _row({
  required int id,
  required int day,
  bool done = false,
  String title = 't',
}) {
  return Task(
    id: id,
    title: title,
    dateEpochDay: day,
    minuteOfDay: null,
    categoryCode: null,
    completed: done,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('DayProgress', () {
    test('empty progress has zero rate and no tasks', () {
      const p = DayProgress();
      expect(p.hasTasks, isFalse);
      expect(p.rate, 0);
    });

    test('rate is completed over total', () {
      var p = const DayProgress();
      p = p.addEntry(isDone: true);
      p = p.addEntry(isDone: true);
      p = p.addEntry(isDone: false);
      expect(p.total, 3);
      expect(p.completed, 2);
      expect(p.rate, closeTo(2 / 3, 1e-9));
    });
  });

  group('foldTasks', () {
    test('groups rows by epoch day and counts completions', () {
      final map = DayProgress.foldTasks([
        _row(id: 1, day: 100, done: true),
        _row(id: 2, day: 100, done: false),
        _row(id: 3, day: 100, done: true),
        _row(id: 4, day: 101),
      ]);

      expect(map.length, 2);
      expect(map[100]!.total, 3);
      expect(map[100]!.completed, 2);
      expect(map[100]!.rate, closeTo(2 / 3, 1e-9));
      expect(map[101]!.total, 1);
      expect(map[101]!.completed, 0);
    });

    test('empty input yields empty map', () {
      expect(DayProgress.foldTasks(const []), isEmpty);
    });
  });
}
