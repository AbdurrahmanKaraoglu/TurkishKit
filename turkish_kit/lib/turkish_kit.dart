/// Turkish helpers for Dart and Flutter, in pure Dart:
///
/// * [TurkishValidators] and [TurkishFormValidators]: T.C. kimlik no, vergi
///   kimlik no, TR IBAN and phone numbers; [TurkishInputMask] for
///   as-you-type formatting.
/// * [TurkishMoney] and [TurkishNumberWords]: exact amounts, Turkish number
///   format and amounts in words (`Yalnız #...#`).
/// * [TurkishText]: Turkish upper/lower case, search normalization and
///   alphabetical sorting.
/// * [TurkishProvinces]: the 81 provinces and 973 districts, offline.
/// * [TurkishHolidays] and [TurkishBusinessCalendar]: public holidays,
///   bayrams and working days.
library;

export 'src/form_validators.dart';
export 'src/holidays.dart';
export 'src/input_mask.dart';
export 'src/money.dart';
export 'src/money_input_mask.dart';
export 'src/number_words.dart' show TurkishNumberWords, TurkishWordCase;
export 'src/provinces.dart';
export 'src/text.dart';
export 'src/validators.dart';
