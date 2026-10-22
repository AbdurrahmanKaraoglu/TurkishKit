// Every code example in README.md, with the result the README promises.
// Keep this file in sync when the README changes.
import 'package:test/test.dart';
import 'package:turkish_kit/turkish_kit.dart';

void main() {
  test('validators', () {
    expect(TurkishValidators.isValidTcKimlik('10000000146'), isTrue);
    expect(TurkishValidators.isValidVergiKimlik('1234567890'), isTrue);
    expect(TurkishValidators.isValidTaxNumber('1234567890'), isTrue);
    expect(
      TurkishValidators.isValidIban('tr33 0006 1005 1978 6457 8413 26'),
      isTrue,
    );
    expect(
      TurkishValidators.formatIban('TR330006100519786457841326'),
      'TR33 0006 1005 1978 6457 8413 26',
    );
    expect(
      TurkishValidators.normalizePhone('(0532) 123 45 67'),
      '+905321234567',
    );
    expect(TurkishValidators.normalizePhone('0532 123 45 67'), '+905321234567');
    expect(TurkishValidators.formatPhone('+905321234567'), '0532 123 45 67');
    expect(
      TurkishValidators.phoneType('0212 123 45 67'),
      TurkishPhoneType.landline,
    );
  });

  test('form validators and masks', () {
    expect(TurkishFormValidators.tcKimlik()('10000000146'), isNull);
    expect(
      TurkishFormValidators.iban(messages: TurkishValidationMessages.en)('x'),
      TurkishValidationMessages.en.iban,
    );
    expect(
      TurkishFormValidators.phone(required: false, message: 'Telefon?')('1'),
      'Telefon?',
    );
    expect(TurkishInputMask.phone.format('05321234567'), '0532 123 45 67');
    expect(
      TurkishInputMask.iban.format('TR330006100519786457841326'),
      'TR33 0006 1005 1978 6457 8413 26',
    );
  });

  test('money', () {
    final total = TurkishMoney.parse('1.234,50 ₺');
    expect(TurkishMoney.fromDecimalString('1234.50'), total);
    expect(TurkishMoney.fromKurus(123450), total);
    expect(total.format(), '1.234,50 ₺');
    expect(total.toWords(), 'Bin İki Yüz Otuz Dört Türk Lirası Elli Kuruş');
    expect(
      total.toInvoiceText(),
      'Yalnız #Bin İki Yüz Otuz Dört Türk Lirası Elli Kuruş#',
    );
    expect(
      total.toInvoiceText(separator: '', wordCase: TurkishWordCase.upper),
      'YALNIZ #BİNİKİYÜZOTUZDÖRTTÜRKLİRASIELLİKURUŞ#',
    );
    expect(
      total.toWords(
        currency: 'TL',
        subunit: 'Kr',
        wordCase: TurkishWordCase.sentence,
      ),
      'Bin iki yüz otuz dört TL elli Kr',
    );
    expect(TurkishMoney.parse('0').toWords(), 'Sıfır Türk Lirası');
    expect(TurkishMoney.parse('0,50').toWords(), 'Elli Kuruş');
    expect(
      TurkishMoney.parse('-1,50').toWords(),
      'Eksi Bir Türk Lirası Elli Kuruş',
    );
    expect(TurkishMoney.parse('1,005').format(symbol: ''), '1,01');
    expect(TurkishMoney.fromNum(2.675).format(symbol: ''), '2,68');
    expect(TurkishNumberWords.convert(1001000), 'Bir Milyon Bin');
    expect(TurkishNumberFormat.format(1234.5), '1.234,50');
    expect(TurkishNumberFormat.parse('1.234,56'), 1234.56);
    expect(TurkishNumberFormat.parse('1.234'), 1234);
    expect(TurkishNumberFormat.tryParse('1.23'), isNull);
  });

  test('text', () {
    expect('istanbul'.toTurkishUpperCase(), 'İSTANBUL');
    expect('istanbul'.toUpperCase(), 'ISTANBUL');
    expect('IĞDIR'.toTurkishLowerCase(), 'ığdır');
    expect('ışık ılık süt iç'.toTurkishTitleCase(), 'Işık Ilık Süt İç');
    expect('  IĞDIR  Kâhta '.toSearchKey(), 'igdir kahta');
    expect('Kağıthane'.turkishContains('kagit'), isTrue);
    final names = <String>['zeytin', 'çanta', 'Çorum', 'cam', 'ılık', 'iğne'];
    names.sort(TurkishText.compare);
    expect(names, <String>['cam', 'çanta', 'Çorum', 'ılık', 'iğne', 'zeytin']);
    final ties = <String>['Kâhta', 'kâhta', 'Kahta', 'kahta']
      ..sort(TurkishText.compare);
    expect(ties, <String>['kahta', 'Kahta', 'kâhta', 'Kâhta']);
  });

  test('provinces', () {
    expect(TurkishProvinces.all.length, 81);
    expect(TurkishProvinces.districtCount, 973);
    final ist = TurkishProvinces.byPlateCode(34)!;
    expect(ist.name, 'İstanbul');
    expect(ist.districts.take(2), <String>['Adalar', 'Arnavutköy']);
    expect(ist.districts, hasLength(39));
    expect(ist.isMetropolitan, isTrue);
    expect(TurkishProvinces.byName('sanliurfa')?.plateCode, 63);
    expect(TurkishProvinces.search('kar').take(4).map((p) => p.name), <String>[
      'Kars',
      'Karaman',
      'Karabük',
      'Afyonkarahisar',
    ]);
    expect(
      TurkishProvinces.provincesWithDistrict('Ereğli').map((p) => p.name),
      <String>['Konya', 'Zonguldak'],
    );
  });

  test('holidays', () {
    final y2026 = TurkishHolidays.forYear(2026);
    expect(y2026, hasLength(17));
    expect(y2026.first.nameTr, 'Yılbaşı');
    expect(y2026.last.nameTr, 'Cumhuriyet Bayramı');
    expect(
      TurkishHolidays.on(DateTime(2026, 5, 27)).map((h) => h.nameTr),
      <String>['Kurban Bayramı (1. Gün)'],
    );
    expect(TurkishHolidays.isHoliday(DateTime(2026, 10, 29)), isTrue);
    expect(TurkishHolidays.isHalfDay(DateTime(2026, 10, 28)), isTrue);
    expect(TurkishHolidays.isBusinessDay(DateTime(2026, 10, 22)), isTrue);
    expect(
      TurkishHolidays.addBusinessDays(DateTime(2026, 5, 26), 1),
      DateTime(2026, 6, 1),
    );
    expect(
      TurkishHolidays.businessDaysBetween(
        DateTime(2026, 10, 1),
        DateTime(2026, 11, 1),
      ),
      21,
    );
    final calendar = TurkishBusinessCalendar(
      halfDayIsBusinessDay: false,
      extraHolidays: [DateTime(2026, 5, 25)],
      extraBusinessDays: [DateTime(2026, 5, 23)],
    );
    expect(calendar.isBusinessDay(DateTime(2026, 5, 23)), isTrue);
    expect(calendar.isBusinessDay(DateTime(2026, 5, 25)), isFalse);
    expect(calendar.isBusinessDay(DateTime(2026, 5, 26)), isFalse);
    expect(TurkishHolidays.firstYear, 2020);
    expect(TurkishHolidays.lastYear, 2035);
  });
}
