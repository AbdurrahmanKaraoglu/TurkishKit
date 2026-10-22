import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkish_kit_flutter/turkish_kit_flutter.dart';

/// `'1.2|34'` or `'1.[23]4'` as a [TextEditingValue].
TextEditingValue v(String marked) {
  final int bar = marked.indexOf('|');
  if (bar >= 0) {
    return TextEditingValue(
      text: marked.replaceFirst('|', ''),
      selection: TextSelection.collapsed(offset: bar),
    );
  }
  final int start = marked.indexOf('[');
  final int end = marked.indexOf(']') - 1;
  return TextEditingValue(
    text: marked.replaceFirst('[', '').replaceFirst(']', ''),
    selection: TextSelection(baseOffset: start, extentOffset: end),
  );
}

String show(TextEditingValue value) {
  expect(value.selection.isCollapsed, isTrue);
  return value.text.replaceRange(
    value.selection.baseOffset,
    value.selection.baseOffset,
    '|',
  );
}

/// What the platform sends when the user types [input] over the selection.
TextEditingValue typed(TextEditingValue old, String input) {
  final TextSelection s = old.selection;
  return TextEditingValue(
    text: old.text.replaceRange(s.start, s.end, input),
    selection: TextSelection.collapsed(offset: s.start + input.length),
  );
}

TextEditingValue backspaced(TextEditingValue old) {
  final TextSelection s = old.selection;
  final int start = s.isCollapsed ? s.start - 1 : s.start;
  return TextEditingValue(
    text: old.text.replaceRange(start, s.end, ''),
    selection: TextSelection.collapsed(offset: start),
  );
}

TextEditingValue deleted(TextEditingValue old) {
  final TextSelection s = old.selection;
  final int end = s.isCollapsed ? s.end + 1 : s.end;
  return TextEditingValue(
    text: old.text.replaceRange(s.start, end, ''),
    selection: TextSelection.collapsed(offset: s.start),
  );
}

void main() {
  group('TurkishMoneyInputFormatter', () {
    final TurkishMoneyInputFormatter f = TurkishMoneyInputFormatter(
      const TurkishMoneyInputMask(symbol: '₺'),
    );
    String type(TextEditingValue old, String input) =>
        show(f.formatEditUpdate(old, typed(old, input)));

    test('typing, regrouping and the decimal key', () {
      TextEditingValue value = v('|');
      for (final String key in '1234.5'.split('')) {
        value = f.formatEditUpdate(value, typed(value, key));
      }
      expect(show(value), '1.234,5| ₺');
      expect(type(v('1.2|34 ₺'), '9'), '12.9|34 ₺');
      expect(type(v('1.234,5|6 ₺'), '7'), '1.234,5|6 ₺');
    });

    test('backspace and delete around separators', () {
      expect(
        show(f.formatEditUpdate(v('1.|234 ₺'), backspaced(v('1.|234 ₺')))),
        '|234 ₺',
      );
      expect(
        show(f.formatEditUpdate(v('1|.234 ₺'), deleted(v('1|.234 ₺')))),
        '1|34 ₺',
      );
      expect(
        show(f.formatEditUpdate(v('1.234 ₺|'), backspaced(v('1.234 ₺|')))),
        '123| ₺',
      );
    });

    test('selection replaced by a paste', () {
      expect(type(v('[1.234,56 ₺]'), '₺ 98.765,4'), '98.765,4| ₺');
      expect(type(v('[5 ₺]'), '1234.56'), '1.234,56| ₺');
    });

    test('a rejected edit returns the old value untouched', () {
      final TextEditingValue old = v('12|3 ₺');
      expect(identical(f.formatEditUpdate(old, typed(old, 'x')), old), isTrue);
    });

    test('reversed selections and an unfocused field', () {
      const TextEditingValue reversed = TextEditingValue(
        text: '1.234',
        selection: TextSelection(baseOffset: 5, extentOffset: 0),
      );
      final TurkishMoneyInputFormatter plain = TurkishMoneyInputFormatter();
      expect(
        show(
          plain.formatEditUpdate(
            reversed,
            const TextEditingValue(
              text: '7',
              selection: TextSelection.collapsed(offset: 1),
            ),
          ),
        ),
        '7|',
      );
      expect(
        plain
            .formatEditUpdate(
              TextEditingValue.empty,
              const TextEditingValue(text: '1234'),
            )
            .text,
        '1.234',
      );
    });
  });

  group('TurkishInputMaskFormatter', () {
    test('phone and IBAN', () {
      final TurkishInputMaskFormatter phone = TurkishInputMaskFormatter(
        TurkishInputMask.phone,
      );
      expect(
        show(
          phone.formatEditUpdate(
            TextEditingValue.empty,
            typed(v('|'), '5321234567'),
          ),
        ),
        '0532 123 45 67|',
      );
      final TurkishInputMaskFormatter iban = TurkishInputMaskFormatter(
        TurkishInputMask.iban,
      );
      expect(
        iban.formatEditUpdate(TextEditingValue.empty, v('tr330006|')).text,
        'TR33 0006',
      );
    });
  });

  group('TurkishMoneyController', () {
    test('reads and writes money and kuruş', () {
      final TurkishMoneyController c = TurkishMoneyController(
        money: TurkishMoney.lira(1250),
      );
      expect(c.text, '1.250,00 ₺');
      expect(c.kurus, 125000);
      c.kurus = 99;
      expect(c.text, '0,99 ₺');
      expect(c.selection, const TextSelection.collapsed(offset: 4));
      expect(c.money, TurkishMoney.fromKurus(99));
      c.money = null;
      expect(c.text, '');
      expect(c.kurus, isNull);
      expect(TurkishMoneyController.fromKurus(5).text, '0,05 ₺');
      expect(TurkishMoneyController.fromKurus(null).text, '');
      final TurkishMoneyController whole = TurkishMoneyController(
        mask: const TurkishMoneyInputMask(fractionDigits: 0),
      );
      expect(() => whole.kurus = 150, throwsArgumentError);
      whole.kurus = 120000;
      expect(whole.text, '1.200');
    });

    test('keeps the cursor before the symbol', () {
      final TurkishMoneyController c = TurkishMoneyController.fromKurus(1200);
      c.selection = TextSelection.collapsed(offset: c.text.length);
      expect(c.selection.baseOffset, c.text.length - 2);
      c.selection = const TextSelection(baseOffset: 0, extentOffset: 7);
      expect(c.selection.extentOffset, 7); // full selection is allowed
    });

    test('complete pads decimals', () {
      final TurkishMoneyController c = TurkishMoneyController()
        ..text = '1.234,5 ₺';
      c.complete();
      expect(c.text, '1.234,50 ₺');
      c.text = '-';
      c.complete();
      expect(c.text, '');
    });
  });
}
