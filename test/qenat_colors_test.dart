import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qenat/core/theme/qenat_colors.dart';

void main() {
  group('gradient anchors', () {
    test('rate 0 lands on clay red', () {
      expect(QenatColors.anchorForRate(0), const Color(0xFFA6503F));
    });

    test('rate 0.5 lands on amber', () {
      expect(QenatColors.anchorForRate(0.5), const Color(0xFFD9992B));
    });

    test('rate 1 lands on deep green', () {
      expect(QenatColors.anchorForRate(1), const Color(0xFF2F6B4E));
    });

    test('anchors move monotonically toward green', () {
      final zero = QenatColors.anchorForRate(0);
      var prev = zero.g - zero.r;
      for (final rate in [0.1, 0.3, 0.5, 0.7, 0.9]) {
        final c = QenatColors.anchorForRate(rate);
        final greenness = c.g - c.r;
        expect(greenness, greaterThan(prev),
            reason: 'greenness should increase with rate');
        prev = greenness;
      }
    });
  });

  group('fill blending', () {
    test('fills stay light enough for ink text contrast', () {
      for (var i = 0; i <= 10; i++) {
        final fill = QenatColors.fillForRate(i / 10);
        expect(fill.computeLuminance(), greaterThan(0.35),
            reason: 'fill at rate ${i / 10} too dark');
      }
    });

    test('fill differs from pure anchor', () {
      expect(QenatColors.fillForRate(1),
          isNot(QenatColors.anchorForRate(1)));
    });
  });

  group('theme extension plumbing', () {
    test('standard instances are equal and hash-consistent', () {
      expect(QenatColors.standard(), QenatColors.standard());
      expect(
          QenatColors.standard().hashCode, QenatColors.standard().hashCode);
    });

    test('lerp at 0 returns original palette', () {
      final a = QenatColors.standard();
      final b = QenatColors.standard()
          .copyWith(scaffold: const Color(0xFF101010));
      expect(a.lerp(b, 0), a);
    });

    test('lerp at 1 returns target palette', () {
      final a = QenatColors.standard();
      final b = QenatColors.standard()
          .copyWith(scaffold: const Color(0xFF101010));
      expect(a.lerp(b, 1).scaffold, b.scaffold);
    });
  });
}
