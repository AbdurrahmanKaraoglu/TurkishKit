# Turkish Kit Flutter

[![pub package](https://img.shields.io/pub/v/turkish_kit_flutter.svg)](https://pub.dev/packages/turkish_kit_flutter)

Flutter widgets for [turkish_kit](https://pub.dev/packages/turkish_kit):

* **`TurkishMoneyField`**: a money input that formats as `1.234,56 ₺` while
  you type, with a cursor that never jumps.
* **`TurkishMoneyController`**: reads and writes the amount as
  `TurkishMoney` or whole kuruş.
* **`TurkishMoneyInputFormatter`**: the same formatting for your own
  `TextField`.
* **`TurkishInputMaskFormatter`**: as-you-type formatting of phone numbers,
  IBANs, T.C. kimlik and VKN.

This package re-exports all of `turkish_kit` (validators, amounts in words,
Turkish text, provinces, holidays), so one import is enough.

Türkçe açıklama için [aşağıya](#türkçe) bakın.

## Installation

```yaml
dependencies:
  turkish_kit_flutter: ^0.2.0
```

```dart
import 'package:turkish_kit_flutter/turkish_kit_flutter.dart';
```

## Money field

```dart
final amount = TurkishMoneyController(
  money: TurkishMoney.lira(1250),            // shows '1.250,00 ₺'
  mask: TurkishMoneyInputMask(
    symbol: '₺',                             // '' for no symbol
    fractionDigits: 2,                       // 2, 1 or 0
    maxValue: TurkishMoney.lira(50000),      // optional
    allowNegative: false,
  ),
);

TurkishMoneyField(
  controller: amount,
  required: true,                            // empty is an error
  decoration: const InputDecoration(labelText: 'Tutar'),
  onChanged: (money) => print(money?.kurus),
  validator: (money) => money != null && money.isZero ? 'Sıfırdan büyük olmalı' : null,
);

amount.money;        // TurkishMoney(125000 kuruş) or null when empty
amount.kurus;        // 125000
amount.kurus = 99;   // shows '0,99 ₺'
```

What the field does:

| You do | You get |
| --- | --- |
| type `1234,5` | `1.234,5 ₺`, cursor after the 5 |
| type `1234.5` (keyboard without a comma) | `1.234,5 ₺` — a lone `.` is the decimal separator |
| type a digit in the middle of `1.2│34` | `12.9│34`, cursor stays after the new digit |
| backspace right after a `.` in `1.│234` | `│234`, the digit before the dot is deleted |
| delete (forward) on the `.` in `1│.234` | `1│34` |
| backspace after `₺` | the last digit is deleted |
| paste `1234.56`, `1.234,56`, `₺1.234,56`, `1 234,56 TL` | `1.234,56 ₺` |
| paste `1234.567` | `1.234,57 ₺` (rounded half up) |
| type a third decimal, or exceed `maxValue` | the keystroke is ignored |
| type `-` (with `allowNegative`) | toggles the sign |
| leave the field | `1.234,5` is completed to `1.234,50` |

It uses the numeric keyboard
(`TextInputType.numberWithOptions(decimal: true)`, plus `signed: true` with
`allowNegative`). The cursor cannot be placed after the symbol.

To use the formatting in your own field:

```dart
TextField(
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  inputFormatters: [TurkishMoneyInputFormatter(const TurkishMoneyInputMask(symbol: '₺'))],
)
```

## ID, IBAN and phone fields

```dart
TextFormField(
  keyboardType: TextInputType.phone,
  inputFormatters: [TurkishInputMaskFormatter(TurkishInputMask.phone)], // 0532 123 45 67
  validator: TurkishFormValidators.mobilePhone(),
)
```

Masks: `TurkishInputMask.phone`, `.iban`, `.tcKimlik`, `.vergiKimlik`,
`.date`.

## Why a separate package?

`turkish_kit` is pure Dart and has no dependencies, so it also works on
servers and in CLIs. A package that depends on the Flutter SDK cannot be used
there at all, even if Flutter is only imported from a separate library. So
the formatting rules (`TurkishMoneyInputMask`, `TurkishInputMask`) stay in
`turkish_kit`, and this package only adapts them to Flutter. Formatting and
parsing of amounts follow one set of rules, shared with `TurkishMoney`.

## Other packages

More packages by the same author on [pub.dev](https://pub.dev/publishers/abdurrahmankaraoglu.com/packages):

* [google_maps_polyline](https://pub.dev/packages/google_maps_polyline): Google Directions routes and polyline encode/decode (pure Dart)
* [marker_crafter](https://pub.dev/packages/marker_crafter): Custom Google Maps markers drawn with Canvas
* [animated_route_marker](https://pub.dev/packages/animated_route_marker): Smoothly animated map marker along a route or live GPS
* [advanced_background_locator](https://pub.dev/packages/advanced_background_locator): Background location tracking plugin (Android/iOS)
* [advanced_geofence](https://pub.dev/packages/advanced_geofence): Pure Dart geofencing engine: enter, exit and dwell events
* [route_simulator](https://pub.dev/packages/route_simulator): Realistic fake GPS streams for testing and demos
* [background_doctor](https://pub.dev/packages/background_doctor): Diagnoses why background work stops on Android and why the app was killed
* [scan_tally](https://pub.dev/packages/scan_tally): Continuous barcode scanning for stock counts: dedupe, tally, feedback, GS1
* [scan_tally_mobile_scanner](https://pub.dev/packages/scan_tally_mobile_scanner): mobile_scanner camera adapter for scan_tally
* [turkish_kit](https://pub.dev/packages/turkish_kit): Turkish validators, money in words, casing, provinces, holidays (pure Dart)
* [flutter_toastify](https://pub.dev/packages/flutter_toastify): Animated toast notifications

## License

MIT. See [LICENSE](LICENSE).

---

## Türkçe

[turkish_kit](https://pub.dev/packages/turkish_kit) için Flutter widget'ları:

* **`TurkishMoneyField`**: yazarken `1.234,56 ₺` biçimine giren, imleci
  kaymayan para alanı.
* **`TurkishMoneyController`**: tutarı `TurkishMoney` ya da kuruş tamsayısı
  olarak okur ve yazar.
* **`TurkishMoneyInputFormatter`**: aynı biçimlendirme, kendi `TextField`'ınız
  için.
* **`TurkishInputMaskFormatter`**: telefon, IBAN, T.C. kimlik ve VKN için
  yazarken biçimleme.

`turkish_kit`'in tamamını dışa aktarır; tek import yeterlidir.

### Kurulum

```yaml
dependencies:
  turkish_kit_flutter: ^0.2.0
```

### Para alanı

```dart
final tutar = TurkishMoneyController(mask: const TurkishMoneyInputMask(symbol: '₺'));

TurkishMoneyField(
  controller: tutar,
  required: true,
  decoration: const InputDecoration(labelText: 'Tutar'),
);

tutar.kurus;        // kuruş olarak değer (boşsa null)
tutar.kurus = 99;   // alanda '0,99 ₺'
```

* Rakamlar yazıldıkça binlik ayracı eklenir; ortadan rakam eklerken veya
  silerken imleç yerinde kalır.
* Noktadan hemen sonra geri silme, noktanın önündeki rakamı siler. İleri
  silme de noktanın arkasındaki rakamı siler.
* Virgül ondalığı başlatır. Yalnız basılan nokta da ondalık ayracı sayılır,
  çünkü bazı sayısal klavyelerde virgül yoktur.
* Yapıştırmada `1234.56`, `1.234,56`, `₺1.234,56`, `1 234,56 TL` kabul edilir.
  Fazla ondalık yukarı yuvarlanır (`1234.567` → `1.234,57`).
* Üçüncü ondalık hane ya da `maxValue` aşımı yazılmaz. `allowNegative` ile
  `-` işareti değiştirir.
* Alandan çıkınca `1.234,5` → `1.234,50` olarak tamamlanır.
* Sayısal klavye kullanılır. İmleç sembolün arkasına geçemez.

### Neden ayrı paket?

`turkish_kit` saf Dart'tır ve bağımlılığı yoktur; sunucuda ve CLI'da da
çalışır. Flutter SDK'ya bağımlı bir paket, Flutter yalnızca ayrı bir
kütüphanede kullanılsa bile oralarda hiç kullanılamaz. Bu yüzden biçim
kuralları (`TurkishMoneyInputMask`, `TurkishInputMask`) `turkish_kit`'te
kalır; bu paket onları yalnızca Flutter'a bağlar. Tutar biçimleme ve
ayrıştırma `TurkishMoney` ile aynı kuralları paylaşır.

### Diğer paketler

Aynı geliştiricinin [pub.dev](https://pub.dev/publishers/abdurrahmankaraoglu.com/packages)'deki diğer paketleri:

* [google_maps_polyline](https://pub.dev/packages/google_maps_polyline): Google Directions rotası ve polyline kodlama/çözme (saf Dart)
* [marker_crafter](https://pub.dev/packages/marker_crafter): Canvas ile çizilen özel Google Maps işaretçileri
* [animated_route_marker](https://pub.dev/packages/animated_route_marker): Rota ya da canlı GPS üzerinde akıcı hareket eden harita işaretçisi
* [advanced_background_locator](https://pub.dev/packages/advanced_background_locator): Arka planda konum takibi eklentisi (Android/iOS)
* [advanced_geofence](https://pub.dev/packages/advanced_geofence): Saf Dart geofence motoru: giriş, çıkış ve bekleme olayları
* [route_simulator](https://pub.dev/packages/route_simulator): Test ve demo için gerçekçi sahte GPS akışı
* [background_doctor](https://pub.dev/packages/background_doctor): Android'de arka plan işinin neden durduğunu ve uygulamanın neden kapandığını teşhis eder
* [scan_tally](https://pub.dev/packages/scan_tally): Stok sayımı için sürekli barkod okutma: tekrar ayıklama, sayım, geri bildirim, GS1
* [scan_tally_mobile_scanner](https://pub.dev/packages/scan_tally_mobile_scanner): scan_tally için mobile_scanner kamera adaptörü
* [turkish_kit](https://pub.dev/packages/turkish_kit): Türkçe doğrulayıcılar, tutarı yazıyla yazma, harf dönüşümü, il/ilçe, tatiller (saf Dart)
* [flutter_toastify](https://pub.dev/packages/flutter_toastify): Animasyonlu toast bildirimleri

### Lisans

MIT. [LICENSE](LICENSE) dosyasına bakın.
