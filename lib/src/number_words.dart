import 'text.dart';

/// Letter case of words produced by [TurkishNumberWords] and [TurkishMoney].
enum TurkishWordCase {
  /// `Bin İki Yüz Otuz Dört` — every word capitalized (the default).
  title,

  /// `bin iki yüz otuz dört`.
  lower,

  /// `BİN İKİ YÜZ OTUZ DÖRT` (Turkish upper case: i becomes İ).
  upper,

  /// `Bin iki yüz otuz dört` — only the first word capitalized.
  sentence,
}

const List<String> _ones = <String>[
  '', 'bir', 'iki', 'üç', 'dört', 'beş', 'altı', 'yedi', 'sekiz', 'dokuz', //
];
const List<String> _tens = <String>[
  '', 'on', 'yirmi', 'otuz', 'kırk', 'elli', 'altmış', 'yetmiş', 'seksen', //
  'doksan',
];

/// Short-scale group names: 10^3, 10^6, ... 10^33.
const List<String> _scales = <String>[
  '', 'bin', 'milyon', 'milyar', 'trilyon', 'katrilyon', 'kentilyon', //
  'seksilyon', 'septilyon', 'oktilyon', 'nonilyon', 'desilyon',
];

/// Converts whole numbers to Turkish words.
///
/// Follows Turkish usage: `100` is `yüz` and `1000` is `bin` (never
/// "bir yüz" / "bir bin"), but `1000000` is `bir milyon`.
abstract final class TurkishNumberWords {
  /// The largest supported absolute value: 10^36 - 1 (the desilyon range).
  static final BigInt maxValue = BigInt.from(10).pow(36) - BigInt.one;

  /// Words for [value], which must be an [int] or a [BigInt].
  ///
  /// Negative numbers start with `eksi`. Throws an [ArgumentError] for other
  /// types and a [RangeError] when the absolute value exceeds [maxValue].
  ///
  /// ```dart
  /// TurkishNumberWords.convert(1234); // 'Bin İki Yüz Otuz Dört'
  /// TurkishNumberWords.convert(-7, wordCase: TurkishWordCase.lower); // 'eksi yedi'
  /// ```
  static String convert(
    Object value, {
    TurkishWordCase wordCase = TurkishWordCase.title,
    String separator = ' ',
  }) => applyWordCase(words(value), wordCase, separator: separator);

  /// The lower-case words of [value] as a list, for example
  /// `['bin', 'iki', 'yüz', 'otuz', 'dört']` for 1234.
  static List<String> words(Object value) {
    final BigInt number;
    if (value is int) {
      number = BigInt.from(value);
    } else if (value is BigInt) {
      number = value;
    } else {
      throw ArgumentError.value(value, 'value', 'must be an int or a BigInt');
    }
    if (number.abs() > maxValue) {
      throw RangeError('$number is outside ±$maxValue');
    }
    if (number == BigInt.zero) return <String>['sıfır'];
    final result = <String>[if (number.isNegative) 'eksi'];
    // Split into groups of three digits, most significant first.
    final digits = number.abs().toString();
    final firstLength = digits.length % 3 == 0 ? 3 : digits.length % 3;
    final groups = <int>[int.parse(digits.substring(0, firstLength))];
    for (var i = firstLength; i < digits.length; i += 3) {
      groups.add(int.parse(digits.substring(i, i + 3)));
    }
    for (var i = 0; i < groups.length; i++) {
      final group = groups[i];
      if (group == 0) continue;
      final scale = groups.length - 1 - i;
      if (!(scale == 1 && group == 1)) result.addAll(_hundreds(group));
      if (scale > 0) result.add(_scales[scale]);
    }
    return result;
  }

  static List<String> _hundreds(int n) {
    final hundred = n ~/ 100;
    final ten = n ~/ 10 % 10;
    final one = n % 10;
    return <String>[
      if (hundred > 1) _ones[hundred],
      if (hundred > 0) 'yüz',
      if (ten > 0) _tens[ten],
      if (one > 0) _ones[one],
    ];
  }
}

/// Joins lower-case Turkish [words] with [separator] in [wordCase].
String applyWordCase(
  List<String> words,
  TurkishWordCase wordCase, {
  String separator = ' ',
}) {
  switch (wordCase) {
    case TurkishWordCase.lower:
      return words.join(separator);
    case TurkishWordCase.upper:
      return words.map(TurkishText.toUpperCase).join(separator);
    case TurkishWordCase.title:
      return words.map(TurkishText.capitalize).join(separator);
    case TurkishWordCase.sentence:
      return <String>[
        for (var i = 0; i < words.length; i++)
          i == 0 ? TurkishText.capitalize(words[i]) : words[i],
      ].join(separator);
  }
}
