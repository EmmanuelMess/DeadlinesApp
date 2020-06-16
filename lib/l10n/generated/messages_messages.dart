// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a messages locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'messages';

  static m0(inDays) => "Due in ${inDays} days";

  static m1(inHours) => "Due in ${inHours} hours";

  static m2(inMinutes) => "Due in ${inMinutes} minutes";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "Add deadline" : MessageLookupByLibrary.simpleMessage("Add deadline"),
    "Deadlines" : MessageLookupByLibrary.simpleMessage("Deadlines"),
    "Due NOW!" : MessageLookupByLibrary.simpleMessage("Due NOW!"),
    "Enter a title" : MessageLookupByLibrary.simpleMessage("Enter a title"),
    "FINISHED" : MessageLookupByLibrary.simpleMessage("FINISHED"),
    "Late!" : MessageLookupByLibrary.simpleMessage("Late!"),
    "Nice!" : MessageLookupByLibrary.simpleMessage("Nice!"),
    "SAVE" : MessageLookupByLibrary.simpleMessage("SAVE"),
    "Title" : MessageLookupByLibrary.simpleMessage("Title"),
    "UNDO" : MessageLookupByLibrary.simpleMessage("UNDO"),
    "dueDays" : m0,
    "dueHours" : m1,
    "dueMinutes" : m2
  };
}
