import 'package:deadlinesapp/db/dao/deadline_dao.dart';
import 'package:deadlinesapp/db/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deadlinesapp/main.dart';

void main() {
  AppDatabase database;
  DeadlineDao deadlineDao;

  setUp(() async {
    database = await $FloorAppDatabase
        .inMemoryDatabaseBuilder()
        .build();
    deadlineDao = database.deadlineDao;
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(DeadlinesApp(deadlineDao));

    expect(find.byElementType(Card), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.byElementType(Card), findsOneWidget);
  });
}
