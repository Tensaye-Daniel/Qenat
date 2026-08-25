import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/qenat_colors.dart';
import '../../../tasks/domain/day_progress.dart';

class DayCell extends StatefulWidget {
  const DayCell({
    super.key,
    required this.date,
    required this.inMonth,
    this.progress,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final bool inMonth;
  final DayProgress? progress;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  State<DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<DayCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  int _lastCompleted = 0;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _lastCompleted = widget.progress?.completed ?? 0;
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DayCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nowCompleted = widget.progress?.completed ?? 0;
    if (nowCompleted > _lastCompleted &&
        !MediaQuery.disableAnimationsOf(context)) {
      _pulse.forward(from: 0);
    }
    _lastCompleted = nowCompleted;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<QenatColors>()!;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final progress = widget.progress;
    final hasTasks = progress?.hasTasks ?? false;
    final rate = hasTasks ? progress!.rate : 0.0;

    final background = !widget.inMonth
        ? Colors.transparent
        : hasTasks
            ? QenatColors.fillForRate(rate, base: colors.surfaceCard)
            : colors.stoneCell;

    final numberColor = !widget.inMonth
        ? colors.inkFaded.withValues(alpha: 0.38)
        : colors.ink;

    final microColor = hasTasks
        ? QenatColors.anchorForRate(rate)
        : colors.inkFaded.withValues(alpha: 0.55);

    final borderColor = widget.isSelected
        ? colors.ink
        : widget.isToday
            ? colors.green
            : Colors.transparent;

    final semanticsLabel = StringBuffer(
        DateFormat('MMMM d').format(widget.date));
    if (hasTasks) {
      semanticsLabel.write(
          ', ${progress!.completed} of ${progress.total} done');
    } else {
      semanticsLabel.write(', nothing planned yet');
    }
    if (widget.isToday) semanticsLabel.write(', today');

    return Semantics(
      button: true,
      label: semanticsLabel.toString(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final scale = reducedMotion
                ? 1.0
                : 1.0 + 0.06 * math.sin(math.pi * Curves.easeOut.transform(_pulse.value));
            return Transform.scale(scale: scale, child: child);
          },
          child: AnimatedContainer(
            duration:
                reducedMotion ? Duration.zero : const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: borderColor, width: 1.4),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: colors.ink.withValues(alpha: 0.16),
                        blurRadius: 9,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '${widget.date.day}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: numberColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: hasTasks
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '${progress!.completed}/${progress.total}',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                color: microColor,
                              ),
                            ),
                          )
                        : Icon(Icons.add_rounded,
                            size: 11, color: microColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
