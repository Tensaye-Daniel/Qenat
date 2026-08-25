import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/qenat_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/task_view.dart';
import 'animated_check.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final TaskView task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<QenatColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Dismissible(
      key: ValueKey('task-${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: colors.clay.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline_rounded, color: colors.clay),
      ),
      onDismissed: (_) {
        HapticFeedback.lightImpact();
        onDelete();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Material(
          color: colors.surfaceField,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onEdit,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  AnimatedCheck(value: task.completed, onChanged: onToggle),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : const Duration(milliseconds: 250),
                          style: (textTheme.bodyMedium ?? const TextStyle())
                              .copyWith(
                            fontWeight: FontWeight.w500,
                            color: task.completed
                                ? colors.inkFaded
                                : colors.ink,
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: colors.inkFaded,
                          ),
                          child: Text(task.title, maxLines: 3, overflow: TextOverflow.ellipsis),
                        ),
                        if (task.category != null || task.minuteOfDay != null)
                          const SizedBox(height: 4),
                        if (task.category != null || task.minuteOfDay != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (task.category != null) ...[
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colors
                                        .colorForCategory(task.category!),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  task.category!.label,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colors.inkFaded,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              if (task.category != null &&
                                  task.minuteOfDay != null)
                                const SizedBox(width: 12),
                              if (task.minuteOfDay != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.schedule_rounded,
                                        size: 13, color: colors.inkFaded),
                                    const SizedBox(width: 4),
                                    Text(
                                      formatMinuteOfDay(task.minuteOfDay!),
                                      style: textTheme.bodySmall
                                          ?.copyWith(color: colors.inkFaded),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
