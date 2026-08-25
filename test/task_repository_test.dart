import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qenat/core/db/database.dart';
import 'package:qenat/features/tasks/data/task_repository.dart';

void main() {
  late QenatDatabase db;
  late TaskRepository repo;

  setUp(() {
    db = QenatDatabase.connect(NativeDatabase.memory());
    repo = TaskRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('addTask stores fields and watchTasksForDay returns it', () async {
    await repo.addTask(
      title: 'Morning run',
      dateEpochDay: 1000,
      minuteOfDay: 6 * 60 + 30,
      categoryCode: 'health',
    );

    final tasks = await repo.watchTasksForDay(1000).first;
    expect(tasks, hasLength(1));
    expect(tasks.first.title, 'Morning run');
    expect(tasks.first.minuteOfDay, 390);
    expect(tasks.first.categoryCode, 'health');
    expect(tasks.first.completed, isFalse);
  });

  test('timed tasks sort before untimed tasks', () async {
    await repo.addTask(title: 'Untimed', dateEpochDay: 1000);
    await repo.addTask(
        title: 'Late', dateEpochDay: 1000, minuteOfDay: 20 * 60);
    await repo.addTask(title: 'Early', dateEpochDay: 1000, minuteOfDay: 7);

    final tasks = await repo.watchTasksForDay(1000).first;
    expect(
        tasks.map((t) => t.title).toList(), ['Early', 'Late', 'Untimed']);
  });

  test('setCompleted flips only the targeted row', () async {
    final idA = await repo.addTask(title: 'A', dateEpochDay: 1000);
    final idB = await repo.addTask(title: 'B', dateEpochDay: 1000);

    await repo.setCompleted(idA, completed: true);

    final tasks = await repo.watchTasksForDay(1000).first;
    expect(tasks.firstWhere((t) => t.id == idA).completed, isTrue);
    expect(tasks.firstWhere((t) => t.id == idB).completed, isFalse);
  });

  test('watchTasksInRange covers inclusive bounds', () async {
    await repo.addTask(title: 'before', dateEpochDay: 998);
    await repo.addTask(title: 'start', dateEpochDay: 999);
    await repo.addTask(title: 'end', dateEpochDay: 1001);
    await repo.addTask(title: 'after', dateEpochDay: 1002);

    final tasks = await repo.watchTasksInRange(999, 1001).first;
    expect(tasks.map((t) => t.title), containsAll(['start', 'end']));
    expect(tasks, hasLength(2));
  });

  test('updateTask rewrites editable fields and keeps completion', () async {
    final id = await repo.addTask(title: 'Old', dateEpochDay: 1000);
    await repo.setCompleted(id, completed: true);

    await repo.updateTask(
      id,
      TasksCompanion(
        title: const Value('New'),
        minuteOfDay: const Value(540),
        categoryCode: const Value('learning'),
      ),
    );

    final task = await (db.select(db.tasks)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    expect(task.title, 'New');
    expect(task.minuteOfDay, 540);
    expect(task.categoryCode, 'learning');
    expect(task.completed, isTrue);
  });

  test('delete then upsertFull restores the identical row', () async {
    final id = await repo.addTask(
      title: 'Precious',
      dateEpochDay: 1000,
      categoryCode: 'work',
    );
    var tasks = await repo.watchTasksForDay(1000).first;
    final row = tasks.single;

    await repo.deleteTask(id);
    tasks = await repo.watchTasksForDay(1000).first;
    expect(tasks, isEmpty);

    await repo.upsertFull(row);
    tasks = await repo.watchTasksForDay(1000).first;
    expect(tasks, hasLength(1));
    expect(tasks.single.id, id);
    expect(tasks.single.title, 'Precious');
    expect(tasks.single.categoryCode, 'work');
  });
}
