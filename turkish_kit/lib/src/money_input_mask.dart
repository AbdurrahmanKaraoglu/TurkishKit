import 'grouping.dart';
import 'money.dart';

/// A text with its selection, as an input formatter sees it. In Flutter this
/// is `TextEditingValue.text` and `TextEditingValue.selection`.
typedef TurkishEditValue = ({
  String text,
  int selectionStart,
  int selectionEnd,
});

/// As-you-type formatting for a Turkish money field: `1.234,56` (with an
/// optional ` ₺` suffix), without depending on Flutter.
///
/// [apply] takes the text before and after an edit and returns the
/// formatted text with the cursor where the user expects it:
///
/// * digits typed or deleted anywhere keep the cursor next to them, even when
///   thousands separators appear or disappear;
/// * backspace (or delete) on a `.` separator or on the symbol removes the
///   digit next to it instead of doing nothing;
/// * `,` starts the decimals; a `.` typed on its own is also taken as the
///   decimal separator, because many numeric keyboards only have a dot;
/// * pasted text may be `1234.56`, `1.234,56`, `₺1.234,56`, `1 234,56 TL`
///   and similar;
/// * edits that would exceed [fractionDigits] or [maxValue] are rejected (the
///   old value is kept); typing `-` toggles the sign when [allowNegative].
///
/// Numbers are grouped and parsed with the same rules as [TurkishMoney] and
/// `TurkishNumberFormat`. For Flutter, use `TurkishMoneyInputFormatter` from
/// the `turkish_kit_flutter` package, or wrap [apply] in a
/// `TextInputFormatter` yourself.
class TurkishMoneyInputMask {
  /// Creates a mask.
  ///
  /// * [fractionDigits]: 2 (kuruş, the default), 1 or 0 (whole lira).
  /// * [maxValue]: the largest absolute amount that can be entered.
  /// * [allowNegative]: whether `-` may be typed.
  /// * [symbol]: shown after the number with a space (for example `'₺'` or
  ///   `'TL'`); empty for none.
  const TurkishMoneyInputMask({
    this.fractionDigits = 2,
    this.maxValue,
    this.allowNegative = false,
    this.symbol = '',
  }) : assert(fractionDigits >= 0 && fractionDigits <= 2);

  /// The number of decimals that can be entered (0-2).
  final int fractionDigits;

  /// The largest absolute amount that can be entered, or `null` for no limit.
  final TurkishMoney? maxValue;

  /// Whether negative amounts can be entered.
  final bool allowNegative;

  /// The currency symbol shown after the number, or `''`.
  final String symbol;

  @override
  bool operator ==(Object other) =>
      other is TurkishMoneyInputMask &&
      other.fractionDigits == fractionDigits &&
      other.maxValue == maxValue &&
      other.allowNegative == allowNegative &&
      other.symbol == symbol;

  @override
  int get hashCode =>
      Object.hash(fractionDigits, maxValue, allowNegative, symbol);

  /// The text shown after the number: `' ₺'`, or `''` without a [symbol].
  String get suffix => symbol.isEmpty ? '' : ' $symbol';

  /// The formatted result of changing [oldValue] into [newValue]. The
  /// returned selection is collapsed (a cursor). Returns [oldValue]
  /// unchanged if the edit is not allowed.
  TurkishEditValue apply(TurkishEditValue oldValue, TurkishEditValue newValue) {
    final oldText = oldValue.text;
    final newText = newValue.text;
    if (oldText == newText) return newValue;

    // Find what was removed and inserted. The edit ends at the new cursor.
    final newLength = newText.length;
    final oldLength = oldText.length;
    final cursor = _clamp(
      newValue.selectionStart > newValue.selectionEnd
          ? newValue.selectionStart
          : newValue.selectionEnd,
      newLength,
    );
    var common = 0;
    while (common < newLength - cursor &&
        common < oldLength &&
        newText.codeUnitAt(newLength - 1 - common) ==
            oldText.codeUnitAt(oldLength - 1 - common)) {
      common++;
    }
    final tail = common;
    final prefixLimit = newLength - tail < oldLength - tail
        ? newLength - tail
        : oldLength - tail;
    var head = 0;
    while (head < prefixLimit &&
        newText.codeUnitAt(head) == oldText.codeUnitAt(head)) {
      head++;
    }
    final removed = oldText.substring(head, oldLength - tail);
    final inserted = newText.substring(head, newLength - tail);

    final before = _units(oldText.substring(0, head));
    final after = _units(oldText.substring(oldLength - tail));
    final isPaste = inserted.length > 1;
    final typed = _insertedUnits(inserted, isPaste);
    if (typed == null) return oldValue;

    if (inserted.isEmpty && removed.isNotEmpty && _units(removed).isEmpty) {
      // Only a separator, space or the symbol was deleted: delete the digit
      // next to it, otherwise the formatting would put it right back.
      final oldStart = oldValue.selectionStart < oldValue.selectionEnd
          ? oldValue.selectionStart
          : oldValue.selectionEnd;
      final oldEnd = oldValue.selectionStart < oldValue.selectionEnd
          ? oldValue.selectionEnd
          : oldValue.selectionStart;
      final isForwardDelete = oldStart == oldEnd && oldStart == head;
      if (isForwardDelete) {
        if (after.isNotEmpty) after.removeAt(0);
      } else if (before.isNotEmpty) {
        before.removeLast();
      }
    }

    final result = _build(
      <String>[...before, ...typed, ...after],
      before.length + typed.length,
      isPaste,
    );
    return result ?? oldValue;
  }

  /// The amount in [text], or `null` if it is empty or incomplete (`'-'`).
  /// Accepts the field's own format and anything [TurkishMoney.parse] does.
  TurkishMoney? parse(String text) {
    var t = text.trim();
    if (symbol.isNotEmpty && t.endsWith(symbol)) {
      t = t.substring(0, t.length - symbol.length).trim();
    }
    if (t.endsWith(',')) t = t.substring(0, t.length - 1);
    if (t.isEmpty || t == '-') return null;
    return TurkishMoney.tryParse(t);
  }

  /// [money] as the field shows it: `'1.234,50 ₺'`; `''` for `null`.
  ///
  /// Throws an [ArgumentError] if [money] has more decimals than
  /// [fractionDigits] allows (for example 12,50 with no decimals).
  String format(TurkishMoney? money) {
    if (money == null) return '';
    final kurus = money.kurusPart;
    if ((fractionDigits == 0 && kurus != 0) ||
        (fractionDigits == 1 && kurus % 10 != 0)) {
      throw ArgumentError.value(
        money,
        'money',
        'has more than $fractionDigits decimals',
      );
    }
    final full = money.format(symbol: '');
    final number = fractionDigits == 2
        ? full
        : fractionDigits == 1
        ? full.substring(0, full.length - 1)
        : full.substring(0, full.length - 3);
    return '$number$suffix';
  }

  /// [text] in its final form: decimals padded (`1.234,5` → `1.234,50`), an
  /// incomplete `-` or `,` cleared. Call it when the field loses focus.
  String complete(String text) {
    final money = parse(text);
    if (money == null) return '';
    return format(money);
  }

  /// The last offset the cursor may take in [text] (before the suffix).
  int maxCursor(String text) => suffix.isNotEmpty && text.endsWith(suffix)
      ? text.length - suffix.length
      : text.length;

  /// Rebuilds the text from [units] (digits, `,` and `-`); [cursorUnits] of
  /// them are before the cursor. Returns `null` if the result is not allowed.
  TurkishEditValue? _build(List<String> units, int cursorUnits, bool isPaste) {
    final items = <(String, bool)>[
      for (var i = 0; i < units.length; i++) (units[i], i < cursorUnits),
    ];
    final minus = items.where((item) => item.$1 == '-').length;
    final negative = minus.isOdd;
    items.removeWhere((item) => item.$1 == '-');
    if (negative && !allowNegative) return null;

    final comma = items.indexWhere((item) => item.$1 == ',');
    final integer = comma < 0 ? items : items.sublist(0, comma);
    final fraction = comma < 0
        ? <(String, bool)>[]
        : items.sublist(comma + 1).where((item) => item.$1 != ',').toList();
    while (integer.length > 1 && integer.first.$1 == '0') {
      integer.removeAt(0);
    }
    if (integer.isEmpty && comma >= 0) integer.add(('0', items[comma].$2));

    final intDigits = integer.map((item) => item.$1).join();
    var fracDigits = fraction.map((item) => item.$1).join();

    if (intDigits.isEmpty) {
      final text = negative ? '-' : '';
      return (
        text: text,
        selectionStart: text.length,
        selectionEnd: text.length,
      );
    }

    if (comma >= 0 && fractionDigits == 0 && !isPaste) return null;
    if (fracDigits.length > fractionDigits) {
      if (!isPaste) return null;
      // Pasted with more decimals than allowed: round half up, cursor at end.
      final rounded = _round('$intDigits.$fracDigits', negative);
      if (rounded == null) return null;
      final text = format(rounded);
      final end = maxCursor(text);
      return (text: text, selectionStart: end, selectionEnd: end);
    }

    final kurus =
        BigInt.parse(intDigits) * BigInt.from(100) +
        BigInt.parse(fracDigits.padRight(2, '0'));
    final max = maxValue;
    if (max != null && kurus > max.kurus.abs()) return null;
    if (fractionDigits == 0) fracDigits = '';

    final sign = negative ? '-' : '';
    final number =
        groupThousands(intDigits) +
        (comma >= 0 && fractionDigits > 0 ? ',$fracDigits' : '');
    final text = '$sign$number$suffix';

    final kept = <(String, bool)>[
      ...integer,
      if (comma >= 0 && fractionDigits > 0) ...<(String, bool)>[
        items[comma],
        ...fraction,
      ],
    ];
    final unitsBefore = kept.where((item) => item.$2).length;
    var offset = sign.length;
    var counted = 0;
    for (var i = 0; i < number.length && counted < unitsBefore; i++) {
      if (number.codeUnitAt(i) != 0x2E) counted++; // skip '.' separators
      offset = sign.length + i + 1;
    }
    return (text: text, selectionStart: offset, selectionEnd: offset);
  }

  TurkishMoney? _round(String decimal, bool negative) {
    var money = TurkishMoney.fromDecimalString(decimal);
    if (fractionDigits < 2) {
      final unit = BigInt.from(fractionDigits == 1 ? 10 : 100);
      final rounded = (money.kurus + unit ~/ BigInt.two) ~/ unit * unit;
      money = TurkishMoney.fromKurusBigInt(rounded);
    }
    final max = maxValue;
    if (max != null && money.kurus > max.kurus.abs()) return null;
    return negative ? -money : money;
  }

  /// The meaningful characters of formatted text: digits, `,` and `-`.
  List<String> _units(String text) => <String>[
    for (final unit in text.codeUnits)
      if ((unit >= 0x30 && unit <= 0x39) || unit == 0x2C || unit == 0x2D)
        String.fromCharCode(unit),
  ];

  /// The units of newly typed or pasted [text], or `null` to reject it.
  List<String>? _insertedUnits(String text, bool isPaste) {
    if (text.isEmpty) return <String>[];
    if (!isPaste) {
      final unit = text.codeUnitAt(0);
      if (unit >= 0x30 && unit <= 0x39) return <String>[text];
      if (unit == 0x2C || unit == 0x2E) {
        // Many numeric keyboards send '.' instead of ','.
        return fractionDigits > 0 ? <String>[','] : null;
      }
      if (unit == 0x2D || unit == 0x2212) {
        return allowNegative ? <String>['-'] : null;
      }
      return null;
    }
    var t = text.replaceAll(RegExp('[\\s  ]'), '');
    if (symbol.isNotEmpty) t = t.replaceAll(symbol, '');
    t = t
        .replaceAll(RegExp('₺|TL|TRY', caseSensitive: false), '')
        .replaceAll('−', '-');
    if (!RegExp(r'^[0-9.,\-]+$').hasMatch(t)) return null;
    if (t.contains(',')) {
      t = t.replaceAll('.', ''); // Turkish: dots group thousands
    } else {
      // Dots that form valid Turkish grouping (1.234, 1.234.567) group
      // thousands; a single other dot is a decimal point (1234.5, 1234.567).
      if (RegExp(r'^-?\d{1,3}(\.\d{3})+$').hasMatch(t)) {
        t = t.replaceAll('.', '');
      } else if ('.'.allMatches(t).length == 1) {
        t = t.replaceAll('.', ',');
      } else if (t.contains('.')) {
        return null;
      }
    }
    if (t.contains('-') && !allowNegative) return null;
    return _units(t);
  }

  static int _clamp(int value, int max) =>
      value < 0 ? 0 : (value > max ? max : value);
}
