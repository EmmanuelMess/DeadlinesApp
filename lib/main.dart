import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import 'package:deadlinesapp/db/database.dart';
import 'package:deadlinesapp/db/entity/deadline.dart';
import 'package:deadlinesapp/db/dao/deadline_dao.dart';

import 'package:deadlinesapp/l10n/localization.dart';
import 'package:deadlinesapp/newdeadline.dart';
import 'package:deadlinesapp/about.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await $FloorAppDatabase.databaseBuilder('app_database.db')
      .build();
  final deadlineDao = database.deadlineDao;

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('es')],
      path: 'lib/l10n',
      fallbackLocale: Locale('en'),
      useOnlyLangCode: true,
      child: DeadlinesApp(deadlineDao),
    )
  );
}

class DeadlinesApp extends StatelessWidget {
  final DeadlineDao deadlineDao;

  const DeadlinesApp(this.deadlineDao);

  @override
  Widget build(BuildContext context) =>
      MaterialApp(
        showPerformanceOverlay: false,
        onGenerateTitle: (BuildContext context) => 'Deadlines'.tr(),
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ).copyWith(
          inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder()),
        ),
        home: DeadlinesPage(
          deadlineDao: deadlineDao,
        ),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
      );
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

    if (timeToDeadline.inDays >= 20) {
      return longWayAwayColor;
    }

    final normalizedTime = max<double>(0, timeToDeadline.inDays / 20.0);

    return Color.lerp(nowColor, longWayAwayColor, normalizedTime);
  }

  Widget _createCard(BuildContext context, final Deadline deadline) {
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(
        deadline.deadline);
    final Duration timeToDeadline = time.difference(DateTime.now());

    return Card(
      color: _getCardColor(timeToDeadline),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(deadline.title),
            subtitle: Text(Localization.dueText(timeToDeadline)),
            trailing: IconButton(
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
              onPressed: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddDeadlinePage(
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
                child: Text('FINISHED').tr(),
                onPressed: () {
                  _removeDeadline(deadline);

                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('Nice!').tr(),
                    action: SnackBarAction(
                      label: 'UNDO'.tr(),
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

  Widget _createCards(BuildContext context) =>
      StreamBuilder<List<Deadline>>(
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

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        appBar: AppBar(
          title: Text('Deadlines').tr(),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'About'.tr(),
              onPressed: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AboutPage()
                    ),
                  ),
            )
          ],
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
          tooltip: 'Add deadline'.tr(),
          child: Icon(Icons.add),
        ),
      );
}