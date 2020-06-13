import 'package:dealinesapp/db/entity/deadline.dart';
import 'package:floor/floor.dart';

@dao
abstract class DeadlineDao {
  @Query('SELECT * FROM Deadline')
  Future<List<Deadline>> findAllPersons();

  @Query('SELECT * FROM Deadline WHERE id = :id')
  Stream<Deadline> findPersonById(int id);

  @insert
  Future<void> insertPerson(Deadline person);
}
