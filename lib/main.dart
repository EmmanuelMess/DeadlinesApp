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
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DeadlinesPage(
        title: 'DeadLines',
        deadlineDao: deadlineDao,
      ),
    );
  }
}

class DeadlinesPage extends StatefulWidget {
  DeadlinesPage({
    Key key,
    this.title,
    @required this.deadlineDao
  }) : super(key: key);

  final DeadlineDao deadlineDao;
  final String title;

  @override
  _DeadlinesPageState createState() => _DeadlinesPageState(deadlineDao);
}

class _DeadlinesPageState extends State<DeadlinesPage> {
  final DeadlineDao deadlineDao;

  _DeadlinesPageState(this.deadlineDao);

  void _addDeadline(final Deadline deadline) async {
    await deadlineDao.insertDeadline(deadline);
  }

  void _removeDeadline(final Deadline deadline) async {
    await deadlineDao.deleteDeadlineById(deadline);
  }

  Widget _createCard(BuildContext context, final Deadline deadline) {
    return Card(
      color: Color.lerp(Colors.black12, Colors.red, 1.0),
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
                textColor: Colors.white,
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
        onPressed: () =>
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDeadlinePage(this.deadlineDao),
            ),
          )
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddDeadlinePage extends StatelessWidget {
  final DeadlineDao deadlineDao;

  const AddDeadlinePage(this.deadlineDao);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: MyStatefulWidget(this.deadlineDao),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  final DeadlineDao deadlineDao;

  MyStatefulWidget(this.deadlineDao, {Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState(this.deadlineDao);
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final DeadlineDao deadlineDao;

  _MyStatefulWidgetState(this.deadlineDao);

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Enter your email',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () async {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState.validate()) {
                  await deadlineDao.insertDeadline(Deadline(null, "Thing"));
                  Navigator.pop(context);
                }
              },
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
