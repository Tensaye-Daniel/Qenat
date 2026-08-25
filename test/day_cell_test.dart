import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qenat/core/theme/app_theme.dart';
import 'package:qenat/core/theme/qenat_colors.dart';
import 'package:qenat/features/calendar/presentation/widgets/day_cell.dart';
import 'package:qenat/features/tasks/domain/day_progress.dart';

Widget _host(Widget child, {TextScaler scaler = TextScaler.noScaling}) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: MediaQuery(
      data: MediaQueryData(textScaler: scaler),
      child: Scaffold(
        body: Center(
          child: SizedBox(width: 48, height: 48, child: child),
        ),
      ),
    ),
  );
}

BoxDecoration _decorationOf(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(
    find.descendant(
      of: find.byType(DayCell),
      matching: find.byType(AnimatedContainer),
    ).first,
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  testWidgets('planned day shows count and gradient fill', (tester) async {
    final day = DateTime(2026, 8, 12);
    await tester.pumpWidget(
      _host(
        DayCell(
          date: day,
          inMonth: true,
          progress: const DayProgress(total: 3, completed: 2),
          isSelected: false,
          isToday: false,
          onTap: () {},
        ),
      ),
    );

    expect(find.text('12'), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);

    final colors = QenatColors.standard();
    expect(
      _decorationOf(tester).color,
      QenatColors.fillForRate(2 / 3, base: colors.surfaceCard),
    );
  });

  testWidgets('unplanned day invites action with plus affordance',
      (tester) async {
    final day = DateTime(2026, 8, 12);
    await tester.pumpWidget(
      _host(
        DayCell(
          date: day,
          inMonth: true,
          progress: null,
          isSelected: false,
          isToday: false,
          onTap: () {},
        ),
      ),
    );

    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    final colors = QenatColors.standard();
    expect(_decorationOf(tester).color, colors.stoneCell);
  });

  testWidgets('today and selected states draw distinct borders',
      (tester) async {
    final day = DateTime(2026, 8, 12);

    await tester.pumpWidget(
      _host(
        DayCell(
          date: day,
          inMonth: true,
          progress: const DayProgress(total: 1, completed: 1),
          isSelected: false,
          isToday: true,
          onTap: () {},
        ),
      ),
    );
    final todayBorder = _decorationOf(tester).border as Border;
    expect(todayBorder.top.color, QenatColors.standard().green);

    await tester.pumpWidget(
      _host(
        DayCell(
          key: UniqueKey(),
          date: day,
          inMonth: true,
          progress: const DayProgress(total: 1, completed: 1),
          isSelected: true,
          isToday: false,
          onTap: () {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    final selectedBorder = _decorationOf(tester).border as Border;
    expect(selectedBorder.top.color, QenatColors.standard().ink);
  });

  testWidgets('completion change triggers pulse without exceptions',
      (tester) async {
    final day = DateTime(2026, 8, 12);
    var completed = 0;

    Widget build() => _host(
          StatefulBuilder(
            builder: (context, setState) => DayCell(
              date: day,
              inMonth: true,
              progress: DayProgress(total: 2, completed: completed),
              isSelected: false,
              isToday: false,
              onTap: () => setState(() => completed++),
            ),
          ),
        );

    await tester.pumpWidget(build());
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(DayCell));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('1/2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cell survives extreme text scaling', (tester) async {
    final day = DateTime(2026, 8, 12);
    await tester.pumpWidget(
      _host(
        DayCell(
          date: day,
          inMonth: true,
          progress: const DayProgress(total: 10, completed: 9),
          isSelected: false,
          isToday: false,
          onTap: () {},
        ),
        scaler: const TextScaler.linear(2.0),
      ),
    );
    await tester.pump();

    expect(find.text('12'), findsOneWidget);
    expect(find.text('9/10'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
