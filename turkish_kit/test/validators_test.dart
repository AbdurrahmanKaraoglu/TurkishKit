import 'dart:math';

import 'package:test/test.dart';
import 'package:turkish_kit/turkish_kit.dart';

/// Independent T.C. kimlik generator, written from the published rules.
String _makeTc(List<int> first9) {
  final odd = first9[0] + first9[2] + first9[4] + first9[6] + first9[8];
  final even = first9[1] + first9[3] + first9[5] + first9[7];
  final d10 = ((odd * 7 - even) % 10 + 10) % 10;
  final d11 = (first9.reduce((a, b) => a + b) + d10) % 10;
  return '${first9.join()}$d10$d11';
}

/// Independent VKN check digit (the "t == 9" formulation of the GİB rule).
int _vknCheck(String first9) {
  var sum = 0;
  for (var i = 0; i < 9; i++) {
    final t = (int.parse(first9[i]) + 9 - i) % 10;
    sum += t == 9 ? 9 : (t * pow(2, 9 - i).toInt()) % 9;
  }
  return (10 - sum % 10) % 10;
}

/// Independent IBAN check digits with BigInt arithmetic.
String _makeIban(String bban) {
  final numeric = '${bban}292700'; // T=29, R=27, check digits 00
  final check = 98 - (BigInt.parse(numeric) % BigInt.from(97)).toInt();
  return 'TR${check.toString().padLeft(2, '0')}$bban';
}

void main() {
  final random = Random(2429);

  group('isValidTcKimlik', () {
    test('accepts known valid numbers', () {
      expect(TurkishValidators.isValidTcKimlik('10000000146'), isTrue);
      expect(TurkishValidators.isValidTcKimlik(' 100 000 001 46 '), isTrue);
    });

    test('accepts generated numbers and rejects any changed digit', () {
      for (var n = 0; n < 500; n++) {
        final first9 = <int>[
          1 + random.nextInt(9),
          for (var i = 0; i < 8; i++) random.nextInt(10),
        ];
        final tc = _makeTc(first9);
        expect(TurkishValidators.isValidTcKimlik(tc), isTrue, reason: tc);
        final pos = 9 + random.nextInt(2);
        final wrong = (int.parse(tc[pos]) + 1 + random.nextInt(9)) % 10;
        final changed = tc.replaceRange(pos, pos + 1, '$wrong');
        expect(
          TurkishValidators.isValidTcKimlik(changed),
          isFalse,
          reason: changed,
        );
      }
    });

    test('rejects bad input', () {
      for (final value in <String?>[
        null, '', '1000000014', '100000001460', '00000000146', //
        '1000000014a', '10000000147', '12345678901', '11111111111x',
      ]) {
        expect(
          TurkishValidators.isValidTcKimlik(value),
          isFalse,
          reason: value,
        );
      }
    });

    test('11111111110 is valid by checksum', () {
      // Well known: passes the algorithm (often used as a test number).
      expect(TurkishValidators.isValidTcKimlik('11111111110'), isTrue);
    });
  });

  group('isValidVergiKimlik', () {
    test('matches an independent implementation', () {
      for (var n = 0; n < 1000; n++) {
        final first9 = List<int>.generate(9, (_) => random.nextInt(10)).join();
        final check = _vknCheck(first9);
        expect(TurkishValidators.isValidVergiKimlik('$first9$check'), isTrue);
        final wrong = (check + 1 + random.nextInt(9)) % 10;
        expect(TurkishValidators.isValidVergiKimlik('$first9$wrong'), isFalse);
      }
    });

    test('handles the shifted == 9 rule', () {
      // First digit 0 -> (0 + 9) % 10 = 9, which must count as 9, not 0.
      const first9 = '000000000';
      expect(
        TurkishValidators.isValidVergiKimlik('$first9${_vknCheck(first9)}'),
        isTrue,
      );
    });

    test('rejects bad input', () {
      for (final value in <String?>[
        null,
        '',
        '123456789',
        '12345678901',
        'abcdefghij',
      ]) {
        expect(TurkishValidators.isValidVergiKimlik(value), isFalse);
      }
    });

    test('isValidTaxNumber accepts VKN or TCKN', () {
      final vkn = '123456789${_vknCheck('123456789')}';
      expect(TurkishValidators.isValidTaxNumber(vkn), isTrue);
      expect(TurkishValidators.isValidTaxNumber('10000000146'), isTrue);
      expect(TurkishValidators.isValidTaxNumber('10000000147'), isFalse);
    });
  });

  group('IBAN', () {
    const registryExample = 'TR330006100519786457841326'; // SWIFT IBAN registry

    test('accepts the registry example in any spelling', () {
      expect(TurkishValidators.isValidIban(registryExample), isTrue);
      expect(
        TurkishValidators.isValidIban('tr33 0006 1005 1978 6457 8413 26'),
        isTrue,
      );
      expect(
        TurkishValidators.isValidIban(' TR33\t0006 1005 1978 6457 8413 26 '),
        isTrue,
      );
    });

    test('matches an independent BigInt implementation', () {
      for (var n = 0; n < 300; n++) {
        final bban = List<int>.generate(22, (_) => random.nextInt(10)).join();
        final iban = _makeIban(bban);
        expect(TurkishValidators.isValidIban(iban), isTrue, reason: iban);
        final pos = 4 + random.nextInt(22);
        final changed = iban.replaceRange(
          pos,
          pos + 1,
          '${(int.parse(iban[pos]) + 1) % 10}',
        );
        expect(
          TurkishValidators.isValidIban(changed),
          isFalse,
          reason: changed,
        );
      }
    });

    test('rejects other countries, lengths and characters', () {
      for (final value in <String?>[
        null, '', 'DE89370400440532013000', 'TR33000610051978645784132', //
        'TR3300061005197864578413261', 'TR33000610051978645784132X',
        'XX330006100519786457841326',
        'TR340006100519786457841326',
      ]) {
        expect(TurkishValidators.isValidIban(value), isFalse, reason: value);
      }
    });

    test('formats, normalizes and reads the bank code', () {
      expect(
        TurkishValidators.formatIban('tr330006100519786457841326'),
        'TR33 0006 1005 1978 6457 8413 26',
      );
      expect(TurkishValidators.formatIban('TR34'), isNull);
      expect(TurkishValidators.normalizeIban(' tr33 0006 '), 'TR330006');
      expect(TurkishValidators.ibanBankCode(registryExample), '00061');
      expect(TurkishValidators.ibanBankCode('nope'), isNull);
    });
  });

  group('phone', () {
    test('normalizes every common spelling to E.164', () {
      for (final value in <String>[
        '05321234567', '5321234567', '0532 123 45 67', '(0532) 123 45 67', //
        '532-123-45-67', '+90 532 123 45 67', '+905321234567', '00905321234567',
        '905321234567', '0532.123.45.67',
      ]) {
        expect(
          TurkishValidators.normalizePhone(value),
          '+905321234567',
          reason: value,
        );
      }
    });

    test('classifies numbers', () {
      expect(
        TurkishValidators.phoneType('05321234567'),
        TurkishPhoneType.mobile,
      );
      expect(
        TurkishValidators.phoneType('0212 123 45 67'),
        TurkishPhoneType.landline,
      );
      expect(
        TurkishValidators.phoneType('0312 123 45 67'),
        TurkishPhoneType.landline,
      );
      expect(
        TurkishValidators.phoneType('0462 123 45 67'),
        TurkishPhoneType.landline,
      );
      expect(
        TurkishValidators.phoneType('0850 123 45 67'),
        TurkishPhoneType.nonGeographic,
      );
      expect(
        TurkishValidators.phoneType('0800 123 45 67'),
        TurkishPhoneType.nonGeographic,
      );
      expect(TurkishValidators.isValidMobilePhone('0212 123 45 67'), isFalse);
      expect(TurkishValidators.isValidLandlinePhone('0212 123 45 67'), isTrue);
    });

    test('rejects invalid numbers', () {
      for (final value in <String?>[
        null, '', '0532123456', '053212345678', '0123 456 78 90', //
        '0612 123 45 67', '0700 123 45 67', '+44 20 7946 0958',
        '0532 123 45 6a',
        '444 1 444', '+',
      ]) {
        expect(TurkishValidators.isValidPhone(value), isFalse, reason: value);
      }
    });

    test('formats for display', () {
      expect(TurkishValidators.formatPhone('+905321234567'), '0532 123 45 67');
      expect(
        TurkishValidators.formatPhone('5321234567', international: true),
        '+90 532 123 45 67',
      );
      expect(TurkishValidators.formatPhone('123'), isNull);
      expect(
        TurkishValidators.nationalPhoneNumber('0 (212) 123 45 67'),
        '2121234567',
      );
    });
  });

  group('TurkishFormValidators', () {
    test('returns null for valid and a message for invalid input', () {
      final validator = TurkishFormValidators.tcKimlik();
      expect(validator('10000000146'), isNull);
      expect(validator('10000000147'), TurkishValidationMessages.tr.tcKimlik);
      expect(validator(''), TurkishValidationMessages.tr.required);
      expect(validator(null), TurkishValidationMessages.tr.required);
      expect(validator('   '), TurkishValidationMessages.tr.required);
    });

    test('optional fields accept empty values', () {
      final validator = TurkishFormValidators.iban(required: false);
      expect(validator(''), isNull);
      expect(validator(null), isNull);
      expect(validator('TR00'), TurkishValidationMessages.tr.iban);
    });

    test('custom messages and languages', () {
      expect(
        TurkishFormValidators.phone(messages: TurkishValidationMessages.en)(
          '1',
        ),
        TurkishValidationMessages.en.phone,
      );
      expect(
        TurkishFormValidators.mobilePhone(message: 'Cep no?')('02121234567'),
        'Cep no?',
      );
      expect(TurkishFormValidators.landlinePhone()('02121234567'), isNull);
      expect(
        TurkishFormValidators.vergiKimlik()('1'),
        TurkishValidationMessages.tr.vergiKimlik,
      );
      expect(TurkishFormValidators.taxNumber()('10000000146'), isNull);
    });

    test('combine returns the first error', () {
      final validator = TurkishFormValidators.combine(<TurkishFieldValidator>[
        TurkishFormValidators.phone(),
        (value) => value!.startsWith('0850') ? 'No 850' : null,
      ]);
      expect(validator(''), TurkishValidationMessages.tr.required);
      expect(validator('08501234567'), 'No 850');
      expect(validator('05321234567'), isNull);
    });
  });
}
