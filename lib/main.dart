import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'dart:math';

import 'package:deadlinesapp/db/database.dart';
import 'package:deadlinesapp/db/entity/deadline.dart';
import 'package:deadlinesapp/db/dao/deadline_dao.dart';

import 'package:deadlinesapp/l10n/localizations.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  final deadlineDao = database.deadlineDao;

  runApp(DeadlinesApp(deadlineDao));
}

class DeadlinesApp extends StatelessWidget {
  final DeadlineDao deadlineDao;

  const DeadlinesApp(this.deadlineDao);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (BuildContext context) => DeadlinesAppLocalizations.of(context).deadlines,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ).copyWith(
          inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      home: DeadlinesPage(
        deadlineDao: deadlineDao,
      ),
      localizationsDelegates: [
        DeadlinesAppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', ''),
      ],
    );
  }
}

class DeadlinesPage extends StatelessWidget {
  DeadlinesPage({
    Key key,
    @required this.deadlineDao
  }) : super(key: key);

  final DeadlineDao deadlineDao;

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

    final normalizedTime = max<double>(0, timeToDeadline.inDays / 20.0);

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
            subtitle: Text(DeadlinesAppLocalizations.of(context).dueText(timeToDeadline)),
            trailing: IconButton(
              icon: const Icon(
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
                child: Text(DeadlinesAppLocalizations.of(context).finished),
                onPressed: () {
                  _removeDeadline(deadline);

                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(DeadlinesAppLocalizations.of(context).nice),
                    action: SnackBarAction(
                      label: DeadlinesAppLocalizations.of(context).undo,
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
        title: Text(DeadlinesAppLocalizations.of(context).deadlines),
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
        tooltip: DeadlinesAppLocalizations.of(context).addDeadline,
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
      appBar: AppBar(
        title: Text(DeadlinesAppLocalizations.of(context).addDeadline),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: AddDeadlineWidget(
          this.deadlineDao,
          previousId: this.previousId,
          previousTitle: this.previousTitle,
          previousDeadline: this.previousDeadline,
        ),
      ),
    );
  }
}

class AddDeadlineWidget extends StatefulWidget {
  final DeadlineDao deadlineDao;
  final int previousId;
  final String previousTitle;
  final DateTime previousDeadline;

  AddDeadlineWidget(this.deadlineDao, {
    this.previousId,
    this.previousTitle,
    this.previousDeadline,
    Key key,
  }) : super(key: key);

  @override
  _AddDeadlineWidgetState createState() => _AddDeadlineWidgetState(
    this.deadlineDao,
    id: this.previousId,
    title: this.previousTitle,
    deadline: this.previousDeadline,
  );
}

class _AddDeadlineWidgetState extends State<AddDeadlineWidget> {
  final DeadlineDao deadlineDao;
  final int id;
  String title;
  DateTime deadline;

  _AddDeadlineWidgetState(this.deadlineDao, {
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
            decoration: InputDecoration(
              hintText: DeadlinesAppLocalizations
                  .of(context)
                  .title,
            ),
            validator: (value) {
              if (value.isEmpty) {
                return DeadlinesAppLocalizations
                    .of(context)
                    .enterATitle;
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
          const SizedBox(height: 24),
          DateTimeField(
            initialValue: deadline ?? _now,
            format: DateFormat("yyyy-MM-dd HH:mm"),
            onShowPicker: (context, currentValue) async {
              final date = await showDatePicker(
                context: context,
                firstDate: deadline != null && deadline.isBefore(_now)
                    ? deadline
                    : _now,
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
          const Padding(padding: EdgeInsets.symmetric(vertical: 16.0)),
          FlatButton(
            color: Colors.deepOrangeAccent,
            textColor: Colors.white,
            child: Text(DeadlinesAppLocalizations.of(context).save),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                if (id == null) {
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
