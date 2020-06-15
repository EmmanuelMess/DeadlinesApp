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
    final longWayAwayColor = Colors.red.shade100;
    final nowColor = Colors.red;

    if(timeToDeadline.inDays >= 20) {
      return longWayAwayColor;
    }

    double normalizedTime = max<double>(0, timeToDeadline.inDays / 20.0);

    return Color.lerp(nowColor, longWayAwayColor, normalizedTime);
  }

  String _dueText(Duration timeToDeadline) {
    if(timeToDeadline.inDays > 0) {
      return 'Due in ${timeToDeadline.inDays} days';
    }
    if(timeToDeadline.inHours > 1) {
      return 'Due in ${timeToDeadline.inHours} hours!';
    }
    if(timeToDeadline.inMinutes > 15) {
      return 'Due in ${timeToDeadline.inMinutes} minutes!';
    }
    if(timeToDeadline.inMilliseconds > 0) {
      return 'Due NOW!';
    }
    return 'Late!';
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
            subtitle: Text(_dueText(timeToDeadline)),
            trailing: IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.white,
              ),
              onPressed: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddDeadlinePage(
                      this.deadlineDao,
                      previousId: deadline.id,
                      previousTitle: deadline.title,
                      previousDeadline: time,
                    ),
                  ),
                ),
            ),
          ),
          ButtonBar(
            children: <Widget>[
              FlatButton(
                textColor: Colors.white,
                child: const Text('FINISHED'),
                onPressed: () {
                  _removeDeadline(deadline);

                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('Nice!'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        _addDeadline(deadline);
                      },
                    ),
                  ));
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddDeadlinePage(this.deadlineDao),
              ),
            ),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddDeadlinePage extends StatelessWidget {
  final DeadlineDao deadlineDao;
  final int previousId;
  final String previousTitle;
  final DateTime previousDeadline;

  AddDeadlinePage(this.deadlineDao, {
    this.previousId,
    this.previousTitle,
    this.previousDeadline,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add deadline")),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: MyStatefulWidget(
          this.deadlineDao,
          previousId: this.previousId,
          previousTitle: this.previousTitle,
          previousDeadline: this.previousDeadline,
        ),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  final DeadlineDao deadlineDao;
  final int previousId;
  final String previousTitle;
  final DateTime previousDeadline;

  MyStatefulWidget(this.deadlineDao, {
    this.previousId,
    this.previousTitle,
    this.previousDeadline,
    Key key,
  }) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState(
    this.deadlineDao,
    id: this.previousId,
    title: this.previousTitle,
    deadline: this.previousDeadline,
  );
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final DeadlineDao deadlineDao;
  final int id;
  String title;
  DateTime deadline;

  _MyStatefulWidgetState(this.deadlineDao, {
    this.id,
    this.title,
    this.deadline,
  }) : assert(id == null || (id != null && title != null && deadline != null));

  final _formKey = GlobalKey<FormState>();
  final _now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            initialValue: title ?? "",
            decoration: const InputDecoration(
              hintText: 'Title',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Enter a title';
              }
              return null;
            },
            onChanged: (String value) =>
                setState(() {
                  title = value;
                }),
            onSaved: (String value) =>
                setState(() {
                  title = value;
                }),
          ),
          SizedBox(height: 24),
          DateTimeField(
            initialValue: deadline ?? _now,
            format: DateFormat("yyyy-MM-dd HH:mm"),
            onShowPicker: (context, currentValue) async {
              final date = await showDatePicker(
                context: context,
                firstDate: deadline != null && deadline.isBefore(_now)? deadline : _now,
                initialDate: currentValue ?? _now,
                lastDate: DateTime(2100),
              );
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(
                      currentValue ?? _now),
                );
                return DateTimeField.combine(date, time);
              } else {
                return currentValue;
              }
            },
            onChanged: (DateTime value) =>
                setState(() {
                  deadline = value;
                }),
            onSaved: (DateTime value) =>
                setState(() {
                  deadline = value;
                }),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 16.0)),
           FlatButton(
            color: Colors.deepOrangeAccent,
            textColor: Colors.white,
            child: Text('SAVE'),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                if(id == null) {
                  await deadlineDao.insertDeadline(Deadline(
                    null,
                    title,
                    deadline.millisecondsSinceEpoch,
                  ));
                } else {
                  await deadlineDao.updateDeadline(Deadline(
                    id,
                    title,
                    deadline.millisecondsSinceEpoch,
                  ));
                }
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
