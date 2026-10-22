# Turkish Kit

[![pub package](https://img.shields.io/pub/v/turkish_kit.svg)](https://pub.dev/packages/turkish_kit)

The helpers almost every Turkish Dart or Flutter project writes from scratch,
in one tested, **pure Dart** package (no Flutter dependency: works in Flutter,
on the server, in CLIs and on the web).

| Area | What you get |
| --- | --- |
| Validators | T.C. kimlik no, vergi kimlik no (VKN), TR IBAN (mod-97), Turkish mobile/landline phone numbers: validate, normalize (E.164), format |
| Forms | `TextFormField`-ready validators with Turkish/English messages, as-you-type masks (phone, IBAN, ID, date) and a money input mask (`1.234,56 ₺`) with a steady cursor |
| Money | Exact amounts in kuruş (no `double` errors), `1.234,56 ₺` formatting and parsing, amounts in words: `Bin İki Yüz Otuz Dört Türk Lirası Elli Kuruş`, invoice style `Yalnız #...#` |
| Text | Correct `İ/i` and `I/ı` upper/lower/title case, accent-insensitive search keys, Turkish alphabetical sorting |
| Provinces | 81 provinces (plate code, name) and all 973 districts, offline, from official data |
| Holidays | Public holidays under Law 2429, Ramazan and Kurban Bayramı 2020–2035 from the Diyanet calendar, arife half days, `isBusinessDay`, `addBusinessDays` |

Türkçe açıklama için [aşağıya](#türkçe) bakın.

## Installation

```yaml
dependencies:
  turkish_kit: ^0.2.0
```

```dart
import 'package:turkish_kit/turkish_kit.dart';
```

For Flutter widgets (money field, input formatters) add
[turkish_kit_flutter](https://pub.dev/packages/turkish_kit_flutter) instead;
it includes turkish_kit.

## Validators

```dart
TurkishValidators.isValidTcKimlik('10000000146');        // true
TurkishValidators.isValidVergiKimlik('1234567890');      // true
TurkishValidators.isValidTaxNumber(value);               // VKN or TCKN
TurkishValidators.isValidIban('tr33 0006 1005 1978 6457 8413 26'); // true
TurkishValidators.formatIban('TR330006100519786457841326');
// 'TR33 0006 1005 1978 6457 8413 26'

TurkishValidators.normalizePhone('(0532) 123 45 67');    // '+905321234567'
TurkishValidators.formatPhone('+905321234567');          // '0532 123 45 67'
TurkishValidators.phoneType('0212 123 45 67');           // TurkishPhoneType.landline
```

Input may contain spaces, dashes, dots and parentheses. Phone numbers are
accepted as `0532…`, `532…`, `+90 532…`, `+90 (0532)…`, `0090 532…` or
`90532…`; IBANs with spaces or dashes and in lower case.

Checksums only prove that a number is well formed, not that it belongs to a
real person, company or account.

### In a Flutter form

The validators have the `String? Function(String?)` signature that
`TextFormField.validator` expects:

```dart
TextFormField(
  validator: TurkishFormValidators.tcKimlik(),          // Turkish messages
  // validator: TurkishFormValidators.iban(messages: TurkishValidationMessages.en),
  // validator: TurkishFormValidators.phone(required: false, message: 'Telefon?'),
)
```

`TurkishInputMask` formats IDs, IBANs and phone numbers while the user types
(`0532 123 45 67`, `TR33 0006 ...`), and `TurkishMoneyInputMask` formats a
money field (`1.234,56 ₺`) with a steady cursor. Both are pure Dart. The
companion package
[turkish_kit_flutter](https://pub.dev/packages/turkish_kit_flutter) wraps
them for Flutter: `TurkishInputMaskFormatter`, `TurkishMoneyInputFormatter`,
`TurkishMoneyController` and a ready-made `TurkishMoneyField`.

```dart
import 'package:turkish_kit_flutter/turkish_kit_flutter.dart'; // also exports turkish_kit

TextFormField(
  keyboardType: TextInputType.phone,
  inputFormatters: [TurkishInputMaskFormatter(TurkishInputMask.phone)],
  validator: TurkishFormValidators.phone(),
)

TurkishMoneyField(
  controller: TurkishMoneyController(mask: const TurkishMoneyInputMask(symbol: '₺')),
  required: true,
  decoration: const InputDecoration(labelText: 'Tutar'),
)
```

**Why is Flutter in a separate package?** A package that depends on the
Flutter SDK cannot be used from plain Dart (servers, CLIs, shared business
logic) at all, even if only one of its libraries imports Flutter. So
turkish_kit stays pure Dart with no dependencies: validators are plain
functions, and the mask logic (including cursor handling) is plain Dart and
tested here. turkish_kit_flutter only adapts it to Flutter's
`TextInputFormatter` and `TextEditingController`.

### Money input without Flutter

`TurkishMoneyInputMask.apply(oldValue, newValue)` takes the text and
selection before and after an edit and returns the formatted text with the
cursor in place:

```dart
const mask = TurkishMoneyInputMask(symbol: '₺', fractionDigits: 2);
final r = mask.apply(
  (text: '1.234 ₺', selectionStart: 3, selectionEnd: 3),  // 1.2|34 ₺
  (text: '1.2934 ₺', selectionStart: 4, selectionEnd: 4), // the user typed 9
);
// r == (text: '12.934 ₺', selectionStart: 4, selectionEnd: 4)  → 12.9|34 ₺
mask.parse('1.234,5 ₺');   // TurkishMoney(1234,50)
mask.format(TurkishMoney.fromKurus(99)); // '0,99 ₺'
```

Options: `fractionDigits` (0-2), `maxValue`, `allowNegative`, `symbol`.
Typed `.` counts as the decimal comma (some numeric keyboards have no
comma); pasted `1234.56`, `1.234,56`, `₺1.234,56` and `1 234,56 TL` are
understood; backspace on a thousands separator deletes the digit before it.

## Money and amounts in words

`TurkishMoney` stores a whole number of kuruş (`BigInt`), so `0.1 + 0.2`
problems cannot happen.

```dart
final total = TurkishMoney.parse('1.234,50 ₺');      // Turkish notation
final same = TurkishMoney.fromDecimalString('1234.50'); // JSON / API
final kurus = TurkishMoney.fromKurus(123450);

total.format();          // '1.234,50 ₺'
total.toWords();         // 'Bin İki Yüz Otuz Dört Türk Lirası Elli Kuruş'
total.toInvoiceText();   // 'Yalnız #Bin İki Yüz Otuz Dört Türk Lirası Elli Kuruş#'
total.toInvoiceText(separator: '', wordCase: TurkishWordCase.upper);
// 'YALNIZ #BİNİKİYÜZOTUZDÖRTTÜRKLİRASIELLİKURUŞ#'
total.toWords(currency: 'TL', subunit: 'Kr', wordCase: TurkishWordCase.sentence);
// 'Bin iki yüz otuz dört TL elli Kr'
```

* **Zero and kuruş only:** `0` → `Sıfır Türk Lirası`, `0,50` → `Elli Kuruş`.
* **Negative:** `-1,50` → `Eksi Bir Türk Lirası Elli Kuruş`.
* **Rounding:** more than two decimals are rounded half up by default
  (`1,005` → `1,01`); `TurkishRounding.halfEven`, `.truncate` and `.strict`
  (throws) are available.
* **Limits:** words up to 10^36 − 1 (`desilyon`, short scale: milyon,
  milyar, trilyon, katrilyon, kentilyon, seksilyon, septilyon, oktilyon,
  nonilyon, desilyon); beyond that a `RangeError` is thrown.
* `TurkishMoney.fromNum(2.675)` uses the shortest decimal form of the double
  (2,675 → 2,68), but prefer kuruş or strings for money.

Plain numbers: `TurkishNumberWords.convert(1001000)` → `Bir Milyon Bin`,
`TurkishNumberFormat.format(1234.5)` → `1.234,50`,
`TurkishNumberFormat.parse('1.234,56')` → `1234.56`. In Turkish notation a
`.` groups thousands, so `1.234` is 1234 and `1.23` is rejected.

## Turkish text

```dart
'istanbul'.toTurkishUpperCase();            // 'İSTANBUL'  ('istanbul'.toUpperCase() gives 'ISTANBUL')
'IĞDIR'.toTurkishLowerCase();               // 'ığdır'
'ışık ılık süt iç'.toTurkishTitleCase();    // 'Işık Ilık Süt İç'
'  IĞDIR  Kâhta '.toSearchKey();            // 'igdir kahta'
'Kağıthane'.turkishContains('kagit');       // true
names.sort(TurkishText.compare);            // a b c ç d e f g ğ h ı i j ... ş t u ü v y z
```

Sorting ignores case and circumflexes first (`Çorum` next to `çorum`,
`Kâhta` next to `Kahta`). Ties are broken like Unicode collation: plain
letters before circumflexes, then lower case before upper case
(`kahta`, `Kahta`, `kâhta`, `Kâhta`).

## Provinces and districts

```dart
TurkishProvinces.all.length;                     // 81
TurkishProvinces.districtCount;                  // 973
final ist = TurkishProvinces.byPlateCode(34)!;   // İstanbul
ist.districts;                                   // ['Adalar', 'Arnavutköy', ...] (39)
ist.isMetropolitan;                              // true
TurkishProvinces.byName('sanliurfa')?.plateCode; // 63
TurkishProvinces.search('kar');                  // Kars, Karaman, Karabük, Afyonkarahisar, ...
TurkishProvinces.provincesWithDistrict('Ereğli');// Konya, Zonguldak
```

**Source:** T.C. İçişleri Bakanlığı, e-İçişleri
"[Mülki İdare Bölümleri](https://www.e-icisleri.gov.tr/Anasayfa/MulkiIdariBolumleri.aspx)",
retrieved 2026-10-22, cross-checked against Turkish Wikipedia
"Türkiye'nin ilçeleri" (same 973 districts, same count in every province).
Names use the official spelling (`Hakkari`, `Kahta`, `Bala`, `Kağıthane`,
Zonguldak's `Ereğli`); search ignores circumflexes, so `Kâhta` still finds
`Kahta`. In the 51 non-metropolitan provinces the central district is called
`Merkez`. Province and district names are facts and official records, not
copyrighted works (see FSEK art. 31); no Wikipedia text is included. The
generator and raw data are in [`tool/`](tool/data/SOURCES.md).

## Holidays and business days

```dart
TurkishHolidays.forYear(2026);        // 17 entries: Yılbaşı ... Cumhuriyet Bayramı
TurkishHolidays.on(DateTime(2026, 5, 27)); // [Kurban Bayramı (1. Gün)]
TurkishHolidays.isHoliday(DateTime(2026, 10, 29));              // true
TurkishHolidays.isHalfDay(DateTime(2026, 10, 28));              // true (from 13:00)
TurkishHolidays.isBusinessDay(DateTime(2026, 10, 22));          // true
TurkishHolidays.addBusinessDays(DateTime(2026, 5, 26), 1);      // 2026-06-01
TurkishHolidays.businessDaysBetween(DateTime(2026, 10, 1), DateTime(2026, 11, 1)); // 21

final calendar = TurkishBusinessCalendar(
  halfDayIsBusinessDay: false,                     // treat arife as a day off
  extraHolidays: [DateTime(2026, 5, 25)],          // an announced idari izin
  extraBusinessDays: [DateTime(2026, 5, 23)],      // a make-up Saturday
);
```

* **Fixed holidays** (Law 2429): 1 Ocak, 23 Nisan, 1 Mayıs (since 2009),
  19 Mayıs, 15 Temmuz (since 2017), 30 Ağustos, 28 Ekim afternoon,
  29 Ekim. Available for every year from 1982 via
  `TurkishHolidays.fixedForYear`.
* **Bayrams:** Ramazan Bayramı (arife half day + 3 days) and Kurban Bayramı
  (arife half day + 4 days) follow the Hijri calendar and are not computed.
  They come from the official
  [Diyanet calendar](https://vakithesaplama.diyanet.gov.tr/) for
  **2020–2035** (2033 has two Ramazan Bayramı). Outside that range the
  functions that need bayram dates throw a `RangeError` instead of giving a
  silently wrong answer. For Ramazan Bayramı 2028 and 2029 some
  international calendars show one day later; Diyanet's date is used (see
  [tool/data/SOURCES.md](tool/data/SOURCES.md)).
* Arife and 28 Ekim are half days (from 13:00). By default they count as
  working days.
* Extra days off announced by the government (idari izin, bridge days) are
  not part of the law; add them with `extraHolidays`.

## Compared with other packages

Existing pub.dev packages each cover one piece: `turkish` (casing and sorting,
no release for 4 years), `turkish_validators` (Flutter-only, `double` for
money, no VKN), `tckn_check` (TCKN only), `amount_to_word` (multi-language,
`num` input), `il_ilce` / `turkiye_il_ilce_mahalle` (widgets or a network API),
generic `iban` validators. There was no package for Turkish public holidays
or VKN validation. turkish_kit puts all of this in one pure-Dart package with
no dependencies, exact money handling, offline official data and tests for
each part.

## Other packages

More packages by the same author on [pub.dev](https://pub.dev/publishers/abdurrahmankaraoglu.com/packages):

* [turkish_kit_flutter](https://pub.dev/packages/turkish_kit_flutter): Flutter money field and input formatters for this package
* [flutter_toastify](https://pub.dev/packages/flutter_toastify): animated toast notifications
* [google_maps_polyline](https://pub.dev/packages/google_maps_polyline): Directions API routes and polyline encoding/decoding
* [marker_crafter](https://pub.dev/packages/marker_crafter): custom Google Maps markers drawn with Canvas
* [animated_route_marker](https://pub.dev/packages/animated_route_marker): markers that move smoothly along a route
* [advanced_background_locator](https://pub.dev/packages/advanced_background_locator): location tracking that keeps running in the background
* [advanced_geofence](https://pub.dev/packages/advanced_geofence): pure Dart geofencing with enter, exit and dwell events
* [route_simulator](https://pub.dev/packages/route_simulator): pure Dart fake GPS streams along a route for testing

## License

MIT. See [LICENSE](LICENSE).

---

## Türkçe

Neredeyse her Türk Dart/Flutter projesinde baştan yazılan yardımcılar, tek,
test edilmiş ve **saf Dart** bir pakette (Flutter bağımlılığı yok: Flutter'da,
sunucuda, komut satırında ve web'de çalışır).

| Alan | İçerik |
| --- | --- |
| Doğrulayıcılar | T.C. kimlik no, vergi kimlik no (VKN), TR IBAN (mod-97), cep/sabit telefon: doğrulama, normalleştirme (E.164), biçimlendirme |
| Formlar | `TextFormField` için hazır doğrulayıcılar (Türkçe/İngilizce mesaj), yazarken biçimleyen maskeler (telefon, IBAN, kimlik, tarih) ve imleci kaymayan para maskesi (`1.234,56 ₺`) |
| Para | Kuruş cinsinden tam tutar (`double` hatası yok), `1.234,56 ₺` biçimlendirme ve ayrıştırma, tutarı yazıyla yazma, fatura biçimi `Yalnız #...#` |
| Metin | Doğru `İ/i`, `I/ı` büyük/küçük harf, aksan duyarsız arama, Türk alfabesine göre sıralama |
| İl/ilçe | 81 il (plaka kodu, ad) ve 973 ilçenin tamamı; çevrimdışı, resmi veriden |
| Tatiller | 2429 sayılı Kanun'a göre resmi tatiller, Diyanet takviminden 2020–2035 Ramazan ve Kurban Bayramı, arife yarım günü, `isBusinessDay`, `addBusinessDays` |

### Kurulum

```yaml
dependencies:
  turkish_kit: ^0.2.0
```

### Doğrulama

```dart
TurkishValidators.isValidTcKimlik('10000000146');   // true
TurkishValidators.isValidVergiKimlik('1234567890'); // true
TurkishValidators.isValidIban('TR33 0006 1005 1978 6457 8413 26'); // true
TurkishValidators.normalizePhone('0532 123 45 67'); // '+905321234567'

// Flutter: turkish_kit_flutter paketi
TextFormField(
  inputFormatters: [TurkishInputMaskFormatter(TurkishInputMask.phone)],
  validator: TurkishFormValidators.phone(),
)
TurkishMoneyField(
  controller: TurkishMoneyController(mask: const TurkishMoneyInputMask(symbol: '₺')),
)
```

Kontrol basamakları numaranın biçimce doğru olduğunu gösterir; gerçek bir
kişiye, şirkete veya hesaba ait olduğunu kanıtlamaz.

**Para alanı:** `TurkishMoneyInputMask` yazarken `1.234,56 ₺` biçimini uygular.
Ortadan rakam eklerken veya silerken imleç kaymaz. Noktadan sonra geri silmek
önceki rakamı siler. Yalnız basılan nokta ondalık virgülü sayılır. Yapıştırılan
`1234.56`, `1.234,56` ve `₺1.234,56` anlaşılır. Ondalık hane sayısı (0-2), en
yüksek değer, negatif değer ve sembol ayarlanabilir. Değer `TurkishMoney` ya da
kuruş olarak okunur ve aynı kurallarla biçimlenir.

**Flutter neden ayrı pakette?** Flutter SDK'ya bağımlı bir paket, Flutter
yalnızca bir kütüphanesinde kullanılsa bile saf Dart projelerinde (sunucu,
CLI, ortak iş mantığı) hiç kullanılamaz. Bu yüzden turkish_kit saf Dart ve
bağımlılıksız kalır; doğrulayıcılar düz fonksiyondur, maske mantığı (imleç
dahil) saf Dart'tır ve burada test edilir.
[turkish_kit_flutter](https://pub.dev/packages/turkish_kit_flutter) bunu
yalnızca `TextInputFormatter`, `TextEditingController` ve hazır
`TurkishMoneyField` olarak Flutter'a bağlar.

### Tutar ve yazıyla tutar

```dart
final tutar = TurkishMoney.parse('1.234,50 ₺');
tutar.format();         // '1.234,50 ₺'
tutar.toWords();        // 'Bin İki Yüz Otuz Dört Türk Lirası Elli Kuruş'
tutar.toInvoiceText();  // 'Yalnız #Bin İki Yüz Otuz Dört Türk Lirası Elli Kuruş#'
TurkishMoney.fromDecimalString('1234.50'); // API/JSON biçimi
```

Sıfır `Sıfır Türk Lirası`, yalnız kuruş `Elli Kuruş`, negatif `Eksi ...`
olarak yazılır. İkiden fazla ondalık varsayılan olarak yukarı yuvarlanır
(`1,005` → `1,01`); `halfEven`, `truncate` ve `strict` seçenekleri vardır.
Yazıyla gösterim 10^36 − 1'e (desilyon) kadar desteklenir.

### Türkçe metin

```dart
'istanbul'.toTurkishUpperCase();       // 'İSTANBUL'
'IĞDIR'.toTurkishLowerCase();          // 'ığdır'
'Kağıthane'.turkishContains('kagit');  // true
isimler.sort(TurkishText.compare);     // Türk alfabesi sırası
TurkishNumberFormat.parse('1.234,56'); // 1234.56
```

### İl ve ilçeler

```dart
TurkishProvinces.byPlateCode(34)!.districts; // İstanbul'un 39 ilçesi
TurkishProvinces.byName('sanliurfa');        // Şanlıurfa
```

Kaynak: T.C. İçişleri Bakanlığı e-İçişleri "Mülki İdare Bölümleri"
(erişim 22.10.2026), Türkçe Vikipedi "Türkiye'nin ilçeleri" ile çapraz kontrol
edildi (973 ilçe, her ilde aynı sayı). Adlar resmi yazımla (`Hakkari`,
`Kahta`, `Kağıthane`); arama şapkayı yok saydığı için `Kâhta` da bulunur.
Büyükşehir olmayan 51 ilde merkez ilçe `Merkez` adını taşır. İl/ilçe adları
olgu ve resmi kayıttır (FSEK md. 31); Vikipedi metni pakete alınmadı.

### Tatiller ve iş günleri

```dart
TurkishHolidays.forYear(2026);
TurkishHolidays.isBusinessDay(DateTime(2026, 10, 29));      // false
TurkishHolidays.addBusinessDays(DateTime(2026, 5, 26), 1);  // 2026-06-01
```

Sabit tatiller 1982'den itibaren her yıl için hesaplanır (1 Mayıs 2009'dan,
15 Temmuz 2017'den beri). Dini bayramlar hesaplanamaz; **2020–2035** için
Diyanet takviminden tablo olarak gelir. Bu aralığın dışında yanlış sonuç
vermek yerine `RangeError` fırlatılır. 2028 ve 2029 Ramazan Bayramı için bazı
uluslararası takvimler bir gün sonrasını gösterir; Diyanet tarihi esas alındı. Arife ve 28 Ekim saat 13:00'ten
itibaren yarım gündür; varsayılan olarak iş günü sayılır. Hükümetin ayrıca
ilan ettiği idari izinler kanunda yoktur; `TurkishBusinessCalendar(extraHolidays: ...)`
ile ekleyin.

### Diğer paketlerden farkı

pub.dev'deki mevcut paketler tek bir parçayı kapsıyor (`turkish`,
`turkish_validators`, `tckn_check`, `amount_to_word`, `il_ilce`,
`turkiye_il_ilce_mahalle`, genel `iban` paketleri); çoğu Flutter'a bağımlı,
para için `double` kullanıyor veya veriyi ağdan çekiyor. Türk resmi tatilleri
ve VKN doğrulaması için paket yoktu. turkish_kit bunların hepsini bağımlılıksız,
saf Dart, tam sayı tabanlı para hesabı ve çevrimdışı resmi veriyle tek pakette
toplar.

### Diğer paketler

Aynı geliştiricinin [pub.dev](https://pub.dev/publishers/abdurrahmankaraoglu.com/packages)'deki diğer paketleri:
[turkish_kit_flutter](https://pub.dev/packages/turkish_kit_flutter) (bu paketin Flutter widget'ları),
[flutter_toastify](https://pub.dev/packages/flutter_toastify),
[google_maps_polyline](https://pub.dev/packages/google_maps_polyline),
[marker_crafter](https://pub.dev/packages/marker_crafter),
[animated_route_marker](https://pub.dev/packages/animated_route_marker),
[advanced_background_locator](https://pub.dev/packages/advanced_background_locator),
[advanced_geofence](https://pub.dev/packages/advanced_geofence),
[route_simulator](https://pub.dev/packages/route_simulator).

### Lisans

MIT. [LICENSE](LICENSE) dosyasına bakın.
