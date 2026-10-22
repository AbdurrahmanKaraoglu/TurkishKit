# turkish_kit example

A small Material 3 Flutter app (Turkish and English, follows the device
language, with a language menu) that shows every part of
[turkish_kit](https://pub.dev/packages/turkish_kit):

* **Validate** – T.C. kimlik, VKN, IBAN and phone fields with
  `TurkishFormValidators` and `TurkishInputMask` (via a 10-line
  `TextInputFormatter` adapter in `lib/src/widgets.dart`).
* **Amount** – `TurkishMoney` formatting, amounts in words and the
  `Yalnız #...#` invoice line.
* **Text** – Turkish upper/lower/title case and sorting next to Dart's
  defaults.
* **Provinces** – accent-insensitive search over 81 provinces and 973
  districts.
* **Holidays** – public holidays per year and a business-day calculator.

```bash
cd example
flutter run
```
