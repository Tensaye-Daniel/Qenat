import '../../../../core/models/category.dart';
import '../../../../core/db/database.dart';

class TaskView {
  const TaskView({
    required this.id,
    required this.title,
    required this.dateEpochDay,
    required this.minuteOfDay,
    required this.category,
    required this.completed,
  });

  final int id;
  final String title;
  final int dateEpochDay;
  final int? minuteOfDay;
  final QenatCategory? category;
  final bool completed;

  factory TaskView.fromTask(Task task) => TaskView(
        id: task.id,
        title: task.title,
        dateEpochDay: task.dateEpochDay,
        minuteOfDay: task.minuteOfDay,
        category: QenatCategory.fromCode(task.categoryCode),
        completed: task.completed,
      );
}
