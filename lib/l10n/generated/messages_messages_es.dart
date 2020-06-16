// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a messages_es locale. All the
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
  String get localeName => 'messages_es';

  static m0(inDays) => "A entregar en ${inDays} dias";

  static m1(inHours) => "A entregar en ${inHours} horas";

  static m2(inMinutes) => "A entregar en ${inMinutes} minutos";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "Add deadline" : MessageLookupByLibrary.simpleMessage("Añadir fecha limite"),
    "Deadlines" : MessageLookupByLibrary.simpleMessage("Fechas limite"),
    "Due NOW!" : MessageLookupByLibrary.simpleMessage("A entregar YA!"),
    "Enter a title" : MessageLookupByLibrary.simpleMessage("Ingresar titulo"),
    "FINISHED" : MessageLookupByLibrary.simpleMessage("TERMINADO"),
    "Late!" : MessageLookupByLibrary.simpleMessage("Tarde!"),
    "Nice!" : MessageLookupByLibrary.simpleMessage("Genial!"),
    "SAVE" : MessageLookupByLibrary.simpleMessage("GUARDAR"),
    "Title" : MessageLookupByLibrary.simpleMessage("Titulo"),
    "UNDO" : MessageLookupByLibrary.simpleMessage("DESHACER"),
    "dueDays" : m0,
    "dueHours" : m1,
    "dueMinutes" : m2
  };
}
