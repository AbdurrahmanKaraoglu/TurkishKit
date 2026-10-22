import 'package:test/test.dart';
import 'package:turkish_kit/turkish_kit.dart';

/// Parses `'1.2|34'` (cursor) or `'1.[23]4'` (selection) into an edit value.
TurkishEditValue v(String marked) {
  final bar = marked.indexOf('|');
  if (bar >= 0) {
    final text = marked.replaceFirst('|', '');
    return (text: text, selectionStart: bar, selectionEnd: bar);
  }
  final start = marked.indexOf('[');
  final end = marked.indexOf(']') - 1;
  final text = marked.replaceFirst('[', '').replaceFirst(']', '');
  return (text: text, selectionStart: start, selectionEnd: end);
}

/// The edit value as `'1.2|34'`.
String show(TurkishEditValue value) {
  expect(value.selectionStart, value.selectionEnd, reason: 'collapsed');
  return value.text.replaceRange(
    value.selectionStart,
    value.selectionStart,
    '|',
  );
}

int _start(TurkishEditValue x) =>
    x.selectionStart < x.selectionEnd ? x.selectionStart : x.selectionEnd;
int _end(TurkishEditValue x) =>
    x.selectionStart < x.selectionEnd ? x.selectionEnd : x.selectionStart;

/// What a text field sends when the user types or pastes [input] over the
/// selection.
TurkishEditValue input(
  TurkishMoneyInputMask mask,
  TurkishEditValue old,
  String input,
) {
  final text = old.text.replaceRange(_start(old), _end(old), input);
  final cursor = _start(old) + input.length;
  return mask.apply(old, (
    text: text,
    selectionStart: cursor,
    selectionEnd: cursor,
  ));
}

/// Backspace: deletes the selection or the character before the cursor.
TurkishEditValue backspace(TurkishMoneyInputMask mask, TurkishEditValue old) {
  var start = _start(old);
  final end = _end(old);
  if (start == end) {
    if (start == 0) return old;
    start--;
  }
  final text = old.text.replaceRange(start, end, '');
  return mask.apply(old, (
    text: text,
    selectionStart: start,
    selectionEnd: start,
  ));
}

/// Forward delete: deletes the selection or the character after the cursor.
TurkishEditValue delete(TurkishMoneyInputMask mask, TurkishEditValue old) {
  final start = _start(old);
  var end = _end(old);
  if (start == end) {
    if (end == old.text.length) return old;
    end++;
  }
  final text = old.text.replaceRange(start, end, '');
  return mask.apply(old, (
    text: text,
    selectionStart: start,
    selectionEnd: start,
  ));
}

/// Types [keys] one character at a time, starting from [start].
String typeAll(TurkishMoneyInputMask mask, String keys, [String start = '|']) {
  var value = v(start);
  for (final key in keys.split('')) {
    value = input(mask, value, key);
  }
  return show(value);
}

void main() {
  const mask = TurkishMoneyInputMask();
  const lira = TurkishMoneyInputMask(symbol: '₺');

  group('typing', () {
    test('groups thousands as you type', () {
      expect(typeAll(mask, '1'), '1|');
      expect(typeAll(mask, '1234'), '1.234|');
      expect(typeAll(mask, '1234567'), '1.234.567|');
      expect(typeAll(mask, '1234,56'), '1.234,56|');
      expect(typeAll(mask, '1234567,5'), '1.234.567,5|');
    });

    test('a dot typed on its own is the decimal separator', () {
      expect(typeAll(mask, '1234.56'), '1.234,56|');
      expect(typeAll(mask, '12.5.'), '12,5|'); // second separator ignored
      expect(typeAll(mask, '12,,'), '12,|');
    });

    test('leading zeros and a bare comma', () {
      expect(typeAll(mask, '0'), '0|');
      expect(typeAll(mask, '00'), '0|');
      expect(typeAll(mask, '05'), '5|');
      expect(typeAll(mask, ','), '0,|');
      expect(typeAll(mask, ',5'), '0,5|');
      expect(typeAll(mask, '0,05'), '0,05|');
    });

    test('rejects a third decimal and other characters', () {
      expect(typeAll(mask, '1,234'), '1,23|');
      expect(typeAll(mask, '12a3'), '123|');
      expect(typeAll(mask, '1 2'), '12|');
      expect(typeAll(mask, '-5'), '5|'); // negative not allowed
    });

    test('symbol suffix stays after the cursor', () {
      expect(typeAll(lira, '1234,5'), '1.234,5| ₺');
      expect(typeAll(lira, ''), '|');
      expect(
        typeAll(const TurkishMoneyInputMask(symbol: 'TL'), '99'),
        '99| TL',
      );
    });

    test('typing in the middle keeps the cursor next to the digit', () {
      expect(show(input(mask, v('1.2|34'), '9')), '12.9|34');
      expect(show(input(mask, v('|234'), '1')), '1|.234');
      expect(show(input(mask, v('12|3'), '4')), '1.24|3');
      expect(show(input(mask, v('999.99|9'), '0')), '9.999.90|9');
      expect(show(input(lira, v('1.23|4 ₺'), '5')), '12.35|4 ₺');
      expect(show(input(mask, v('1.234,|5'), '6')), '1.234,6|5');
      expect(show(input(mask, v('1.234,5|6'), '7')), '1.234,5|6'); // full
    });

    test('typing over a selection', () {
      expect(show(input(mask, v('[1.234,56]'), '7')), '7|');
      expect(show(input(mask, v('1.[23]4'), '9')), '19|4');
      expect(show(input(lira, v('[1.234 ₺]'), '5')), '5| ₺');
    });
  });

  group('deleting', () {
    test('backspace removes digits and regroups', () {
      expect(show(backspace(mask, v('1.234|'))), '123|');
      expect(show(backspace(mask, v('12.34|5'))), '1.23|5');
      expect(show(backspace(mask, v('1|.234'))), '|234');
      expect(show(backspace(mask, v('1.234,5|6'))), '1.234,|6');
      expect(show(backspace(mask, v('5|'))), '|');
    });

    test('backspace right after a separator removes the digit before it', () {
      expect(show(backspace(mask, v('1.|234'))), '|234');
      expect(show(backspace(mask, v('12.|345'))), '1|.345');
      expect(show(backspace(mask, v('1.234.|567'))), '123|.567');
    });

    test('forward delete on a separator removes the digit after it', () {
      expect(show(delete(mask, v('1|.234'))), '1|34');
      expect(show(delete(mask, v('12|.345'))), '1.2|45');
      expect(show(delete(mask, v('1.2|34'))), '12|4');
    });

    test('backspace on the comma joins the decimals', () {
      expect(show(backspace(mask, v('12,|5'))), '12|5');
      expect(show(backspace(mask, v('1.234,|56'))), '123.4|56');
    });

    test('backspace on the symbol removes the last digit', () {
      expect(show(backspace(lira, v('1.234 ₺|'))), '123| ₺');
      expect(show(backspace(lira, v('1.234 |₺'))), '123| ₺');
      expect(show(backspace(lira, v('5| ₺'))), '|');
    });

    test('deleting a selection', () {
      expect(show(backspace(mask, v('[1.234,56]'))), '|');
      expect(show(backspace(mask, v('1.[234],56'))), '1|,56');
      expect(show(backspace(mask, v('1[.2]34'))), '1|34');
    });
  });

  group('pasting', () {
    test('accepts common spellings', () {
      for (final text in <String>[
        '1234.56',
        '1.234,56',
        '1234,56',
        '₺1.234,56',
        '1.234,56 ₺',
        '1 234,56',
        '1 234,56 TL',
        ' 1234.56 TRY ',
      ]) {
        expect(show(input(mask, v('|'), text)), '1.234,56|', reason: text);
      }
      expect(show(input(mask, v('|'), '1.234')), '1.234|'); // Turkish grouping
      expect(show(input(mask, v('|'), '1.234.567')), '1.234.567|');
      expect(show(input(mask, v('|'), '1234.5')), '1.234,5|');
      expect(show(input(lira, v('|'), '1234.56')), '1.234,56| ₺');
    });

    test('pasting into existing text', () {
      expect(show(input(mask, v('1|'), '234')), '1.234|');
      expect(show(input(mask, v('[1.234,56]'), '₺99,90')), '99,90|');
    });

    test('rounds extra decimals and rejects garbage', () {
      expect(show(input(mask, v('|'), '1234.567')), '1.234,57|');
      expect(show(input(mask, v('|'), '0,005')), '0,01|');
      expect(show(input(mask, v('12|'), 'abc')), '12|');
      expect(show(input(mask, v('|'), '1.23.456')), '|');
      expect(show(input(mask, v('12|'), '-5')), '12|');
    });
  });

  group('options', () {
    test('no decimals', () {
      const whole = TurkishMoneyInputMask(fractionDigits: 0, symbol: '₺');
      expect(typeAll(whole, '1234'), '1.234| ₺');
      expect(typeAll(whole, '12,5'), '125| ₺'); // comma ignored
      expect(typeAll(whole, '12.5'), '125| ₺');
      expect(show(input(whole, v('|'), '1.234,50')), '1.235| ₺');
      expect(show(input(whole, v('|'), '1234.49')), '1.234| ₺');
    });

    test('one decimal', () {
      const one = TurkishMoneyInputMask(fractionDigits: 1);
      expect(typeAll(one, '12,34'), '12,3|');
      expect(show(input(one, v('|'), '12,35')), '12,4|');
    });

    test('maximum value', () {
      final capped = TurkishMoneyInputMask(maxValue: TurkishMoney.lira(1000));
      expect(typeAll(capped, '1000'), '1.000|');
      expect(typeAll(capped, '10001'), '1.000|');
      expect(typeAll(capped, '1000,01'), '1.000,0|');
      expect(typeAll(capped, '999,99'), '999,99|');
      expect(show(input(capped, v('|'), '2.000')), '|');
    });

    test('negative amounts', () {
      const signed = TurkishMoneyInputMask(allowNegative: true, symbol: '₺');
      expect(typeAll(signed, '-'), '-|');
      expect(typeAll(signed, '-1234'), '-1.234| ₺');
      expect(typeAll(signed, '12-'), '-12| ₺'); // toggles
      expect(typeAll(signed, '12--'), '12| ₺');
      expect(show(input(signed, v('|1.234 ₺'), '-')), '-|1.234 ₺');
      expect(show(backspace(signed, v('-|1.234 ₺'))), '|1.234 ₺');
      expect(show(backspace(signed, v('-5| ₺'))), '-|');
      expect(show(input(signed, v('|'), '−1.234,5')), '-1.234,5| ₺');
    });
  });

  group('value', () {
    test('parse', () {
      expect(lira.parse('1.234,56 ₺'), TurkishMoney.fromKurus(123456));
      expect(mask.parse('1.234,'), TurkishMoney.fromKurus(123400));
      expect(mask.parse('0,5'), TurkishMoney.fromKurus(50));
      expect(mask.parse(''), isNull);
      expect(mask.parse('-'), isNull);
      expect(
        const TurkishMoneyInputMask(symbol: 'TL').parse('12 TL'),
        TurkishMoney.fromKurus(1200),
      );
    });

    test('format and complete', () {
      expect(lira.format(TurkishMoney.fromKurus(123450)), '1.234,50 ₺');
      expect(mask.format(TurkishMoney.fromKurus(-5)), '-0,05');
      expect(mask.format(null), '');
      const whole = TurkishMoneyInputMask(fractionDigits: 0);
      expect(whole.format(TurkishMoney.lira(1234)), '1.234');
      expect(
        () => whole.format(TurkishMoney.fromKurus(1250)),
        throwsArgumentError,
      );
      const one = TurkishMoneyInputMask(fractionDigits: 1);
      expect(one.format(TurkishMoney.fromKurus(1250)), '12,5');
      expect(lira.complete('1.234,5 ₺'), '1.234,50 ₺');
      expect(lira.complete('12, ₺'), '12,00 ₺');
      expect(lira.complete('-'), '');
      expect(lira.complete(''), '');
      expect(lira.maxCursor('12 ₺'), 2);
      expect(mask.maxCursor('12'), 2);
    });

    test('format and parse round-trip with TurkishMoney', () {
      for (final kurus in <int>[
        0,
        1,
        99,
        100,
        123456,
        100000000,
        999999999999,
      ]) {
        final money = TurkishMoney.fromKurus(kurus);
        expect(lira.parse(lira.format(money)), money);
        expect(lira.format(money), money.format());
      }
    });

    test('typed text parses to the typed amount', () {
      expect(
        lira.parse(typeAll(lira, '1234,5').replaceAll('|', '')),
        TurkishMoney.fromKurus(123450),
      );
    });

    test('equality', () {
      expect(const TurkishMoneyInputMask(symbol: '₺'), lira);
      expect(const TurkishMoneyInputMask(symbol: '₺').hashCode, lira.hashCode);
      expect(lira, isNot(mask));
      expect(
        TurkishMoneyInputMask(maxValue: TurkishMoney.lira(5)),
        TurkishMoneyInputMask(maxValue: TurkishMoney.lira(5)),
      );
    });

    test('selection-only changes pass through', () {
      final value = v('1.2|34');
      final moved = (text: '1.234', selectionStart: 0, selectionEnd: 5);
      expect(mask.apply(value, moved), moved);
    });
  });
}
