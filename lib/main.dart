import 'package:dealinesapp/db/dao/deadline_dao.dart';
import 'package:flutter/material.dart';

import 'db/database.dart';
import 'db/entity/deadline.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  final deadlineDao = database.deadlineDao;

  runApp(MyApp(deadlineDao));
}

class MyApp extends StatelessWidget {
  final DeadlineDao deadlineDao;

  const MyApp(this.deadlineDao);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeadLines',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(
        title: 'DeadLines',
        deadlineDao: deadlineDao,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
    this.title,
    @required this.deadlineDao
  }) : super(key: key);

  final DeadlineDao deadlineDao;
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState(deadlineDao);
}

class _MyHomePageState extends State<MyHomePage> {
  final DeadlineDao deadlineDao;

  _MyHomePageState(this.deadlineDao);

  void _addDeadline(final Deadline deadline) async {
    await deadlineDao.insertDeadline(deadline);
  }

  void _removeDeadline(final Deadline deadline) async {
    await deadlineDao.deleteDeadlineById(deadline);
  }

  Widget _createCard(BuildContext context, final Deadline deadline) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(deadline.title),
            subtitle: Text('Due in two days'),
          ),
          ButtonBar(
            children: <Widget>[
              FlatButton(
                child: const Text('FINISHED'),
                onPressed: () {
                  _removeDeadline(deadline);

                  final snackBar = SnackBar(
                    content: Text('Nice!'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        _addDeadline(deadline);
                      },
                    ),
                  );
                  Scaffold.of(context).showSnackBar(snackBar);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _createCards(BuildContext context) {
    return StreamBuilder<List<Deadline>>(
        stream: deadlineDao.findAllDeadlinesAsStream(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return ListView();

          final tasks = snapshot.data;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (_, index) {
              return _createCard(context, tasks[index]);
            },
          );
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(
        builder: (context) =>
            Align(
              alignment: Alignment.topCenter,
              child: _createCards(context)
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          _addDeadline(Deadline(null, "Thing"))
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
