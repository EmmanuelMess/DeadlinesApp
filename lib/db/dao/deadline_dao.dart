import 'package:dealinesapp/db/entity/deadline.dart';
import 'package:floor/floor.dart';

@dao
abstract class DeadlineDao {
  @update
  Future<void> updateDeadline(Deadline person);

  @delete
  Future<void> deleteDeadlineById(Deadline person);

  @insert
  Future<void> insertDeadline(Deadline person);

  @Query('SELECT * FROM Deadline ORDER BY Deadline.deadline ASC')
  Stream<List<Deadline>> findAllDeadlinesAsStream();
}
