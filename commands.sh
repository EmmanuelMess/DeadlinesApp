#*

#lib/db
~/flutter/bin/flutter packages pub run build_runner build --delete-conflicting-outputs

#libs/l10n
~/flutter/bin/flutter pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/l10n/localizations.dart
~/flutter/bin/flutter pub run intl_translation:generate_from_arb --output-dir=lib/l10n/generated --no-use-deferred-loading lib/l10n/localizations.dart lib/l10n/intl_*.arb