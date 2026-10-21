import 'package:test/test.dart';
import 'package:turkish_kit/turkish_kit.dart';

void main() {
  group('casing', () {
    test('upper case handles dotted and dotless i', () {
      expect(TurkishText.toUpperCase('istanbul'), 'İSTANBUL');
      expect(TurkishText.toUpperCase('ılık'), 'ILIK');
      expect(TurkishText.toUpperCase('çğıöşü iÇ'), 'ÇĞIÖŞÜ İÇ');
      expect('diyarbakır'.toTurkishUpperCase(), 'DİYARBAKIR');
      // Dart's default gets this wrong:
      expect('istanbul'.toUpperCase(), isNot('İSTANBUL'));
    });

    test('lower case handles İ and I', () {
      expect(TurkishText.toLowerCase('İSTANBUL'), 'istanbul');
      expect(TurkishText.toLowerCase('IĞDIR'), 'ığdır');
      expect(TurkishText.toLowerCase('ÇĞIÖŞÜ'), 'çğıöşü');
      expect(TurkishText.toLowerCase('i̇'), 'i');
      expect('İZMİR'.toTurkishLowerCase(), 'izmir');
      expect('I'.toLowerCase(), isNot('ı'));
    });

    test('round trip', () {
      const text = 'Iğdır İzmir ılık iyi ÇÖŞÜĞ';
      expect(TurkishText.toLowerCase(TurkishText.toUpperCase(text)),
          TurkishText.toLowerCase(text));
    });

    test('capitalize and title case', () {
      expect(TurkishText.capitalize('istanbul'), 'İstanbul');
      expect(TurkishText.capitalize('IĞDIR'), 'Iğdır');
      expect(TurkishText.capitalize(''), '');
      expect(TurkishText.capitalize('😀x'), '😀x');
      expect('ışık ılık süt iç'.toTurkishTitleCase(), 'Işık Ilık Süt İç');
      expect(TurkishText.toTitleCase("İSTANBUL'DA BİR GÜN"),
          "İstanbul'da Bir Gün");
      expect(TurkishText.toTitleCase('emirdağ-çay/ilgın'), 'Emirdağ-Çay/İlgın');
      expect('ankara'.toTurkishCapitalized(), 'Ankara');
    });
  });

  group('search normalization', () {
    test('folds case, Turkish letters and circumflexes', () {
      expect(TurkishText.normalizeForSearch('  IĞDIR  Kâhta '), 'igdir kahta');
      expect(
          TurkishText.normalizeForSearch('ÇĞIİÖŞÜ çğıiöşü'), 'cgiiosu cgiiosu');
      expect(TurkishText.normalizeForSearch('Hakkâri'), 'hakkari');
      expect(TurkishText.normalizeForSearch('Café Noël'), 'cafe noel');
      expect(TurkishText.normalizeForSearch('Özel'), 'ozel'); // decomposed Ö
      expect(TurkishText.normalizeForSearch('a\tb\nc d'), 'a b c d');
      expect('ŞİŞLİ'.toSearchKey(), 'sisli');
    });

    test('contains', () {
      expect(TurkishText.searchContains('Kağıthane', 'kagit'), isTrue);
      expect(TurkishText.searchContains('İstanbul', 'ISTAN'), isTrue);
      expect(TurkishText.searchContains('Ilgın', 'ilgin'), isTrue);
      expect(TurkishText.searchContains('Ankara', 'izmir'), isFalse);
      expect('Çanakkale'.turkishContains(''), isTrue);
      expect('Çanakkale'.turkishContains('KALE'), isTrue);
    });
  });

  group('sorting', () {
    test('Turkish alphabetical order', () {
      final words = <String>[
        'zeytin', 'üzüm', 'uçak', 'şeker', 'sabun', 'öküz', 'ozan', 'iğne', //
        'ılık', 'ğ', 'gül', 'çanta', 'cam', 'ağaç',
      ]..shuffle();
      TurkishText.sort(words);
      expect(
          words,
          <String>[
            'ağaç', 'cam', 'çanta', 'ğ', 'gül', 'ılık', 'iğne', 'ozan', //
            'öküz', 'sabun', 'şeker', 'uçak', 'üzüm', 'zeytin',
          ]..sort(TurkishText.compare));
      expect(words.indexOf('gül') < words.indexOf('ğ'), isTrue);
      expect(words.indexOf('ılık') < words.indexOf('iğne'), isTrue);
      expect(words.indexOf('cam') < words.indexOf('çanta'), isTrue);
      expect(words.indexOf('ozan') < words.indexOf('öküz'), isTrue);
      expect(words.indexOf('sabun') < words.indexOf('şeker'), isTrue);
      expect(words.indexOf('uçak') < words.indexOf('üzüm'), isTrue);
    });

    test('case is secondary', () {
      final words = <String>[
        'Çorum',
        'cam',
        'Istanbul',
        'iğne',
        'İzmir',
        'ılık',
        'Ankara',
        'adana'
      ];
      TurkishText.sort(words);
      expect(words, <String>[
        'adana',
        'Ankara',
        'cam',
        'Çorum',
        'ılık',
        'Istanbul',
        'iğne',
        'İzmir'
      ]);
    });

    test('ties: lower before upper, plain before circumflex', () {
      final words = <String>['Kâhta', 'Kahta', 'kahta'];
      TurkishText.sort(words);
      expect(words, <String>['kahta', 'Kahta', 'Kâhta']);
      expect(TurkishText.compare('a', 'a'), 0);
      expect(TurkishText.compare('kahta', 'kahta'), 0);
    });

    test('prefixes, digits and punctuation', () {
      expect(TurkishText.compare('ak', 'akça'), lessThan(0));
      expect(TurkishText.compare('19 Mayıs', 'Alaçam'), lessThan(0));
      expect(TurkishText.compare('a b', 'ab'), lessThan(0));
      expect('ç'.turkishCompareTo('d'), lessThan(0));
      expect('q'.turkishCompareTo('r'), lessThan(0));
      expect('w'.turkishCompareTo('y'), lessThan(0));
    });

    test('it is a consistent comparator', () {
      final words = <String>[
        'ağaç',
        'Ağrı',
        'ağ',
        'AĞ',
        'ılgın',
        'Ilgın',
        'ilgi',
        'İlgi',
        'ışık',
        'şık',
        'sık'
      ];
      for (final a in words) {
        for (final b in words) {
          expect(
              TurkishText.compare(a, b).sign, -TurkishText.compare(b, a).sign,
              reason: '$a/$b');
        }
      }
    });
  });

  group('TurkishInputMask', () {
    test('phone', () {
      expect(TurkishInputMask.phone.format('05321234567'), '0532 123 45 67');
      expect(TurkishInputMask.phone.format('5321234567'), '0532 123 45 67');
      expect(
          TurkishInputMask.phone.format('+90 532 123 45 67'), '0532 123 45 67');
      expect(TurkishInputMask.phone.format('00905321234567'), '0532 123 45 67');
      expect(TurkishInputMask.phone.format('0532123456789'), '0532 123 45 67');
      expect(TurkishInputMask.phone.format('053'), '053');
      expect(TurkishInputMask.phone.format('0532 '), '0532');
      expect(TurkishInputMask.phone.format(''), '');
      expect(TurkishInputMask.phone.format('0'), '');
      expect(TurkishInputMask.phone.maxDigits, 10);
    });

    test('iban, ids and dates', () {
      expect(TurkishInputMask.iban.format('tr330006100519786457841326'),
          'TR33 0006 1005 1978 6457 8413 26');
      expect(TurkishInputMask.iban.format('33 0006 1'), 'TR33 0006 1');
      expect(
          TurkishInputMask.tcKimlik.format('100-000-001-46-9'), '10000000146');
      expect(TurkishInputMask.vergiKimlik.format('12345678901'), '1234567890');
      expect(TurkishInputMask.date.format('29102026'), '29.10.2026');
    });

    test('cursor follows the digits', () {
      // Typing the 5th digit at the end.
      expect(
          TurkishInputMask.phone.apply('0532 1'), (text: '0532 1', cursor: 6));
      // Cursor after "0532" in raw "05321234": stays after the 4th digit.
      expect(TurkishInputMask.phone.apply('05321234', 4),
          (text: '0532 123 4', cursor: 4));
      // Inserting a digit in the middle.
      expect(TurkishInputMask.date.apply('2910.2026', 3),
          (text: '29.10.2026', cursor: 4));
      expect(TurkishInputMask.date.apply('29', 0), (text: '29', cursor: 0));
      expect(TurkishInputMask.date.apply('29', 99), (text: '29', cursor: 2));
      // Cursor beyond the digits that fit lands at the end.
      expect(TurkishInputMask.tcKimlik.apply('123456789012', 12),
          (text: '12345678901', cursor: 11));
    });
  });
}
