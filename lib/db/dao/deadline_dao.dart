import 'package:dealinesapp/db/entity/deadline.dart';
import 'package:floor/floor.dart';

@dao
abstract class DeadlineDao {
  @Query('SELECT * FROM Deadline')
  Future<List<Deadline>> findAllDeadlines();

  @delete
  Future<void> deleteDeadlineById(Deadline person);

  @insert
  Future<void> insertDeadline(Deadline person);

  @Query('SELECT * FROM Deadline')
  Stream<List<Deadline>> findAllDeadlinesAsStream();
}
