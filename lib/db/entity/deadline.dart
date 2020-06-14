import 'package:floor/floor.dart';

@entity
class Deadline {
  @primaryKey
  final int id;

  final String title;

  final int deadline;

  Deadline(this.id, this.title, this.deadline);
}