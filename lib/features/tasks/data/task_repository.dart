import 'package:drift/drift.dart';

import '../../../../core/db/database.dart';

class TaskRepository {
  TaskRepository(this._db);

  final QenatDatabase _db;

  Stream<List<Task>> watchTasksForDay(int epochDay) {
    final query = _db.select(_db.tasks)
      ..where((t) => t.dateEpochDay.equals(epochDay))
      ..orderBy([
        (t) => OrderingTerm(
            expression: t.minuteOfDay.isNull(), mode: OrderingMode.asc),
        (t) => OrderingTerm.asc(t.minuteOfDay),
        (t) => OrderingTerm.asc(t.id),
      ]);
    return query.watch();
  }

  Stream<List<Task>> watchTasksInRange(
      int startEpochDay, int endEpochDayInclusive) {
    final query = _db.select(_db.tasks)
      ..where((t) =>
          t.dateEpochDay.isBetweenValues(startEpochDay, endEpochDayInclusive));
    return query.watch();
  }

  Future<int> addTask({
    required String title,
    required int dateEpochDay,
    int? minuteOfDay,
    String? categoryCode,
  }) {
    return _db.into(_db.tasks).insert(TasksCompanion.insert(
          title: title,
          dateEpochDay: dateEpochDay,
          minuteOfDay: Value(minuteOfDay),
          categoryCode: Value(categoryCode),
        ));
  }

  Future<void> setCompleted(int id, {required bool completed}) {
    return (_db.update(_db.tasks)..where((t) => t.id.equals(id)))
        .write(TasksCompanion(completed: Value(completed)));
  }

  Future<void> updateTask(int id, TasksCompanion changes) {
    return (_db.update(_db.tasks)..where((t) => t.id.equals(id)))
        .write(changes);
  }

  Future<void> deleteTask(int id) {
    return (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
  }

  Future<void> upsertFull(Task task) {
    return _db
        .into(_db.tasks)
        .insert(task.toCompanion(true), mode: InsertMode.replace);
  }
}
