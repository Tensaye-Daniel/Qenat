import '../../../../core/db/database.dart';

class DayProgress {
  final int total;
  final int completed;

  const DayProgress({this.total = 0, this.completed = 0});

  bool get hasTasks => total > 0;

  double get rate => total == 0 ? 0 : completed / total;

  DayProgress addEntry({required bool isDone}) => DayProgress(
        total: total + 1,
        completed: completed + (isDone ? 1 : 0),
      );

  static Map<int, DayProgress> foldTasks(Iterable<Task> tasks) {
    final map = <int, DayProgress>{};
    for (final t in tasks) {
      final current = map[t.dateEpochDay] ?? const DayProgress();
      map[t.dateEpochDay] = current.addEntry(isDone: t.completed);
    }
    return map;
  }
}
