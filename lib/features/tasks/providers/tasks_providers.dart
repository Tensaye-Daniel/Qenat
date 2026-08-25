import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/database.dart';
import '../../../../core/utils/date_utils.dart';
import '../data/task_repository.dart';
import '../domain/day_progress.dart';

final qenatDatabaseProvider = Provider<QenatDatabase>((ref) {
  final db = QenatDatabase();
  ref.onDispose(db.close);
  return db;
});

final taskRepositoryProvider =
    Provider<TaskRepository>((ref) => TaskRepository(ref.watch(qenatDatabaseProvider)));

final dayTasksProvider =
    StreamProvider.autoDispose.family<List<Task>, int>((ref, epochDay) {
  return ref.watch(taskRepositoryProvider).watchTasksForDay(epochDay);
});

final monthProgressProvider = StreamProvider.autoDispose
    .family<Map<int, DayProgress>, DateTime>((ref, month) {
  final first = monthStartOf(month);
  final start = epochDayOf(first);
  final end = start + daysInMonth(first) - 1;
  return ref
      .watch(taskRepositoryProvider)
      .watchTasksInRange(start, end)
      .map(DayProgress.foldTasks);
});

final recentProgressProvider =
    StreamProvider<Map<int, DayProgress>>((ref) {
  final today = epochDayOf(DateTime.now());
  return ref
      .watch(taskRepositoryProvider)
      .watchTasksInRange(today - 29, today)
      .map(DayProgress.foldTasks);
});
