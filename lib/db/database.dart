import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/deadline_dao.dart';
import 'entity/deadline.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Deadline])
abstract class AppDatabase extends FloorDatabase {
  DeadlineDao get deadlineDao;
}
