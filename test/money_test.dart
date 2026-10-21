import 'package:test/test.dart';
import 'package:turkish_kit/turkish_kit.dart';

String lower(Object n) =>
    TurkishNumberWords.convert(n, wordCase: TurkishWordCase.lower);

void main() {
  group('TurkishNumberWords', () {
    test('small numbers and Turkish special cases', () {
      final expected = <int, String>{
        0: 'sıfır',
        1: 'bir',
        9: 'dokuz',
        10: 'on',
        11: 'on bir',
        19: 'on dokuz',
        20: 'yirmi',
        45: 'kırk beş',
        60: 'altmış',
        99: 'doksan dokuz',
        100: 'yüz',
        101: 'yüz bir',
        200: 'iki yüz',
        999: 'dokuz yüz doksan dokuz',
        1000: 'bin',
        1001: 'bin bir',
        1100: 'bin yüz',
        1234: 'bin iki yüz otuz dört',
        2000: 'iki bin',
        10000: 'on bin',
        11000: 'on bir bin',
        100000: 'yüz bin',
        101000: 'yüz bir bin',
        999999: 'dokuz yüz doksan dokuz bin dokuz yüz doksan dokuz',
        1000000: 'bir milyon',
        1001000: 'bir milyon bin',
        1000001: 'bir milyon bir',
        2500000: 'iki milyon beş yüz bin',
        1000000000: 'bir milyar',
        1000000000000: 'bir trilyon',
        1000000000000000: 'bir katrilyon',
      };
      expected.forEach((n, words) => expect(lower(n), words, reason: '$n'));
    });

    test('negative numbers and int range', () {
      expect(lower(-7), 'eksi yedi');
      expect(lower(-1000), 'eksi bin');
      expect(
        lower(9223372036854775807),
        'dokuz kentilyon iki yüz yirmi üç katrilyon üç yüz yetmiş iki trilyon '
        'otuz altı milyar sekiz yüz elli dört milyon yedi yüz yetmiş beş bin '
        'sekiz yüz yedi',
      );
    });

    test('BigInt up to the desilyon range', () {
      expect(lower(BigInt.from(10).pow(33)), 'bir desilyon');
      expect(lower(BigInt.from(10).pow(21) * BigInt.two), 'iki seksilyon');
      expect(lower(-TurkishNumberWords.maxValue),
          startsWith('eksi dokuz yüz doksan dokuz desilyon'));
      expect(() => lower(TurkishNumberWords.maxValue + BigInt.one),
          throwsRangeError);
      expect(() => lower(1.5), throwsArgumentError);
    });

    test('word cases and separators', () {
      expect(TurkishNumberWords.convert(1234), 'Bin İki Yüz Otuz Dört');
      expect(TurkishNumberWords.convert(1234, wordCase: TurkishWordCase.upper),
          'BİN İKİ YÜZ OTUZ DÖRT');
      expect(
          TurkishNumberWords.convert(1234, wordCase: TurkishWordCase.sentence),
          'Bin iki yüz otuz dört');
      expect(TurkishNumberWords.convert(61, separator: ''), 'AltmışBir');
      expect(TurkishNumberWords.words(31), <String>['otuz', 'bir']);
    });
  });

  group('TurkishMoney parsing', () {
    test('Turkish notation', () {
      expect(TurkishMoney.parse('1.234,56').kurus, BigInt.from(123456));
      expect(TurkishMoney.parse('1234,5').kurus, BigInt.from(123450));
      expect(TurkishMoney.parse('1.234').kurus, BigInt.from(123400));
      expect(TurkishMoney.parse('0,99').kurus, BigInt.from(99));
      expect(TurkishMoney.parse(',5').kurus, BigInt.from(50));
      expect(TurkishMoney.parse('1 234 567,00').kurus, BigInt.from(123456700));
      expect(TurkishMoney.parse('-1.234,56 ₺').kurus, BigInt.from(-123456));
      expect(TurkishMoney.parse('₺1.234,56').kurus, BigInt.from(123456));
      expect(TurkishMoney.parse('1.234,56 TL').kurus, BigInt.from(123456));
      expect(TurkishMoney.parse('15 try').kurus, BigInt.from(1500));
      expect(TurkishMoney.parse('+3').kurus, BigInt.from(300));
      expect(TurkishMoney.parse('−3,10').kurus, BigInt.from(-310));
    });

    test('invalid Turkish notation', () {
      for (final text in <String>[
        '',
        '1,2,3',
        '12.34',
        '1.2345',
        'abc',
        '1.234.5',
        '1,',
        '-',
        '1..234'
      ]) {
        expect(TurkishMoney.tryParse(text), isNull, reason: text);
        expect(() => TurkishMoney.parse(text), throwsFormatException,
            reason: text);
      }
    });

    test('machine decimals', () {
      expect(
          TurkishMoney.fromDecimalString('1234.50').kurus, BigInt.from(123450));
      expect(TurkishMoney.fromDecimalString('-0.5').kurus, BigInt.from(-50));
      expect(TurkishMoney.fromDecimalString('.07').kurus, BigInt.from(7));
      expect(TurkishMoney.fromDecimalString('12').kurus, BigInt.from(1200));
      expect(TurkishMoney.fromDecimalString('99999999999999999999.99').kurus,
          BigInt.parse('9999999999999999999999'));
      expect(
          () => TurkishMoney.fromDecimalString('1,5'), throwsFormatException);
      expect(() => TurkishMoney.fromDecimalString('.'), throwsFormatException);
    });

    test('rounding to kuruş', () {
      TurkishMoney p(String t, TurkishRounding r) =>
          TurkishMoney.fromDecimalString(t, rounding: r);
      expect(p('1.005', TurkishRounding.halfUp).kurus, BigInt.from(101));
      expect(p('-1.005', TurkishRounding.halfUp).kurus, BigInt.from(-101));
      expect(p('1.0049999', TurkishRounding.halfUp).kurus, BigInt.from(100));
      expect(p('1.005', TurkishRounding.halfEven).kurus, BigInt.from(100));
      expect(p('1.015', TurkishRounding.halfEven).kurus, BigInt.from(102));
      expect(p('1.0051', TurkishRounding.halfEven).kurus, BigInt.from(101));
      expect(p('1.009', TurkishRounding.truncate).kurus, BigInt.from(100));
      expect(p('0.995', TurkishRounding.halfUp).kurus, BigInt.from(100));
      expect(p('1.000', TurkishRounding.strict).kurus, BigInt.from(100));
      expect(() => p('1.001', TurkishRounding.strict), throwsFormatException);
      expect(TurkishMoney.parse('2,675').kurus, BigInt.from(268));
    });

    test('fromNum avoids binary surprises', () {
      expect(TurkishMoney.fromNum(2.675).kurus, BigInt.from(268));
      expect(TurkishMoney.fromNum(0.1 + 0.2).kurus, BigInt.from(30));
      expect(TurkishMoney.fromNum(1234.5).kurus, BigInt.from(123450));
      expect(TurkishMoney.fromNum(42).kurus, BigInt.from(4200));
      expect(TurkishMoney.fromNum(1e-7).kurus, BigInt.zero);
      expect(() => TurkishMoney.fromNum(double.nan), throwsArgumentError);
      expect(() => TurkishMoney.fromNum(1e16), throwsArgumentError);
    });

    test('constructors and arithmetic', () {
      expect(TurkishMoney.lira(12, 5).kurus, BigInt.from(1205));
      expect(TurkishMoney.lira(-12, 5).kurus, BigInt.from(-1205));
      expect(() => TurkishMoney.lira(1, 100), throwsRangeError);
      final a = TurkishMoney.fromKurus(150);
      final b = TurkishMoney.fromKurus(275);
      expect((a + b).kurus, BigInt.from(425));
      expect((a - b).kurus, BigInt.from(-125));
      expect((-a).kurus, BigInt.from(-150));
      expect(a < b, isTrue);
      expect(b > a, isTrue);
      expect(a, TurkishMoney.parse('1,50'));
      expect(a.hashCode, TurkishMoney.parse('1,50').hashCode);
      expect(<TurkishMoney>[b, a]..sort(), <TurkishMoney>[a, b]);
      expect(TurkishMoney.zero.isZero, isTrue);
      expect(TurkishMoney.fromKurus(-5).abs().kurus, BigInt.from(5));
    });
  });

  group('TurkishMoney output', () {
    test('format', () {
      expect(TurkishMoney.fromKurus(123456).format(), '1.234,56 ₺');
      expect(TurkishMoney.fromKurus(-123456).format(), '-1.234,56 ₺');
      expect(TurkishMoney.fromKurus(5).format(), '0,05 ₺');
      expect(TurkishMoney.fromKurus(100).format(symbol: 'TL'), '1,00 TL');
      expect(TurkishMoney.fromKurus(100).format(symbolFirst: true), '₺1,00');
      expect(
          TurkishMoney.fromKurus(123400)
              .format(hideZeroKurus: true, symbol: ''),
          '1.234');
      expect(TurkishMoney.fromKurus(123456789).toString(), '1.234.567,89 ₺');
      expect(TurkishMoney.fromKurus(-5).toDecimalString(), '-0.05');
      expect(TurkishMoney.fromKurus(123450).toDecimalString(), '1234.50');
    });

    test('words', () {
      expect(TurkishMoney.fromDecimalString('1234.50').toWords(),
          'Bin İki Yüz Otuz Dört Türk Lirası Elli Kuruş');
      expect(TurkishMoney.zero.toWords(), 'Sıfır Türk Lirası');
      expect(TurkishMoney.fromKurus(50).toWords(), 'Elli Kuruş');
      expect(TurkishMoney.fromKurus(100).toWords(), 'Bir Türk Lirası');
      expect(TurkishMoney.fromKurus(100).toWords(showZeroKurus: true),
          'Bir Türk Lirası Sıfır Kuruş');
      expect(TurkishMoney.fromKurus(-150).toWords(),
          'Eksi Bir Türk Lirası Elli Kuruş');
      expect(TurkishMoney.fromKurus(-1).toWords(), 'Eksi Bir Kuruş');
      expect(TurkishMoney.fromKurus(100000000000).toWords(),
          'Bir Milyar Türk Lirası');
      expect(
          TurkishMoney.fromKurus(123450)
              .toWords(wordCase: TurkishWordCase.upper),
          'BİN İKİ YÜZ OTUZ DÖRT TÜRK LİRASI ELLİ KURUŞ');
      expect(
          TurkishMoney.fromKurus(123450)
              .toWords(wordCase: TurkishWordCase.lower),
          'bin iki yüz otuz dört türk lirası elli kuruş');
      expect(
        TurkishMoney.fromKurus(123450).toWords(
            wordCase: TurkishWordCase.sentence, currency: 'TL', subunit: 'Kr'),
        'Bin iki yüz otuz dört TL elli Kr',
      );
      final tooBig = TurkishMoney.fromKurusBigInt(
          (TurkishNumberWords.maxValue + BigInt.one) * BigInt.from(100));
      expect(tooBig.toWords, throwsRangeError);
    });

    test('invoice text', () {
      final amount = TurkishMoney.fromKurus(123450);
      expect(amount.toInvoiceText(),
          'Yalnız #Bin İki Yüz Otuz Dört Türk Lirası Elli Kuruş#');
      expect(amount.toInvoiceText(separator: ''),
          'Yalnız #BinİkiYüzOtuzDörtTürkLirasıElliKuruş#');
      expect(
          amount.toInvoiceText(
              wordCase: TurkishWordCase.upper, currency: 'TL', subunit: 'KR'),
          'YALNIZ #BİN İKİ YÜZ OTUZ DÖRT TL ELLİ KR#');
      expect(
          TurkishMoney.fromKurus(7)
              .toInvoiceText(prefix: 'YALNIZ:', delimiter: ''),
          'YALNIZ: Yedi Kuruş');
      expect(
          TurkishMoney.zero.toInvoiceText(prefix: ''), '#Sıfır Türk Lirası#');
    });
  });

  group('TurkishNumberFormat', () {
    test('formatInteger', () {
      expect(TurkishNumberFormat.formatInteger(0), '0');
      expect(TurkishNumberFormat.formatInteger(999), '999');
      expect(TurkishNumberFormat.formatInteger(1000), '1.000');
      expect(TurkishNumberFormat.formatInteger(-1234567), '-1.234.567');
      expect(
          TurkishNumberFormat.formatInteger(
              BigInt.parse('12345678901234567890')),
          '12.345.678.901.234.567.890');
      expect(TurkishNumberFormat.formatInteger(1234567, groupSeparator: ' '),
          '1 234 567');
      expect(() => TurkishNumberFormat.formatInteger('1'), throwsArgumentError);
    });

    test('format', () {
      expect(TurkishNumberFormat.format(1234.5), '1.234,50');
      expect(
          TurkishNumberFormat.format(1234.567, fractionDigits: 1), '1.234,6');
      expect(TurkishNumberFormat.format(-0.5), '-0,50');
      expect(TurkishNumberFormat.format(-0.001), '0,00');
      expect(
          TurkishNumberFormat.format(1234567, fractionDigits: 0), '1.234.567');
      expect(TurkishNumberFormat.format(1234567.891, grouping: false),
          '1234567,89');
      expect(() => TurkishNumberFormat.format(double.infinity),
          throwsArgumentError);
    });

    test('parse', () {
      expect(TurkishNumberFormat.parse('1.234,56'), 1234.56);
      expect(TurkishNumberFormat.parse('1.234'), 1234);
      expect(TurkishNumberFormat.parse('1.234'), isA<int>());
      expect(TurkishNumberFormat.parse('-0,5'), -0.5);
      expect(TurkishNumberFormat.parse('  42 '), 42);
      expect(TurkishNumberFormat.parse('1 234,5'), 1234.5);
      expect(TurkishNumberFormat.tryParse('1.23'), isNull);
      expect(TurkishNumberFormat.tryParse('1,234.56'), isNull);
      expect(TurkishNumberFormat.tryParse(''), isNull);
      expect(() => TurkishNumberFormat.parse('x'), throwsFormatException);
    });

    test('round trip', () {
      for (final value in <num>[0, 1, 12.5, 999.99, 1000, 1234567.89, -42.1]) {
        expect(TurkishNumberFormat.parse(TurkishNumberFormat.format(value)),
            closeTo(value, 1e-9));
      }
    });
  });
}
