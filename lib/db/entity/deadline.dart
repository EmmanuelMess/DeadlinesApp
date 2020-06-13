import 'package:floor/floor.dart';

@entity
class Deadline {
  @primaryKey
  final int id;

  final String title;

  Deadline(this.id, this.title);
}