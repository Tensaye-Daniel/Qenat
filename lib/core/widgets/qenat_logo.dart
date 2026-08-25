import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/qenat_colors.dart';

class QenatLogo extends StatelessWidget {
  const QenatLogo({super.key, this.size = 36, this.showName = true});

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<QenatColors>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: _LogoPainter(
            green: colors.green,
            amber: colors.amber,
            clay: colors.clay,
          ),
        ),
        if (showName) ...[
          const SizedBox(width: 10),
          Text(
            'Qenat',
            style: GoogleFonts.fraunces(
              fontSize: size * 0.62,
              fontWeight: FontWeight.w700,
              color: colors.ink,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter({
    required this.green,
    required this.amber,
    required this.clay,
  });

  final Color green;
  final Color amber;
  final Color clay;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final bgPaint = Paint()..color = green;
    canvas.drawCircle(center, r, bgPaint);

    final arcRect = Rect.fromCircle(center: center, radius: r * 0.58);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.14
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFDF9EE);
    canvas.drawArc(arcRect, -math.pi * 0.7, math.pi * 1.1, false, arcPaint);

    final tailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.12
      ..strokeCap = StrokeCap.round
      ..color = amber;
    final tailStart = Offset(
      center.dx + r * 0.38,
      center.dy + r * 0.18,
    );
    final tailEnd = Offset(
      center.dx + r * 0.72,
      center.dy + r * 0.52,
    );
    canvas.drawLine(tailStart, tailEnd, tailPaint);

    final dotPaint = Paint()..color = clay;
    canvas.drawCircle(
      Offset(center.dx + r * 0.02, center.dy - r * 0.04),
      r * 0.11,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) =>
      oldDelegate.green != green ||
      oldDelegate.amber != amber ||
      oldDelegate.clay != clay;
}
