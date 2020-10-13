import 'package:easy_localization/easy_localization.dart';

class Localization {
  static String dueText(Duration timeToDeadline) {
    if(timeToDeadline.inDays > 1) {
      return 'dueDays'.tr(args: [timeToDeadline.inDays.toString()]);
    }
    if(timeToDeadline.inHours > 1) {
      return 'dueHours'.tr(args: [timeToDeadline.inHours.toString()]);
    }
    if(timeToDeadline.inMinutes > 15) {
      return 'dueMinutes'.tr(args: [timeToDeadline.inMinutes.toString()]);
    }
    if(timeToDeadline.inMilliseconds > 0) {
      return 'dueNow'.tr();
    }
    return 'dueLate'.tr();
  }
}