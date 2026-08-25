import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/stats/presentation/stats_screen.dart';
import 'qenat_logo.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  children: [
                    const QenatLogo(size: 32, showName: true),
                    const Spacer(),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _index == 0
                          ? const SizedBox.shrink(key: ValueKey('empty'))
                          : IconButton(
                              key: const ValueKey('calendar-jump'),
                              tooltip: 'Go to Calendar',
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                setState(() => _index = 0);
                              },
                              icon: const Icon(Icons.calendar_month_rounded, size: 22),
                            ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _index == 0
                      ? const CalendarScreen(key: ValueKey('calendar'))
                      : const StatsScreen(key: ValueKey('stats')),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) {
            HapticFeedback.lightImpact();
            setState(() => _index = i);
          },
          animationDuration: const Duration(milliseconds: 400),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights_rounded),
              label: 'Insights',
            ),
          ],
        ),
      ),
    );
  }
}
