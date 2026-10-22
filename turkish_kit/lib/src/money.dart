import 'grouping.dart';
import 'number_words.dart';
import 'text.dart';

/// How amounts with more than two decimals are rounded to kuruş.
enum TurkishRounding {
  /// Half away from zero: 1,005 → 1,01 and -1,005 → -1,01 (the default,
  /// as on Turkish invoices).
  halfUp,

  /// Half to even (banker's rounding): 1,005 → 1,00 and 1,015 → 1,02.
  halfEven,

  /// Drop the extra decimals: 1,009 → 1,00.
  truncate,

  /// Throw a [FormatException] if there are more than two decimals.
  strict,
}

/// Formats and parses numbers in Turkish notation: `.` groups thousands and
/// `,` is the decimal separator (`1.234.567,89`).
abstract final class TurkishNumberFormat {
  /// Formats an [int] or [BigInt] with thousands separators:
  /// `1234567` → `'1.234.567'`.
  static String formatInteger(Object value, {String groupSeparator = '.'}) {
    final BigInt number;
    if (value is int) {
      number = BigInt.from(value);
    } else if (value is BigInt) {
      number = value;
    } else {
      throw ArgumentError.value(value, 'value', 'must be an int or a BigInt');
    }
    final grouped = groupThousands(number.abs().toString(), groupSeparator);
    return number.isNegative ? '-$grouped' : grouped;
  }

  /// Formats [value] with [fractionDigits] decimals: `1234.5` →
  /// `'1.234,50'`.
  ///
  /// Doubles are rounded with [double.toStringAsFixed], which works on the
  /// binary value (`2.675` is stored as 2.67499…). For money use
  /// [TurkishMoney], which is exact.
  static String format(
    num value, {
    int fractionDigits = 2,
    bool grouping = true,
  }) {
    if (!value.isFinite) {
      throw ArgumentError.value(value, 'value', 'must be finite');
    }
    // toStringAsFixed switches to exponent notation from 1e21; such doubles
    // have no fraction, so BigInt gives their exact integer digits.
    final fixed = value.abs() >= 1e21
        ? '${BigInt.from(value.abs())}'
              '${fractionDigits > 0 ? '.${'0' * fractionDigits}' : ''}'
        : value.abs().toStringAsFixed(fractionDigits);
    final dot = fixed.indexOf('.');
    final integer = dot < 0 ? fixed : fixed.substring(0, dot);
    final fraction = dot < 0 ? '' : fixed.substring(dot + 1);
    final negative = value < 0 && RegExp('[1-9]').hasMatch(fixed);
    final body =
        (grouping ? groupThousands(integer, '.') : integer) +
        (fraction.isEmpty ? '' : ',$fraction');
    return negative ? '-$body' : body;
  }

  /// Parses a Turkish-formatted number: `'1.234,56'` → 1234.56,
  /// `'-1234'` → -1234, `'0,5'` → 0.5.
  ///
  /// Thousands separators are optional but, if present, must group exactly
  /// three digits and use one kind of separator (`.`, a space, or a no-break
  /// space). A plain `1.234` is therefore one thousand two hundred
  /// thirty-four, not 1.234. Returns an [int] when there is no fraction part
  /// and the value fits in an [int], otherwise a [double]. Returns `null` if
  /// [text] is not a valid number.
  static num? tryParse(String text) {
    final parts = parseParts(text);
    if (parts == null) return null;
    final sign = parts.negative ? '-' : '';
    if (parts.fraction.isEmpty) {
      return int.tryParse('$sign${parts.integer}') ??
          double.parse('$sign${parts.integer}');
    }
    return double.parse('$sign${parts.integer}.${parts.fraction}');
  }

  /// Like [tryParse] but throws a [FormatException] for invalid input.
  static num parse(String text) =>
      tryParse(text) ?? (throw FormatException('Invalid number', text));

  /// Splits a Turkish-formatted number into sign, integer digits (without
  /// separators) and fraction digits, or returns `null` if invalid. Used by
  /// [tryParse] and [TurkishMoney.parse] to stay exact.
  static ({bool negative, String integer, String fraction})? parseParts(
    String text,
  ) {
    final match = _numberPattern.firstMatch(text.trim());
    if (match == null) return null;
    final integer = match[2]!.replaceAll(RegExp('[.   ]'), '');
    final fraction = match[4] ?? '';
    if (integer.isEmpty && fraction.isEmpty) return null;
    return (
      negative: match[1] != null && match[1] != '+',
      integer: integer.isEmpty ? '0' : integer,
      fraction: fraction,
    );
  }
}

final RegExp _numberPattern = RegExp(
  r'^([+\-\u2212])?\s*'
  // Either plain digits, or groups of three with one consistent separator.
  r'(\d{1,3}([. \u00A0\u202F])\d{3}(?:\3\d{3})*|\d*)'
  r'(?:,(\d+))?$',
);

final BigInt _hundred = BigInt.from(100);

/// An exact Turkish lira amount, stored as a whole number of kuruş
/// (1 TL = 100 kuruş), so there are no floating-point errors.
///
/// ```dart
/// final total = TurkishMoney.parse('1.234,50 ₺');
/// total.format();        // '1.234,50 ₺'
/// total.toWords();       // 'Bin İki Yüz Otuz Dört Türk Lirası Elli Kuruş'
/// total.toInvoiceText(); // 'Yalnız #Bin İki Yüz Otuz Dört Türk Lirası Elli Kuruş#'
/// ```
class TurkishMoney implements Comparable<TurkishMoney> {
  /// An amount of [kurus] (1 TL = 100 kuruş).
  TurkishMoney.fromKurus(int kurus) : kurus = BigInt.from(kurus);

  /// An amount of [kurus] given as a [BigInt].
  const TurkishMoney.fromKurusBigInt(this.kurus);

  /// [lira] lira and [kurusPart] kuruş (0-99). The sign of [lira] applies to
  /// the whole amount; use [fromKurus] for amounts between -1 and 0 TL.
  factory TurkishMoney.lira(int lira, [int kurusPart = 0]) {
    if (kurusPart < 0 || kurusPart > 99) {
      throw RangeError.range(kurusPart, 0, 99, 'kurusPart');
    }
    final whole = BigInt.from(lira) * _hundred;
    return TurkishMoney.fromKurusBigInt(
      lira < 0
          ? whole - BigInt.from(kurusPart)
          : whole + BigInt.from(kurusPart),
    );
  }

  /// Zero lira.
  static final TurkishMoney zero = TurkishMoney.fromKurusBigInt(BigInt.zero);

  /// Parses a Turkish-formatted amount such as `'1.234,56'`, `'1234,5 TL'`,
  /// `'₺1.234'` or `'-0,99 ₺'`. A `₺`, `TL` or `TRY` before or after the
  /// number is ignored. Extra decimals are rounded with [rounding].
  ///
  /// Throws a [FormatException] for invalid input.
  static TurkishMoney parse(
    String text, {
    TurkishRounding rounding = TurkishRounding.halfUp,
  }) {
    final cleaned = text
        .trim()
        .replaceFirst(RegExp(r'^(₺|TL|TRY)\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'\s*(₺|TL|TRY)$', caseSensitive: false), '');
    final parts = TurkishNumberFormat.parseParts(cleaned);
    if (parts == null) throw FormatException('Invalid amount', text);
    return _fromParts(
      parts.negative,
      parts.integer,
      parts.fraction,
      rounding,
      text,
    );
  }

  /// Like [parse] but returns `null` for invalid input.
  static TurkishMoney? tryParse(
    String text, {
    TurkishRounding rounding = TurkishRounding.halfUp,
  }) {
    try {
      return parse(text, rounding: rounding);
    } on FormatException {
      return null;
    }
  }

  /// Parses a machine-format decimal such as `'1234.50'` or `'-0.5'` (a `.`
  /// as decimal separator, no thousands separators), as found in JSON, APIs
  /// and databases.
  ///
  /// Throws a [FormatException] for invalid input.
  static TurkishMoney fromDecimalString(
    String text, {
    TurkishRounding rounding = TurkishRounding.halfUp,
  }) {
    final match = RegExp(r'^([+-])?(\d*)(?:\.(\d+))?$').firstMatch(text.trim());
    if (match == null || (match[2]!.isEmpty && match[3] == null)) {
      throw FormatException('Invalid decimal', text);
    }
    return _fromParts(
      match[1] == '-',
      match[2]!.isEmpty ? '0' : match[2]!,
      match[3] ?? '',
      rounding,
      text,
    );
  }

  /// Converts a [num]. A [double] is taken by its shortest decimal form
  /// (`2.675` is treated as 2,675 and rounds to 2,68 with
  /// [TurkishRounding.halfUp]); prefer [fromKurus] or a string where you can.
  ///
  /// Throws an [ArgumentError] for non-finite values and for doubles of
  /// 10^15 or more, where a double cannot hold kuruş precision.
  static TurkishMoney fromNum(
    num value, {
    TurkishRounding rounding = TurkishRounding.halfUp,
  }) {
    if (value is int) {
      return TurkishMoney.fromKurusBigInt(BigInt.from(value) * _hundred);
    }
    if (!value.isFinite || value.abs() >= 1e15) {
      throw ArgumentError.value(value, 'value', 'must be finite and < 1e15');
    }
    var text = value.toString();
    if (text.contains('e')) text = value.toStringAsFixed(20);
    return fromDecimalString(text, rounding: rounding);
  }

  static TurkishMoney _fromParts(
    bool negative,
    String integer,
    String fraction,
    TurkishRounding rounding,
    String source,
  ) {
    final padded = fraction.padRight(2, '0');
    var kurus =
        BigInt.parse(integer) * _hundred + BigInt.parse(padded.substring(0, 2));
    final rest = padded.substring(2);
    if (rest.isNotEmpty && rest.contains(RegExp('[1-9]'))) {
      switch (rounding) {
        case TurkishRounding.strict:
          throw FormatException('More than two decimals', source);
        case TurkishRounding.truncate:
          break;
        case TurkishRounding.halfUp:
          if (rest.codeUnitAt(0) >= 0x35) kurus += BigInt.one;
        case TurkishRounding.halfEven:
          final first = rest.codeUnitAt(0) - 0x30;
          final exactHalf =
              first == 5 && !rest.substring(1).contains(RegExp('[1-9]'));
          if (first > 5 ||
              (first == 5 && !exactHalf) ||
              (exactHalf && kurus.isOdd)) {
            kurus += BigInt.one;
          }
      }
    }
    return TurkishMoney.fromKurusBigInt(negative ? -kurus : kurus);
  }

  /// The amount in kuruş (negative for negative amounts).
  final BigInt kurus;

  /// Whether the amount is below zero.
  bool get isNegative => kurus.isNegative;

  /// Whether the amount is exactly zero.
  bool get isZero => kurus == BigInt.zero;

  /// The whole lira part, without sign: 1234 for 1.234,56 and -1.234,56.
  BigInt get liraPart => kurus.abs() ~/ _hundred;

  /// The kuruş part (0-99), without sign: 56 for 1.234,56 and -1.234,56.
  int get kurusPart => (kurus.abs() % _hundred).toInt();

  /// The absolute value.
  TurkishMoney abs() => TurkishMoney.fromKurusBigInt(kurus.abs());

  /// Sum of two amounts.
  TurkishMoney operator +(TurkishMoney other) =>
      TurkishMoney.fromKurusBigInt(kurus + other.kurus);

  /// Difference of two amounts.
  TurkishMoney operator -(TurkishMoney other) =>
      TurkishMoney.fromKurusBigInt(kurus - other.kurus);

  /// The negated amount.
  TurkishMoney operator -() => TurkishMoney.fromKurusBigInt(-kurus);

  /// Whether this amount is less than [other].
  bool operator <(TurkishMoney other) => kurus < other.kurus;

  /// Whether this amount is greater than [other].
  bool operator >(TurkishMoney other) => kurus > other.kurus;

  /// The amount as a machine-format decimal string: `'1234.56'`, `'-0.05'`.
  String toDecimalString() =>
      '${isNegative ? '-' : ''}$liraPart.${kurusPart.toString().padLeft(2, '0')}';

  /// Formats the amount in Turkish notation: `'1.234,56 ₺'`.
  ///
  /// Set [symbol] to `'TL'` or `''`, and [symbolFirst] to write `₺1.234,56`.
  /// With [hideZeroKurus], `1.234,00` is shown as `1.234`.
  String format({
    String symbol = '₺',
    bool symbolFirst = false,
    bool hideZeroKurus = false,
    String groupSeparator = '.',
  }) {
    final number =
        groupThousands(liraPart.toString(), groupSeparator) +
        (hideZeroKurus && kurusPart == 0
            ? ''
            : ',${kurusPart.toString().padLeft(2, '0')}');
    final sign = isNegative ? '-' : '';
    if (symbol.isEmpty) return '$sign$number';
    return symbolFirst ? '$sign$symbol$number' : '$sign$number $symbol';
  }

  /// The amount in words: `'Bin İki Yüz Otuz Dört Türk Lirası Elli Kuruş'`.
  ///
  /// * [currency] / [subunit]: the unit names (for example `'TL'` / `'Kr'`).
  /// * Zero lira with kuruş gives only the kuruş (`'Elli Kuruş'`); zero
  ///   gives `'Sıfır Türk Lirası'`. With [showZeroKurus], `'Sıfır Kuruş'` is
  ///   appended to whole amounts.
  /// * Negative amounts start with `Eksi`.
  /// * [separator] joins the words; use `''` for the run-together style
  ///   some invoices use.
  ///
  /// Throws a [RangeError] above [TurkishNumberWords.maxValue] lira.
  String toWords({
    TurkishWordCase wordCase = TurkishWordCase.title,
    String currency = 'Türk Lirası',
    String subunit = 'Kuruş',
    bool showZeroKurus = false,
    String separator = ' ',
  }) => _joinTokens(
    _wordTokens(currency, subunit, showZeroKurus),
    wordCase,
    separator,
  );

  /// The amount in the invoice style `Yalnız #...#`:
  /// `'Yalnız #Bin İki Yüz Otuz Dört Türk Lirası Elli Kuruş#'`.
  ///
  /// [prefix] and [delimiter] can be changed (for example
  /// `prefix: 'YALNIZ:'`, `delimiter: ''`); [separator] `''` writes the
  /// words together (`#BinİkiYüzOtuzDörtTürkLirasıElliKuruş#`). The other
  /// parameters are as in [toWords].
  String toInvoiceText({
    String prefix = 'Yalnız',
    String delimiter = '#',
    TurkishWordCase wordCase = TurkishWordCase.title,
    String currency = 'Türk Lirası',
    String subunit = 'Kuruş',
    bool showZeroKurus = false,
    String separator = ' ',
  }) {
    final amount = toWords(
      wordCase: wordCase,
      currency: currency,
      subunit: subunit,
      showZeroKurus: showZeroKurus,
      separator: separator,
    );
    final casedPrefix = prefix.isEmpty
        ? ''
        : '${_caseFixed(prefix, wordCase)} ';
    return '$casedPrefix$delimiter$amount$delimiter';
  }

  List<_Token> _wordTokens(
    String currency,
    String subunit,
    bool showZeroKurus,
  ) {
    final tokens = <_Token>[if (isNegative) const _Token('eksi')];
    final lira = liraPart;
    final kr = kurusPart;
    if (lira > BigInt.zero || kr == 0) {
      tokens
        ..addAll(TurkishNumberWords.words(lira).map(_Token.new))
        ..addAll(_unitTokens(currency));
    }
    if (kr > 0 || showZeroKurus) {
      tokens
        ..addAll(TurkishNumberWords.words(kr).map(_Token.new))
        ..addAll(_unitTokens(subunit));
    }
    return tokens;
  }

  @override
  int compareTo(TurkishMoney other) => kurus.compareTo(other.kurus);

  @override
  bool operator ==(Object other) =>
      other is TurkishMoney && other.kurus == kurus;

  @override
  int get hashCode => kurus.hashCode;

  @override
  String toString() => format();
}

/// A word of an amount; [fixed] words (unit names) keep the spelling the
/// caller gave them in title and sentence case.
class _Token {
  const _Token(this.word, {this.fixed = false});

  final String word;
  final bool fixed;
}

Iterable<_Token> _unitTokens(String unit) => <_Token>[
  for (final word in unit.split(RegExp(r'\s+')))
    if (word.isNotEmpty) _Token(word, fixed: true),
];

String _caseFixed(String word, TurkishWordCase wordCase) => switch (wordCase) {
  TurkishWordCase.lower => TurkishText.toLowerCase(word),
  TurkishWordCase.upper => TurkishText.toUpperCase(word),
  TurkishWordCase.title || TurkishWordCase.sentence => word,
};

String _joinTokens(
  List<_Token> tokens,
  TurkishWordCase wordCase,
  String separator,
) {
  final words = <String>[];
  for (var i = 0; i < tokens.length; i++) {
    final token = tokens[i];
    if (token.fixed) {
      words.add(_caseFixed(token.word, wordCase));
    } else if (wordCase == TurkishWordCase.sentence) {
      words.add(i == 0 ? TurkishText.capitalize(token.word) : token.word);
    } else {
      words.add(applyWordCase(<String>[token.word], wordCase));
    }
  }
  return words.join(separator);
}
