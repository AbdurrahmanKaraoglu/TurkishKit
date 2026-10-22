import 'package:flutter/material.dart';
import 'package:turkish_kit/turkish_kit.dart';

/// The app language chosen in the language menu; null follows the device.
final ValueNotifier<Locale?> appLocale = ValueNotifier<Locale?>(null);

const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('tr')];

/// Turkish on Turkish devices, English everywhere else.
Locale resolveLocale(List<Locale>? deviceLocales, Iterable<Locale> supported) {
  for (final Locale locale in deviceLocales ?? const <Locale>[]) {
    if (locale.languageCode == 'tr') return const Locale('tr');
    if (locale.languageCode == 'en') return const Locale('en');
  }
  return const Locale('en');
}

/// UI texts of the example. Every getter holds both languages, so a missing
/// translation cannot slip through.
class AppStrings {
  const AppStrings._(this.isTurkish);

  static AppStrings of(BuildContext context) =>
      AppStrings._(Localizations.localeOf(context).languageCode == 'tr');

  final bool isTurkish;

  String _t(String tr, String en) => isTurkish ? tr : en;

  TurkishValidationMessages get messages =>
      isTurkish ? TurkishValidationMessages.tr : TurkishValidationMessages.en;

  String get navValidate => _t('Doğrulama', 'Validate');
  String get navMoney => _t('Tutar', 'Amount');
  String get navText => _t('Metin', 'Text');
  String get navProvinces => _t('İl/İlçe', 'Provinces');
  String get navHolidays => _t('Tatiller', 'Holidays');

  String get language => _t('Dil', 'Language');
  String get systemLanguage => _t('Cihaz dili', 'Device language');

  // Validate
  String get validateSubtitle => _t(
    'Biçimleyici yazarken düzenler, doğrulayıcı algoritmayı kontrol eder.',
    'Masks format while you type, validators check the algorithm.',
  );
  String get tcKimlik => _t('T.C. kimlik no', 'Turkish ID number');
  String get vergiKimlik => _t('Vergi kimlik no', 'Tax ID number');
  String get iban => 'IBAN';
  String get phone => _t('Telefon', 'Phone');
  String get checkAll => _t('Kontrol et', 'Check');
  String get allValid => _t('Tüm alanlar geçerli.', 'All fields are valid.');
  String get fillSample => _t('Örnek doldur', 'Fill sample');
  String bankCode(String code) => _t('Banka kodu: $code', 'Bank code: $code');
  String phoneInfo(String e164, TurkishPhoneType type) {
    final String kind = switch (type) {
      TurkishPhoneType.mobile => _t('cep', 'mobile'),
      TurkishPhoneType.landline => _t('sabit hat', 'landline'),
      TurkishPhoneType.nonGeographic => _t('coğrafi olmayan', 'non-geographic'),
    };
    return '$e164 · $kind';
  }

  // Money
  String get moneySubtitle => _t(
    'Tutar kuruş olarak tam sayıyla tutulur; ondalık hatası olmaz.',
    'Amounts are stored as whole kuruş, so there are no rounding errors.',
  );
  String get amount => _t('Tutar', 'Amount');
  String get amountHint => _t('örn. 1.234,50', 'e.g. 1.234,50');
  String get invalidAmount => _t(
    'Geçerli bir tutar girin (1.234,56).',
    'Enter a valid amount (1.234,56).',
  );
  String get wordCase => _t('Harf biçimi', 'Letter case');
  String get caseTitle => _t('Başlık', 'Title');
  String get caseUpper => _t('BÜYÜK', 'UPPER');
  String get caseLower => _t('küçük', 'lower');
  String get compact => _t('Bitişik yaz', 'Run words together');
  String get shortUnits => _t('TL / Kr kısaltması', 'TL / Kr abbreviations');
  String get formatted => _t('Biçimli', 'Formatted');
  String get inWords => _t('Yazıyla', 'In words');
  String get invoice => _t('Fatura satırı', 'Invoice line');
  String get copied => _t('Kopyalandı', 'Copied');
  String get copy => _t('Kopyala', 'Copy');

  // Text
  String get textSubtitle => _t(
    'Dart\'ın varsayılanı i/İ ve ı/I harflerini yanlış çevirir.',
    'Dart\'s defaults get the Turkish i/İ and ı/I wrong.',
  );
  String get input => _t('Metin', 'Text');
  String get upperCase => _t('Büyük harf', 'Upper case');
  String get lowerCase => _t('Küçük harf', 'Lower case');
  String get titleCase => _t('Baş harfler büyük', 'Title case');
  String get searchKey => _t('Arama anahtarı', 'Search key');
  String get dartDefault => _t('Dart varsayılanı', 'Dart default');
  String get sorting => _t('Sıralama', 'Sorting');
  String get turkishOrder => _t('Türkçe sıra', 'Turkish order');
  String get codeUnitOrder => _t('Kod sırası', 'Code unit order');

  // Provinces
  String provincesSubtitle(int provinces, int districts) => _t(
    '$provinces il, $districts ilçe; çevrimdışı, resmi e-İçişleri verisi.',
    '$provinces provinces, $districts districts; offline, official data.',
  );
  String get searchHint => _t(
    'İl veya ilçe ara (ör. kagithane)',
    'Search province or district (e.g. kagithane)',
  );
  String districtCount(int count) => _t('$count ilçe', '$count districts');
  String get metropolitan => _t('Büyükşehir', 'Metropolitan');
  String matchingDistricts(String names) =>
      _t('İlçe: $names', 'District: $names');
  String get noResults => _t('Sonuç yok', 'No results');

  // Holidays
  String get holidaysSubtitle => _t(
    'Bayram tarihleri Diyanet takviminden (2020–2035).',
    'Bayram dates from the Diyanet calendar (2020–2035).',
  );
  String get year => _t('Yıl', 'Year');
  String get halfDay => _t('Yarım gün', 'Half day');
  String get businessDays => _t('İş günü hesabı', 'Business days');
  String get startDate => _t('Başlangıç', 'Start');
  String get days => _t('İş günü', 'Business days');
  String get result => _t('Sonuç', 'Result');
  String get isBusinessDay => _t('İş günü', 'Working day');
  String get outOfRange => _t(
    'Sonuç 2020–2035 aralığının dışında kalıyor.',
    'The result is outside 2020–2035.',
  );
  String get notBusinessDay => _t('İş günü değil', 'Not a working day');
  String holidayName(TurkishHoliday holiday) =>
      isTurkish ? holiday.nameTr : holiday.nameEn;

  String weekday(int weekday) => (isTurkish
      ? const <String>['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz']
      : const <String>[
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
          'Sat',
          'Sun',
        ])[weekday - 1];

  String date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} ${weekday(d.weekday)}';
}
