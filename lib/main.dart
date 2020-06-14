import 'dart:ui';

import 'package:dealinesapp/db/dao/deadline_dao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import 'dart:math';

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
      ).copyWith(
          inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder()),
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

  Color _getCardColor(Duration timeToDeadline) {
    final longWayAwayColor = Colors.black12;
    final nowColor = Colors.red;

    if(timeToDeadline.inDays >= 20) {
      return longWayAwayColor;
    }

    double normalizedTime = max<double>(0, timeToDeadline.inDays / 20.0);

    return Color.lerp(nowColor, longWayAwayColor, normalizedTime);
  }

  Widget _createCard(BuildContext context, final Deadline deadline) {
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(deadline.deadline);
    final Duration timeToDeadline = time.difference(DateTime.now());

    return Card(
      color: _getCardColor(timeToDeadline),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(deadline.title),
            subtitle: Text('Due in ${timeToDeadline.inDays} days'),
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
      body: Padding(
        padding: EdgeInsets.all(24),
        child: MyStatefulWidget(this.deadlineDao),
      ),
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

  String _title;
  DateTime _deadline;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Title',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Enter a title';
              }
              return null;
            },
            onChanged: (String value) => setState(() {
              _title = value;
            }),
            onSaved: (String value) => setState(() {
              _title = value;
            }),
          ),
          SizedBox(height: 24),
          DateTimeField(
            format: DateFormat("yyyy-MM-dd HH:mm"),
            onShowPicker: (context, currentValue) async {
              final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  initialDate: currentValue ?? DateTime.now(),
                  lastDate: DateTime(2100),
              );
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                );
                return DateTimeField.combine(date, time);
              } else {
                return currentValue;
              }
            },
            onChanged: (DateTime value) => setState(() {
              _deadline = value;
            }),
            onSaved: (DateTime value) => setState(() {
              _deadline = value;
            }),
          ),
          RaisedButton(
            child: Text('SAVE'),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                await deadlineDao.insertDeadline(Deadline(
                    null,
                  _title,
                  _deadline.millisecondsSinceEpoch
                ));
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
