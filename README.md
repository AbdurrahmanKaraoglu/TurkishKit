# Turkish Kit

Turkish helpers for Dart and Flutter, in two packages:

| Package | What it is |
| --- | --- |
| [turkish_kit](turkish_kit/) · [pub.dev](https://pub.dev/packages/turkish_kit) | Pure Dart, no dependencies: TC kimlik / VKN / IBAN / phone validators, amounts in words, Turkish casing and sorting, 81 provinces and 973 districts, holidays and business days, input masks (including a money mask). |
| [turkish_kit_flutter](turkish_kit_flutter/) · [pub.dev](https://pub.dev/packages/turkish_kit_flutter) | Flutter widgets on top of it: `TurkishMoneyField` (`1.234,56 ₺` with a steady cursor), `TurkishMoneyController`, input formatters. |

The Flutter demo app (Turkish/English) is in [turkish_kit/example](turkish_kit/example/).

```bash
cd turkish_kit && dart test
cd turkish_kit_flutter && flutter test
```

---

Dart ve Flutter için Türkçe yardımcılar, iki pakette:
[turkish_kit](turkish_kit/) (saf Dart, bağımlılıksız) ve
[turkish_kit_flutter](turkish_kit_flutter/) (Flutter widget'ları: imleci
kaymayan para alanı, biçimleyiciler). Örnek uygulama
[turkish_kit/example](turkish_kit/example/) klasöründe.

MIT License.
