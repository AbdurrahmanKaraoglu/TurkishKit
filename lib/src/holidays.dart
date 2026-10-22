import 'data/bayram_data.dart';

/// Which holiday a [TurkishHoliday] is.
enum TurkishHolidayKind {
  /// 1 Ocak, Yılbaşı.
  newYear('Yılbaşı', "New Year's Day"),

  /// 23 Nisan, Ulusal Egemenlik ve Çocuk Bayramı.
  nationalSovereigntyDay(
    'Ulusal Egemenlik ve Çocuk Bayramı',
    "National Sovereignty and Children's Day",
  ),

  /// 1 Mayıs, Emek ve Dayanışma Günü (a holiday since 2009).
  labourDay('Emek ve Dayanışma Günü', 'Labour and Solidarity Day'),

  /// 19 Mayıs, Atatürk'ü Anma, Gençlik ve Spor Bayramı.
  youthDay(
    "Atatürk'ü Anma, Gençlik ve Spor Bayramı",
    'Commemoration of Atatürk, Youth and Sports Day',
  ),

  /// 15 Temmuz, Demokrasi ve Millî Birlik Günü (a holiday since 2017).
  democracyDay(
    'Demokrasi ve Millî Birlik Günü',
    'Democracy and National Unity Day',
  ),

  /// 30 Ağustos, Zafer Bayramı.
  victoryDay('Zafer Bayramı', 'Victory Day'),

  /// 28 Ekim afternoon (from 13:00), the eve of Cumhuriyet Bayramı.
  republicDayEve('Cumhuriyet Bayramı Arifesi', 'Republic Day Eve'),

  /// 29 Ekim, Cumhuriyet Bayramı.
  republicDay('Cumhuriyet Bayramı', 'Republic Day'),

  /// The afternoon (from 13:00) before Ramazan Bayramı.
  ramazanBayramiEve('Ramazan Bayramı Arifesi', 'Eid al-Fitr Eve'),

  /// Ramazan Bayramı (Eid al-Fitr), 3 days.
  ramazanBayrami('Ramazan Bayramı', 'Eid al-Fitr'),

  /// The afternoon (from 13:00) before Kurban Bayramı.
  kurbanBayramiEve('Kurban Bayramı Arifesi', 'Eid al-Adha Eve'),

  /// Kurban Bayramı (Eid al-Adha), 4 days.
  kurbanBayrami('Kurban Bayramı', 'Eid al-Adha');

  const TurkishHolidayKind(this.nameTr, this.nameEn);

  /// The Turkish name.
  final String nameTr;

  /// The English name.
  final String nameEn;

  /// Whether this is a half-day holiday (from 13:00): an arife.
  bool get isHalfDay =>
      this == republicDayEve ||
      this == ramazanBayramiEve ||
      this == kurbanBayramiEve;

  /// Whether this is a religious holiday (or its eve), whose date follows
  /// the Hijri calendar.
  bool get isReligious =>
      this == ramazanBayramiEve ||
      this == ramazanBayrami ||
      this == kurbanBayramiEve ||
      this == kurbanBayrami;
}

/// A public holiday in Turkey on a given date.
final class TurkishHoliday {
  const TurkishHoliday._(this.date, this.kind, [this.dayNumber]);

  /// The date (local [DateTime] at midnight).
  final DateTime date;

  /// Which holiday this is.
  final TurkishHolidayKind kind;

  /// For bayram days, which day of the bayram it is (1-3 for Ramazan,
  /// 1-4 for Kurban); otherwise `null`.
  final int? dayNumber;

  /// Whether only the afternoon (from 13:00) is a holiday.
  bool get isHalfDay => kind.isHalfDay;

  /// The Turkish name, for example `Kurban Bayramı (2. Gün)`.
  String get nameTr =>
      dayNumber == null ? kind.nameTr : '${kind.nameTr} ($dayNumber. Gün)';

  /// The English name, for example `Eid al-Adha (Day 2)`.
  String get nameEn =>
      dayNumber == null ? kind.nameEn : '${kind.nameEn} (Day $dayNumber)';

  @override
  bool operator ==(Object other) =>
      other is TurkishHoliday &&
      other.date == date &&
      other.kind == kind &&
      other.dayNumber == dayNumber;

  @override
  int get hashCode => Object.hash(date, kind, dayNumber);

  @override
  String toString() =>
      '${date.year}-${_two(date.month)}-${_two(date.day)} $nameTr';
}

/// Public holidays of Turkey under Law No. 2429 (Ulusal Bayram ve Genel
/// Tatiller Hakkında Kanun).
///
/// Fixed-date holidays are computed for any year from 1982. The dates of
/// Ramazan and Kurban Bayramı follow the Hijri calendar and cannot be
/// computed reliably, so they come from a table of the official Diyanet
/// calendar for [firstYear]–[lastYear]; outside that range the functions
/// that need them throw a [RangeError].
///
/// Extra days off that the government announces separately (idari izin,
/// for example bridge days around a bayram) are not part of the law and not
/// included; add them with [TurkishBusinessCalendar.extraHolidays].
abstract final class TurkishHolidays {
  /// The first year with religious holiday dates.
  static const int firstYear = 2020;

  /// The last year with religious holiday dates.
  static const int lastYear = 2035;

  /// Whether [year] is within [firstYear]–[lastYear].
  static bool isSupportedYear(int year) =>
      year >= firstYear && year <= lastYear;

  /// All holidays (fixed and religious) in [year], sorted by date. Several
  /// holidays can share a date (for example the arife of Ramazan Bayramı on
  /// 1 January 2033).
  ///
  /// Throws a [RangeError] if [year] is outside [firstYear]–[lastYear].
  static List<TurkishHoliday> forYear(int year) {
    _checkYear(year);
    return _cache.putIfAbsent(year, () {
      final holidays =
          <TurkishHoliday>[
            ...fixedForYear(year),
            for (final holiday in _religious)
              if (holiday.date.year == year) holiday,
          ]..sort((a, b) {
            final byDate = a.date.compareTo(b.date);
            return byDate != 0 ? byDate : a.kind.index - b.kind.index;
          });
      return List<TurkishHoliday>.unmodifiable(holidays);
    });
  }

  /// The fixed-date holidays in [year] (everything except the bayrams),
  /// including 1 Mayıs from 2009 and 15 Temmuz from 2017.
  ///
  /// Throws a [RangeError] for years before 1982.
  static List<TurkishHoliday> fixedForYear(int year) {
    if (year < 1982) throw RangeError.value(year, 'year', 'must be >= 1982');
    return <TurkishHoliday>[
      TurkishHoliday._(DateTime(year, 1, 1), TurkishHolidayKind.newYear),
      TurkishHoliday._(
        DateTime(year, 4, 23),
        TurkishHolidayKind.nationalSovereigntyDay,
      ),
      if (year >= 2009)
        TurkishHoliday._(DateTime(year, 5, 1), TurkishHolidayKind.labourDay),
      TurkishHoliday._(DateTime(year, 5, 19), TurkishHolidayKind.youthDay),
      if (year >= 2017)
        TurkishHoliday._(
          DateTime(year, 7, 15),
          TurkishHolidayKind.democracyDay,
        ),
      TurkishHoliday._(DateTime(year, 8, 30), TurkishHolidayKind.victoryDay),
      TurkishHoliday._(
        DateTime(year, 10, 28),
        TurkishHolidayKind.republicDayEve,
      ),
      TurkishHoliday._(DateTime(year, 10, 29), TurkishHolidayKind.republicDay),
    ];
  }

  /// The holidays on [date] (its year, month and day; the time is ignored).
  /// Empty if [date] is not a holiday.
  ///
  /// Throws a [RangeError] if the year is outside [firstYear]–[lastYear].
  static List<TurkishHoliday> on(DateTime date) => <TurkishHoliday>[
    for (final holiday in forYear(date.year))
      if (holiday.date.month == date.month && holiday.date.day == date.day)
        holiday,
  ];

  /// Whether [date] is a full-day holiday or, with [includeHalfDays], also
  /// an arife afternoon.
  ///
  /// Throws a [RangeError] if the year is outside [firstYear]–[lastYear].
  static bool isHoliday(DateTime date, {bool includeHalfDays = false}) =>
      on(date).any((h) => includeHalfDays || !h.isHalfDay);

  /// Whether [date] is only a half-day holiday (an arife, from 13:00) and
  /// not also a full-day holiday.
  static bool isHalfDay(DateTime date) {
    final holidays = on(date);
    return holidays.isNotEmpty && holidays.every((h) => h.isHalfDay);
  }

  /// Whether [date] is a working day on the standard calendar: Monday to
  /// Friday and not a full-day holiday. Arife half days count as working
  /// days. See [TurkishBusinessCalendar] to change these rules.
  static bool isBusinessDay(DateTime date) =>
      TurkishBusinessCalendar.standard.isBusinessDay(date);

  /// [TurkishBusinessCalendar.addBusinessDays] on the standard calendar.
  static DateTime addBusinessDays(DateTime date, int days) =>
      TurkishBusinessCalendar.standard.addBusinessDays(date, days);

  /// [TurkishBusinessCalendar.businessDaysBetween] on the standard calendar.
  static int businessDaysBetween(DateTime start, DateTime end) =>
      TurkishBusinessCalendar.standard.businessDaysBetween(start, end);

  static void _checkYear(int year) {
    if (!isSupportedYear(year)) {
      throw RangeError.range(
        year,
        firstYear,
        lastYear,
        'year',
        'Religious holiday dates are only available for',
      );
    }
  }

  static final Map<int, List<TurkishHoliday>> _cache =
      <int, List<TurkishHoliday>>{};

  static final List<TurkishHoliday> _religious = <TurkishHoliday>[
    for (final (isKurban, y, m, d) in bayramData) ...[
      TurkishHoliday._(
        DateTime(y, m, d - 1),
        isKurban
            ? TurkishHolidayKind.kurbanBayramiEve
            : TurkishHolidayKind.ramazanBayramiEve,
      ),
      for (var day = 1; day <= (isKurban ? 4 : 3); day++)
        TurkishHoliday._(
          DateTime(y, m, d + day - 1),
          isKurban
              ? TurkishHolidayKind.kurbanBayrami
              : TurkishHolidayKind.ramazanBayrami,
          day,
        ),
    ],
  ];
}

/// Working-day rules: weekends, public holidays and your own exceptions.
///
/// ```dart
/// final calendar = TurkishBusinessCalendar(
///   extraHolidays: {DateTime(2026, 5, 25)}, // an announced bridge day
/// );
/// calendar.addBusinessDays(DateTime(2026, 5, 22), 1);
/// ```
///
/// All methods work on dates: the time of day is ignored, and results are
/// local [DateTime]s at midnight. They throw a [RangeError] when they need a
/// year outside [TurkishHolidays.firstYear]–[TurkishHolidays.lastYear].
class TurkishBusinessCalendar {
  /// Creates a calendar.
  ///
  /// * [weekendDays]: [DateTime.weekday] values that are never working days
  ///   (default Saturday and Sunday).
  /// * [halfDayIsBusinessDay]: whether arife half days count as working days
  ///   (default true; they are working mornings).
  /// * [extraHolidays]: additional days off, such as announced idari izin.
  /// * [extraBusinessDays]: days that are working days even though they fall
  ///   on a weekend or holiday (for example a make-up working Saturday).
  TurkishBusinessCalendar({
    Set<int> weekendDays = const <int>{DateTime.saturday, DateTime.sunday},
    this.halfDayIsBusinessDay = true,
    Iterable<DateTime> extraHolidays = const <DateTime>[],
    Iterable<DateTime> extraBusinessDays = const <DateTime>[],
  }) : weekendDays = Set<int>.unmodifiable(weekendDays),
       _extraHolidays = extraHolidays.map(_key).toSet(),
       _extraBusinessDays = extraBusinessDays.map(_key).toSet() {
    if (this.weekendDays.length >= 7) {
      throw ArgumentError.value(
        weekendDays,
        'weekendDays',
        'leaves no working day',
      );
    }
  }

  /// Monday to Friday, public holidays off, arife half days are working days.
  static final TurkishBusinessCalendar standard = TurkishBusinessCalendar();

  /// [DateTime.weekday] values that are not working days.
  final Set<int> weekendDays;

  /// Whether arife half days count as working days.
  final bool halfDayIsBusinessDay;

  final Set<int> _extraHolidays;
  final Set<int> _extraBusinessDays;

  /// Whether [date] is a working day.
  bool isBusinessDay(DateTime date) {
    TurkishHolidays._checkYear(date.year);
    final key = _key(date);
    if (_extraBusinessDays.contains(key)) return true;
    if (_extraHolidays.contains(key)) return false;
    final day = DateTime.utc(date.year, date.month, date.day);
    if (weekendDays.contains(day.weekday)) return false;
    return !TurkishHolidays.isHoliday(
      date,
      includeHalfDays: !halfDayIsBusinessDay,
    );
  }

  /// The date [days] working days after [date] (before it if [days] is
  /// negative). With 0, returns [date] itself if it is a working day,
  /// otherwise the next working day.
  ///
  /// Friday + 1 is the next Monday, unless that is a holiday.
  DateTime addBusinessDays(DateTime date, int days) {
    var day = DateTime.utc(date.year, date.month, date.day);
    if (days == 0) {
      while (!isBusinessDay(day)) {
        day = _shift(day, 1);
      }
      return _local(day);
    }
    final step = days > 0 ? 1 : -1;
    var remaining = days.abs();
    while (remaining > 0) {
      day = _shift(day, step);
      if (isBusinessDay(day)) remaining--;
    }
    return _local(day);
  }

  /// The first working day after [date].
  DateTime nextBusinessDay(DateTime date) => addBusinessDays(date, 1);

  /// The last working day before [date].
  DateTime previousBusinessDay(DateTime date) => addBusinessDays(date, -1);

  /// The number of working days from [start] (inclusive) to [end]
  /// (exclusive). Negative if [end] is before [start].
  int businessDaysBetween(DateTime start, DateTime end) {
    var from = DateTime.utc(start.year, start.month, start.day);
    var to = DateTime.utc(end.year, end.month, end.day);
    var sign = 1;
    if (to.isBefore(from)) {
      final swap = from;
      from = to;
      to = swap;
      sign = -1;
    }
    var count = 0;
    for (var day = from; day.isBefore(to); day = _shift(day, 1)) {
      if (isBusinessDay(day)) count++;
    }
    return sign * count;
  }
}

int _key(DateTime date) => date.year * 10000 + date.month * 100 + date.day;

DateTime _shift(DateTime utcDay, int days) =>
    DateTime.utc(utcDay.year, utcDay.month, utcDay.day + days);

DateTime _local(DateTime utcDay) =>
    DateTime(utcDay.year, utcDay.month, utcDay.day);

String _two(int n) => n.toString().padLeft(2, '0');
