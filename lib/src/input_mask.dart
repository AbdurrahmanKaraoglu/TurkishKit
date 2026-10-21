/// The result of [TurkishInputMask.apply]: the formatted text and where the
/// cursor should be.
typedef TurkishMaskResult = ({String text, int cursor});

/// As-you-type formatting for Turkish numbers, without depending on Flutter.
///
/// A mask pattern uses `#` for a digit; every other character is a literal
/// that is inserted automatically. Anything the user types that is not a
/// digit is dropped, and trailing literals are only added once the next digit
/// arrives, so backspace works naturally.
///
/// In Flutter, wrap it in a `TextInputFormatter` (see the package README):
///
/// ```dart
/// final r = TurkishInputMask.phone.apply(newValue.text, newValue.selection.end);
/// return TextEditingValue(
///   text: r.text,
///   selection: TextSelection.collapsed(offset: r.cursor),
/// );
/// ```
class TurkishInputMask {
  /// Creates a mask from a [pattern].
  ///
  /// [digitFilter] may rewrite the typed digits before masking; [phone] uses
  /// it to drop a typed leading `0`, `90` or `0090`.
  const TurkishInputMask(this.pattern, {String Function(String)? digitFilter})
      : _digitFilter = digitFilter;

  /// `0532 123 45 67`. A typed leading `0`, `+90` or `0090` is absorbed.
  static const TurkishInputMask phone =
      TurkishInputMask('0### ### ## ##', digitFilter: _phoneDigits);

  /// `TR33 0006 1005 1978 6457 8413 26`. `TR` is inserted automatically.
  static const TurkishInputMask iban =
      TurkishInputMask('TR## #### #### #### #### #### ##');

  /// 11-digit T.C. kimlik numarası, digits only.
  static const TurkishInputMask tcKimlik = TurkishInputMask('###########');

  /// 10-digit vergi kimlik numarası, digits only.
  static const TurkishInputMask vergiKimlik = TurkishInputMask('##########');

  /// A date as `GG.AA.YYYY` (day.month.year).
  static const TurkishInputMask date = TurkishInputMask('##.##.####');

  /// The mask pattern; `#` is a digit placeholder.
  final String pattern;

  final String Function(String)? _digitFilter;

  /// The number of digits the pattern holds.
  int get maxDigits => '#'.allMatches(pattern).length;

  /// Formats [input]; same as `apply(input).text`.
  String format(String input) => apply(input).text;

  /// Formats [input] and maps [cursor] (an offset in [input], default: the
  /// end) to the matching offset in the result.
  TurkishMaskResult apply(String input, [int? cursor]) {
    final end = cursor == null || cursor > input.length ? input.length : cursor;
    var digits = StringBuffer();
    var digitsBeforeCursor = 0;
    for (var i = 0; i < input.length; i++) {
      final unit = input.codeUnitAt(i);
      if (unit >= 0x30 && unit <= 0x39) {
        digits.writeCharCode(unit);
        if (i < end) digitsBeforeCursor++;
      }
    }
    var digitText = digits.toString();
    final filter = _digitFilter;
    if (filter != null) {
      final filtered = filter(digitText);
      final removed = digitText.length - filtered.length;
      digitsBeforeCursor =
          digitsBeforeCursor - removed < 0 ? 0 : digitsBeforeCursor - removed;
      digitText = filtered;
    }
    digits = StringBuffer();
    var used = 0;
    var outCursor = -1;
    for (var p = 0; p < pattern.length && used < digitText.length; p++) {
      if (pattern.codeUnitAt(p) == 0x23) {
        digits.write(digitText[used]);
        used++;
        if (used == digitsBeforeCursor) outCursor = digits.length;
      } else {
        digits.write(pattern[p]);
      }
    }
    final text = digits.toString();
    if (digitsBeforeCursor == 0) {
      outCursor = 0;
    } else if (outCursor < 0) {
      outCursor = text.length;
    }
    return (text: text, cursor: outCursor);
  }
}

String _phoneDigits(String digits) {
  if (digits.startsWith('0090')) return digits.substring(4);
  if (digits.startsWith('90') && digits.length > 10) {
    return digits.substring(2);
  }
  if (digits.startsWith('0')) return digits.substring(1);
  return digits;
}
