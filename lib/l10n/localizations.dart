import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'generated/messages_all.dart';

class DeadlinesAppLocalizations {
  static Future<DeadlinesAppLocalizations> load(Locale locale) {
    final String name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      return DeadlinesAppLocalizations(localeName);
    });
  }

  static DeadlinesAppLocalizations of(BuildContext context) {
    return Localizations.of<DeadlinesAppLocalizations>(context, DeadlinesAppLocalizations);
  }

  static const LocalizationsDelegate<DeadlinesAppLocalizations> delegate = _DeadlinesAppLocalizationsDelegate();

  DeadlinesAppLocalizations(this.localeName);

  final String localeName;

  String get deadlines => Intl.message('Dealines', locale: localeName);

  String get addDeadline => Intl.message('Add deadline', locale: localeName);

  String dueDays(int inDays) => Intl.message(
    'Due in $inDays days',
    args: [inDays],
    name: 'dueDays',
    locale: localeName,
  );

  String dueHours(int inHours) => Intl.message(
    'Due in $inHours hours',
    args: [inHours],
    name: 'dueHours',
    locale: localeName,
  );

  String dueMinutes(int inMinutes) => Intl.message(
    'Due in $inMinutes minutes',
    args: [inMinutes],
    name: 'dueMinutes',
    locale: localeName,
  );

  String get dueNow => Intl.message('Due NOW!');

  String get dueLate => Intl.message('Late!');

  String dueText(Duration timeToDeadline) {
    if(timeToDeadline.inDays > 0) {
      return dueDays(timeToDeadline.inDays);
    }
    if(timeToDeadline.inHours > 1) {
      return dueHours(timeToDeadline.inHours);
    }
    if(timeToDeadline.inMinutes > 15) {
      return dueMinutes(timeToDeadline.inMinutes);
    }
    if(timeToDeadline.inMilliseconds > 0) {
      return dueNow;
    }
    return dueLate;
  }
  
  String get finished => Intl.message('FINISHED');
  
  String get nice => Intl.message('Nice!');
  
  String get undo => Intl.message('UNDO');

  String get title => Intl.message('Title');

  String get enterATitle => Intl.message('Enter a title');

  String get save => Intl.message('SAVE');
}

class _DeadlinesAppLocalizationsDelegate extends LocalizationsDelegate<DeadlinesAppLocalizations> {
  const _DeadlinesAppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<DeadlinesAppLocalizations> load(Locale locale) {
    return DeadlinesAppLocalizations.load(locale);
  }

  @override
  bool shouldReload(_DeadlinesAppLocalizationsDelegate old) => false;
}