import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/database.dart';
import '../../../../core/models/category.dart';
import '../../../../core/theme/qenat_colors.dart';
import '../domain/task_view.dart';
import '../providers/tasks_providers.dart';

enum TaskEditorResult { saved, deleted }

Future<TaskEditorResult?> showTaskEditorDialog(
    BuildContext context, TaskView task) {
  return showDialog<TaskEditorResult>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.32),
    builder: (_) => _TaskEditorDialog(task: task),
  );
}

class _TaskEditorDialog extends ConsumerStatefulWidget {
  const _TaskEditorDialog({required this.task});

  final TaskView task;

  @override
  ConsumerState<_TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends ConsumerState<_TaskEditorDialog> {
  late final TextEditingController _title;
  TimeOfDay? _time;
  QenatCategory? _category;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task.title);
    _category = widget.task.category;
    final minute = widget.task.minuteOfDay;
    if (minute != null) {
      _time = TimeOfDay(hour: minute ~/ 60, minute: minute % 60);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    HapticFeedback.lightImpact();
    await ref.read(taskRepositoryProvider).updateTask(
          widget.task.id,
          TasksCompanion(
            title: Value(title),
            minuteOfDay: Value(_time == null
                ? null
                : _time!.hour * 60 + _time!.minute),
            categoryCode: Value(_category?.code),
          ),
        );
    if (mounted) Navigator.of(context).pop(TaskEditorResult.saved);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<QenatColors>()!;

    return AlertDialog(
      title: const Text('Edit task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _title,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _save(),
            decoration: const InputDecoration(hintText: 'Task title'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 18, color: colors.inkFaded),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _pickTime,
                child: Text(_time == null ? 'Add time' : _time!.format(context)),
              ),
              if (_time != null)
                IconButton(
                  tooltip: 'Clear time',
                  icon: const Icon(Icons.close_rounded, size: 16),
                  onPressed: () => setState(() => _time = null),
                ),
            ],
          ),
          Wrap(
            spacing: 6,
            children: [
              for (final c in QenatCategory.values)
                ChoiceChip(
                  label: Text(c.label),
                  selected: _category == c,
                  visualDensity: VisualDensity.compact,
                  avatar: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.colorForCategory(c),
                    ),
                  ),
                  onSelected: (selected) =>
                      setState(() => _category = selected ? c : null),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: colors.danger),
          onPressed: () => Navigator.of(context).pop(TaskEditorResult.deleted),
          child: const Text('Delete'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
