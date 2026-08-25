import 'package:drift/drift.dart';

@TableIndex(name: 'idx_tasks_date_epoch_day', columns: {#dateEpochDay})
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text().withLength(min: 1, max: 300)();

  IntColumn get dateEpochDay => integer()();

  IntColumn get minuteOfDay => integer().nullable()();

  TextColumn get categoryCode => text().nullable()();

  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
