import 'package:test/test.dart';
import 'package:turkish_kit/turkish_kit.dart';

void main() {
  group('TurkishHolidays', () {
    test('2026 matches the official list', () {
      final list =
          TurkishHolidays.forYear(2026).map((h) => h.toString()).toList();
      expect(list, <String>[
        '2026-01-01 Yılbaşı',
        '2026-03-19 Ramazan Bayramı Arifesi',
        '2026-03-20 Ramazan Bayramı (1. Gün)',
        '2026-03-21 Ramazan Bayramı (2. Gün)',
        '2026-03-22 Ramazan Bayramı (3. Gün)',
        '2026-04-23 Ulusal Egemenlik ve Çocuk Bayramı',
        '2026-05-01 Emek ve Dayanışma Günü',
        "2026-05-19 Atatürk'ü Anma, Gençlik ve Spor Bayramı",
        '2026-05-26 Kurban Bayramı Arifesi',
        '2026-05-27 Kurban Bayramı (1. Gün)',
        '2026-05-28 Kurban Bayramı (2. Gün)',
        '2026-05-29 Kurban Bayramı (3. Gün)',
        '2026-05-30 Kurban Bayramı (4. Gün)',
        '2026-07-15 Demokrasi ve Millî Birlik Günü',
        '2026-08-30 Zafer Bayramı',
        '2026-10-28 Cumhuriyet Bayramı Arifesi',
        '2026-10-29 Cumhuriyet Bayramı',
      ]);
    });

    test('every supported year has the right number of bayram days', () {
      for (var year = TurkishHolidays.firstYear;
          year <= TurkishHolidays.lastYear;
          year++) {
        final holidays = TurkishHolidays.forYear(year);
        final ramazan = holidays
            .where((h) => h.kind == TurkishHolidayKind.ramazanBayrami)
            .length;
        final kurban = holidays
            .where((h) => h.kind == TurkishHolidayKind.kurbanBayrami)
            .length;
        expect(ramazan, year == 2033 ? 6 : 3, reason: '$year');
        expect(kurban, 4, reason: '$year');
        expect(holidays.where((h) => h.isHalfDay).length, year == 2033 ? 4 : 3,
            reason: '$year');
        for (var i = 1; i < holidays.length; i++) {
          expect(holidays[i - 1].date.compareTo(holidays[i].date),
              lessThanOrEqualTo(0));
        }
      }
    });

    test('known bayram first days', () {
      void first(TurkishHolidayKind kind, DateTime date) {
        final match = TurkishHolidays.on(date)
            .where((h) => h.kind == kind && h.dayNumber == 1);
        expect(match, hasLength(1), reason: '$kind $date');
      }

      first(TurkishHolidayKind.ramazanBayrami, DateTime(2020, 5, 24));
      first(TurkishHolidayKind.kurbanBayrami, DateTime(2020, 7, 31));
      first(TurkishHolidayKind.ramazanBayrami, DateTime(2023, 4, 21));
      first(TurkishHolidayKind.kurbanBayrami, DateTime(2023, 6, 28));
      first(TurkishHolidayKind.ramazanBayrami, DateTime(2024, 4, 10));
      first(TurkishHolidayKind.kurbanBayrami, DateTime(2024, 6, 16));
      first(TurkishHolidayKind.ramazanBayrami, DateTime(2025, 3, 30));
      first(TurkishHolidayKind.kurbanBayrami, DateTime(2025, 6, 6));
      first(TurkishHolidayKind.ramazanBayrami, DateTime(2027, 3, 9));
      first(TurkishHolidayKind.ramazanBayrami, DateTime(2033, 1, 2));
      first(TurkishHolidayKind.ramazanBayrami, DateTime(2033, 12, 23));
      first(TurkishHolidayKind.kurbanBayrami, DateTime(2035, 2, 18));
    });

    test('bayram across a month boundary', () {
      // Kurban Bayramı 2023: 28 June - 1 July.
      final days = TurkishHolidays.on(DateTime(2023, 7, 1));
      expect(days.single.nameTr, 'Kurban Bayramı (4. Gün)');
      expect(days.single.nameEn, 'Eid al-Adha (Day 4)');
    });

    test('overlapping holidays on 1 January 2033', () {
      final days = TurkishHolidays.on(DateTime(2033, 1, 1));
      expect(days.map((h) => h.kind), <TurkishHolidayKind>[
        TurkishHolidayKind.newYear,
        TurkishHolidayKind.ramazanBayramiEve,
      ]);
      expect(TurkishHolidays.isHoliday(DateTime(2033, 1, 1)), isTrue);
      expect(TurkishHolidays.isHalfDay(DateTime(2033, 1, 1)), isFalse);
    });

    test('history of fixed holidays', () {
      List<TurkishHolidayKind> kinds(int year) =>
          TurkishHolidays.fixedForYear(year).map((h) => h.kind).toList();
      expect(kinds(2008), isNot(contains(TurkishHolidayKind.labourDay)));
      expect(kinds(2009), contains(TurkishHolidayKind.labourDay));
      expect(kinds(2016), isNot(contains(TurkishHolidayKind.democracyDay)));
      expect(kinds(2017), contains(TurkishHolidayKind.democracyDay));
      expect(kinds(2100), hasLength(8));
      expect(() => TurkishHolidays.fixedForYear(1981), throwsRangeError);
    });

    test('half days and queries', () {
      expect(TurkishHolidays.isHoliday(DateTime(2026, 10, 29)), isTrue);
      expect(TurkishHolidays.isHoliday(DateTime(2026, 10, 28)), isFalse);
      expect(
          TurkishHolidays.isHoliday(DateTime(2026, 10, 28),
              includeHalfDays: true),
          isTrue);
      expect(TurkishHolidays.isHalfDay(DateTime(2026, 10, 28)), isTrue);
      expect(TurkishHolidays.isHalfDay(DateTime(2026, 10, 29)), isFalse);
      expect(TurkishHolidays.isHalfDay(DateTime(2026, 10, 27)), isFalse);
      expect(TurkishHolidays.on(DateTime(2026, 3, 19, 15, 30)).single.kind,
          TurkishHolidayKind.ramazanBayramiEve);
      expect(TurkishHolidays.on(DateTime(2026, 6, 1)), isEmpty);
      expect(TurkishHolidayKind.kurbanBayramiEve.isReligious, isTrue);
      expect(TurkishHolidayKind.victoryDay.isReligious, isFalse);
      expect(TurkishHolidays.forYear(2026).first,
          TurkishHolidays.forYear(2026).first);
    });

    test('unsupported years throw', () {
      expect(() => TurkishHolidays.forYear(2019), throwsRangeError);
      expect(() => TurkishHolidays.forYear(2036), throwsRangeError);
      expect(() => TurkishHolidays.isBusinessDay(DateTime(2040)),
          throwsRangeError);
      expect(TurkishHolidays.isSupportedYear(2035), isTrue);
    });
  });

  group('business days', () {
    test('weekends and holidays', () {
      expect(TurkishHolidays.isBusinessDay(DateTime(2026, 10, 22)),
          isTrue); // Thursday
      expect(TurkishHolidays.isBusinessDay(DateTime(2026, 10, 24)),
          isFalse); // Saturday
      expect(TurkishHolidays.isBusinessDay(DateTime(2026, 10, 29)),
          isFalse); // Republic Day
      expect(TurkishHolidays.isBusinessDay(DateTime(2026, 10, 28)),
          isTrue); // half day
      expect(TurkishHolidays.isBusinessDay(DateTime(2026, 5, 26)),
          isTrue); // arife
      expect(TurkishHolidays.isBusinessDay(DateTime(2026, 5, 27)),
          isFalse); // Kurban
    });

    test('addBusinessDays', () {
      // Friday 22 May 2026 + 1: Monday 25 May (arife on 26th is a work day).
      expect(TurkishHolidays.addBusinessDays(DateTime(2026, 5, 22), 1),
          DateTime(2026, 5, 25));
      // Tuesday 26 May (arife) + 1 skips Kurban (27-30) and the weekend.
      expect(TurkishHolidays.addBusinessDays(DateTime(2026, 5, 26), 1),
          DateTime(2026, 6, 1));
      expect(TurkishHolidays.addBusinessDays(DateTime(2026, 6, 1), -1),
          DateTime(2026, 5, 26));
      expect(TurkishHolidays.addBusinessDays(DateTime(2026, 10, 23), 5),
          DateTime(2026, 11, 2));
      expect(TurkishHolidays.addBusinessDays(DateTime(2026, 10, 24, 18), 0),
          DateTime(2026, 10, 26));
      expect(TurkishHolidays.addBusinessDays(DateTime(2026, 10, 22, 9), 0),
          DateTime(2026, 10, 22));
      // Across a year boundary.
      expect(TurkishHolidays.addBusinessDays(DateTime(2026, 12, 31), 1),
          DateTime(2027, 1, 4));
    });

    test('businessDaysBetween', () {
      // October 2026: 22 weekdays, minus 29 Ekim.
      expect(
          TurkishHolidays.businessDaysBetween(
              DateTime(2026, 10, 1), DateTime(2026, 11, 1)),
          21);
      expect(
          TurkishHolidays.businessDaysBetween(
              DateTime(2026, 11, 1), DateTime(2026, 10, 1)),
          -21);
      expect(
          TurkishHolidays.businessDaysBetween(
              DateTime(2026, 10, 1), DateTime(2026, 10, 1)),
          0);
      // Whole of 2026: 261 weekdays, minus weekday holidays.
      final weekdayHolidays = TurkishHolidays.forYear(2026)
          .where((h) => !h.isHalfDay && h.date.weekday <= 5)
          .map((h) => h.date)
          .toSet()
          .length;
      expect(
          TurkishHolidays.businessDaysBetween(DateTime(2026), DateTime(2027)),
          261 - weekdayHolidays);
    });

    test('custom calendar', () {
      final calendar = TurkishBusinessCalendar(
        halfDayIsBusinessDay: false,
        extraHolidays: <DateTime>[DateTime(2026, 5, 25)],
        extraBusinessDays: <DateTime>[DateTime(2026, 5, 23)],
      );
      expect(
          calendar.isBusinessDay(DateTime(2026, 5, 26)), isFalse); // arife off
      expect(
          calendar.isBusinessDay(DateTime(2026, 5, 25)), isFalse); // bridge day
      expect(calendar.isBusinessDay(DateTime(2026, 5, 23)),
          isTrue); // make-up Saturday
      expect(calendar.nextBusinessDay(DateTime(2026, 5, 22)),
          DateTime(2026, 5, 23));
      expect(calendar.nextBusinessDay(DateTime(2026, 5, 23)),
          DateTime(2026, 6, 1));
      expect(calendar.previousBusinessDay(DateTime(2026, 6, 1)),
          DateTime(2026, 5, 23));

      final sixDays =
          TurkishBusinessCalendar(weekendDays: <int>{DateTime.sunday});
      expect(sixDays.isBusinessDay(DateTime(2026, 10, 24)), isTrue);
      expect(
          () =>
              TurkishBusinessCalendar(weekendDays: <int>{1, 2, 3, 4, 5, 6, 7}),
          throwsArgumentError);
      expect(TurkishBusinessCalendar.standard.weekendDays, <int>{6, 7});
    });
  });
}
