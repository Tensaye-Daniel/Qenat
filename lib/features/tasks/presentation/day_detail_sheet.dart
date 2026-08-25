import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/db/database.dart';
import '../../../../core/models/category.dart';
import '../../../../core/theme/qenat_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/qenat_logo.dart';
import '../domain/task_view.dart';
import '../providers/tasks_providers.dart';
import 'task_editor_dialog.dart';
import 'widgets/task_tile.dart';

Future<void> showDayDetailSheet(BuildContext context, DateTime date) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.32),
    builder: (_) => _DayDetailSheet(date: dateOnly(date)),
  );
}

class _DayDetailSheet extends ConsumerStatefulWidget {
  const _DayDetailSheet({required this.date});

  final DateTime date;

  @override
  ConsumerState<_DayDetailSheet> createState() => _DayDetailSheetState();
}

class _DayDetailSheetState extends ConsumerState<_DayDetailSheet> {
  final TextEditingController _titleController = TextEditingController();
  TimeOfDay? _time;
  QenatCategory? _category;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    HapticFeedback.lightImpact();
    await ref.read(taskRepositoryProvider).addTask(
          title: title,
          dateEpochDay: epochDayOf(widget.date),
          minuteOfDay:
              _time == null ? null : _time!.hour * 60 + _time!.minute,
          categoryCode: _category?.code,
        );
    if (!mounted) return;
    setState(() {
      _titleController.clear();
      _time = null;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _deleteWithUndo(Task row) {
    final repo = ref.read(taskRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    HapticFeedback.lightImpact();
    repo.deleteTask(row.id);
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => repo.upsertFull(row),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<QenatColors>()!;
    final epoch = epochDayOf(widget.date);
    final tasksAsync = ref.watch(dayTasksProvider(epoch));
    final rows = tasksAsync.value ?? const <Task>[];
    final hasTasks = rows.isNotEmpty;
    final completedCount = rows.where((t) => t.completed).length;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        maxChildSize: 0.94,
        minChildSize: 0.45,
        builder: (context, scrollController) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(26)),
                  boxShadow: [
                    BoxShadow(
                      color: colors.ink.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.outlineWarm,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('EEEE')
                                      .format(widget.date)
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2,
                                    color: colors.inkFaded,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('MMMM d').format(widget.date),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(color: colors.ink),
                                ),
                              ],
                            ),
                          ),
                          CompletionRing(
                            rate: hasTasks ? completedCount / rows.length : null,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(colors: [
                            colors.clay.withValues(alpha: 0.30),
                            colors.amber.withValues(alpha: 0.30),
                            colors.green.withValues(alpha: 0.30),
                          ]),
                        ),
                      ),
                    ),
                    _buildAddBar(context, colors),
                    Expanded(
                      child: !hasTasks
                          ? const _EmptyState()
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                              itemCount: rows.length,
                              itemBuilder: (context, index) {
                                final row = rows[index];
                                final view = TaskView.fromTask(row);
                                return TaskTile(
                                  task: view,
                                  onToggle: () {
                                    if (!row.completed) {
                                      HapticFeedback.mediumImpact();
                                    }
                                    ref
                                        .read(taskRepositoryProvider)
                                        .setCompleted(
                                            row.id, completed: !row.completed);
                                  },
                                  onEdit: () async {
                                    final result =
                                        await showTaskEditorDialog(context, view);
                                    if (result == TaskEditorResult.deleted) {
                                      _deleteWithUndo(row);
                                    }
                                  },
                                  onDelete: () => _deleteWithUndo(row),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddBar(BuildContext context, QenatColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _submit(),
                  decoration:
                      const InputDecoration(hintText: 'Add a task…'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                tooltip: 'Pick a time',
                onPressed: _pickTime,
                icon: Icon(
                  Icons.schedule_rounded,
                  size: 20,
                  color: _time == null ? colors.inkFaded : colors.green,
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                tooltip: 'Add task',
                onPressed: _submit,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                if (_time != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InputChip(
                      visualDensity: VisualDensity.compact,
                      avatar: Icon(Icons.schedule_rounded,
                          size: 14, color: colors.green),
                      label: Text(formatMinuteOfDay(
                          _time!.hour * 60 + _time!.minute)),
                      onDeleted: () => setState(() => _time = null),
                    ),
                  ),
                ChoiceChip(
                  visualDensity: VisualDensity.compact,
                  label: const Text('No category'),
                  selected: _category == null,
                  onSelected: (_) => setState(() => _category = null),
                ),
                for (final c in QenatCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ChoiceChip(
                      visualDensity: VisualDensity.compact,
                      label: Text(c.label),
                      selected: _category == c,
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
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CompletionRing extends StatefulWidget {
  const CompletionRing({super.key, required this.rate});

  final double? rate;

  @override
  State<CompletionRing> createState() => _CompletionRingState();
}

class _CompletionRingState extends State<CompletionRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _tween;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _tween = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<QenatColors>()!;
    final targetRate = widget.rate;
    final progressColor = targetRate == null
        ? colors.stoneCell
        : QenatColors.anchorForRate(targetRate);

    return AnimatedBuilder(
      animation: _tween,
      builder: (context, _) {
        final currentRate = targetRate != null ? targetRate * _tween.value : null;
        return SizedBox(
          width: 48,
          height: 48,
          child: CustomPaint(
            painter: _RingPainter(
              trackColor: colors.outlineWarm.withValues(alpha: 0.7),
              progressColor: progressColor,
              rate: currentRate,
            ),
            child: Center(
              child: Text(
                targetRate == null ? '–' : '${(targetRate * 100).round()}%',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: colors.ink,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.trackColor,
    required this.progressColor,
    required this.rate,
  });

  final Color trackColor;
  final Color progressColor;
  final double? rate;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 3.6;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2,
        size.width - stroke, size.height - stroke);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = trackColor;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    final value = rate;
    if (value == null || value <= 0) return;
    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = progressColor;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * value.clamp(0.0, 1.0),
        false, progress);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.rate != rate ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<QenatColors>()!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const QenatLogo(size: 44, showName: false),
          const SizedBox(height: 14),
          Text(
            'Nothing planned yet',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: colors.ink),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Add your first task above — small steps keep the rhythm.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colors.inkFaded),
            ),
          ),
        ],
      ),
    );
  }
}
