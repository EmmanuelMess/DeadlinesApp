import 'package:dealinesapp/db/entity/deadline.dart';
import 'package:floor/floor.dart';

@dao
abstract class DeadlineDao {
  @delete
  Future<void> deleteDeadlineById(Deadline person);

  @insert
  Future<void> insertDeadline(Deadline person);

  @Query('SELECT * FROM Deadline')
  Stream<List<Deadline>> findAllDeadlinesAsStream();
}
