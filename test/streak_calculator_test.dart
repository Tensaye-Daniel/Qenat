import 'package:flutter_test/flutter_test.dart';
import 'package:qenat/features/stats/logic/streak_calculator.dart';

void main() {
  group('StreakCalculator.compute', () {
    const today = 1000;

    test('empty history yields zero streaks', () {
      final r = StreakCalculator.compute({}, todayEpoch: today);
      expect(r.current, 0);
      expect(r.best, 0);
    });

    test('a fully complete today counts toward current streak', () {
      final r = StreakCalculator.compute(
          {today: 1.0}, todayEpoch: today);
      expect(r.current, 1);
      expect(r.best, 1);
    });

    test('partial today does not break yesterday-based streak', () {
      final r = StreakCalculator.compute({
        today: 0.4,
        today - 1: 1.0,
        today - 2: 0.85,
        today - 3: 1.0,
      }, todayEpoch: today);
      expect(r.current, 3);
      expect(r.best, 3);
    });

    test('gap resets current streak but preserves best', () {
      final r = StreakCalculator.compute({
        today: 1.0,
        today - 1: 1.0,
        today - 2: 0.5,
        today - 3: 1.0,
        today - 4: 1.0,
        today - 5: 1.0,
      }, todayEpoch: today);
      expect(r.current, 2);
      expect(r.best, 3);
    });

    test('exactly at threshold qualifies', () {
      final r = StreakCalculator.compute({today: 0.8}, todayEpoch: today);
      expect(r.current, 1);
    });

    test('just below threshold does not qualify', () {
      final r = StreakCalculator.compute({today: 0.79}, todayEpoch: today);
      expect(r.current, 0);
    });

    test('best scan handles unordered keys', () {
      final r = StreakCalculator.compute({
        today - 6: 1.0,
        today - 4: 1.0,
        today - 5: 1.0,
        today - 3: 1.0,
      }, todayEpoch: today);
      expect(r.best, 4);
      expect(r.current, 0);
    });

    test('long historical run beats short current run', () {
      final rates = <int, double>{
        today: 1.0,
        today - 1: 1.0,
        for (var d = 500; d <= 520; d++) d: 1.0,
      };
      final r = StreakCalculator.compute(rates, todayEpoch: today);
      expect(r.current, 2);
      expect(r.best, 21);
    });
  });
}
