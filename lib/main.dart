import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/home_shell.dart';

void main() {
  runApp(const ProviderScope(child: QenatApp()));
}

class QenatApp extends StatelessWidget {
  const QenatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qenat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomeShell(),
    );
  }
}
