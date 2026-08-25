import 'package:flutter/material.dart';

import '../../../../core/theme/qenat_colors.dart';

class AnimatedCheck extends StatefulWidget {
  const AnimatedCheck({super.key, required this.value, required this.onChanged});

  final bool value;
  final VoidCallback onChanged;

  @override
  State<AnimatedCheck> createState() => _AnimatedCheckState();
}

class _AnimatedCheckState extends State<AnimatedCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.value ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedCheck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.duration = Duration.zero;
    }
    widget.value ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<QenatColors>()!;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      checked: widget.value,
      label: widget.value ? 'Mark as not done' : 'Mark as done',
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onChanged,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: AnimatedContainer(
            duration:
                reducedMotion ? Duration.zero : const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.value ? colors.green : Colors.transparent,
              border: Border.all(
                width: 1.6,
                color: widget.value
                    ? colors.green
                    : colors.inkFaded.withValues(alpha: 0.7),
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t =
                    CurvedAnimation(parent: _controller, curve: Curves.easeOutBack)
                        .value;
                return Transform.scale(
                  scale: 0.4 + 0.6 * t,
                  child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
                );
              },
              child: Icon(Icons.check_rounded,
                  size: 17, color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
