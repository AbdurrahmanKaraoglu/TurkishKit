// Edge cases found in the 0.1.1 review.
import 'package:test/test.dart';
import 'package:turkish_kit/turkish_kit.dart';

void main() {
  test('phone with a trunk 0 after the country code', () {
    for (final value in <String>[
      '+90 0532 123 45 67',
      '+90 (0532) 123 45 67',
      '0090 0532 123 45 67',
      '90 0532 123 45 67',
    ]) {
      expect(
        TurkishValidators.normalizePhone(value),
        '+905321234567',
        reason: value,
      );
    }
    expect(TurkishValidators.normalizePhone('+90 00532 123 45 67'), isNull);
    expect(TurkishValidators.normalizePhone('+90 0900 123 45 67'), isNotNull);
  });

  test('phone mask absorbs a country code typed digit by digit', () {
    expect(TurkishInputMask.phone.format('9'), '09');
    expect(TurkishInputMask.phone.format('905'), '05');
    expect(TurkishInputMask.phone.format('9053'), '053');
    expect(TurkishInputMask.phone.format('+90 532 123'), '0532 123');
    expect(
      TurkishInputMask.phone.format('+90 0532 123 45 67'),
      '0532 123 45 67',
    );
    expect(TurkishInputMask.phone.format('900 123 45 67'), '0900 123 45 67');
  });

  test('IBAN with dashes', () {
    expect(
      TurkishValidators.isValidIban('TR33-0006-1005-1978-6457-8413-26'),
      isTrue,
    );
    expect(TurkishValidators.normalizeIban('tr33 0006-1005'), 'TR3300061005');
  });

  test('number format above 1e21', () {
    expect(
      TurkishNumberFormat.format(1e21),
      '1.000.000.000.000.000.000.000,00',
    );
    expect(
      TurkishNumberFormat.format(-1e22, fractionDigits: 0),
      '-10.000.000.000.000.000.000.000',
    );
    expect(TurkishNumberFormat.format(1e20), '100.000.000.000.000.000.000,00');
  });

  test('number parsing: huge integers and consistent separators', () {
    expect(
      TurkishNumberFormat.parse('99.999.999.999.999.999.999'),
      closeTo(1e20, 1e6),
    );
    expect(TurkishNumberFormat.tryParse('1.234 567'), isNull);
    expect(TurkishNumberFormat.tryParse('1 234.567'), isNull);
    expect(TurkishNumberFormat.parse('1 234 567'), 1234567);
    expect(TurkishMoney.tryParse('1.234 567,00'), isNull);
    expect(
      TurkishMoney.parse('99.999.999.999.999.999.999,99').kurus,
      BigInt.parse('9999999999999999999999'),
    );
  });

  test('sorting: circumflex before case, everywhere in the string', () {
    final words = <String>['Kâhta', 'kâhta', 'Kahta', 'kahta']
      ..sort(TurkishText.compare);
    expect(words, <String>['kahta', 'Kahta', 'kâhta', 'Kâhta']);
    final towns = <String>['Balâ', 'bala', 'Bala']..sort(TurkishText.compare);
    expect(towns, <String>['bala', 'Bala', 'Balâ']);
  });

  test('money words near the limit', () {
    final limit = TurkishMoney.fromKurusBigInt(
      TurkishNumberWords.maxValue * BigInt.from(100) + BigInt.from(99),
    );
    expect(limit.toWords(), startsWith('Dokuz Yüz Doksan Dokuz Desilyon'));
    expect(limit.toWords(), endsWith('Türk Lirası Doksan Dokuz Kuruş'));
    expect(
      TurkishMoney.fromKurusBigInt(-limit.kurus).toWords(),
      startsWith('Eksi Dokuz Yüz'),
    );
    expect(
      TurkishMoney.fromKurus(100000000000000).toWords(),
      'Bir Trilyon Türk Lirası',
    );
    expect(TurkishMoney.fromNum(-0.0).isNegative, isFalse);
    expect(TurkishMoney.parse('-0,004').toWords(), 'Sıfır Türk Lirası');
    expect(TurkishMoney.parse('-0,005').toWords(), 'Eksi Bir Kuruş');
  });

  test('holiday range ends cleanly', () {
    final lastDay = DateTime(2035, 12, 31);
    expect(TurkishHolidays.isBusinessDay(lastDay), lastDay.weekday <= 5);
    expect(
      TurkishHolidays.addBusinessDays(DateTime(2035, 12, 24), 1),
      DateTime(2035, 12, 25),
    );
    expect(() => TurkishHolidays.addBusinessDays(lastDay, 1), throwsRangeError);
    expect(
      () => TurkishHolidays.addBusinessDays(DateTime(2020, 1, 1), -1),
      throwsRangeError,
    );
  });
}
