import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Tasks])
class QenatDatabase extends _$QenatDatabase {
  QenatDatabase() : super(driftDatabase(name: 'qenat'));

  QenatDatabase.connect(super.executor);

  @override
  int get schemaVersion => 1;
}
