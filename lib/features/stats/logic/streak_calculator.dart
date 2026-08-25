class StreakCalculator {
  StreakCalculator._();

  static const double qualifyingThreshold = 0.8;

  static ({int current, int best}) compute(Map<int, double> rateByDay,
      {required int todayEpoch}) {
    bool qualifies(int day) {
      final rate = rateByDay[day];
      return rate != null && rate >= qualifyingThreshold;
    }

    var current = 0;
    var cursor = todayEpoch;
    if (qualifies(cursor)) {
      current++;
    }
    cursor--;
    while (qualifies(cursor)) {
      current++;
      cursor--;
    }

    var best = 0;
    var run = 0;
    int? previous;
    final days = rateByDay.keys.where(qualifies).toList()..sort();
    for (final day in days) {
      run = (previous != null && day == previous + 1) ? run + 1 : 1;
      if (run > best) best = run;
      previous = day;
    }

    return (current: current, best: best);
  }
}
