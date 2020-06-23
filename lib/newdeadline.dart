import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import 'package:deadlinesapp/db/entity/deadline.dart';
import 'package:deadlinesapp/db/dao/deadline_dao.dart';

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
  Widget build(BuildContext context) =>
      Scaffold(
        appBar: AppBar(
          title: Text('Add deadline').tr(),
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
  _AddDeadlineWidgetState createState() =>
      _AddDeadlineWidgetState(
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
  Widget build(BuildContext context) =>
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              initialValue: title ?? "",
              decoration: InputDecoration(
                hintText: 'Title'.tr(),
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter a title'.tr();
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
              child: Text('SAVE').tr(),
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