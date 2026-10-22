## 0.1.1

* Phone numbers with a trunk 0 after the country code are accepted:
  `+90 (0532) 123 45 67`, `0090 0532 …`, `90 0532 …`.
* `TurkishInputMask.phone` absorbs a country code typed digit by digit
  (`+90 5…` no longer becomes `0905…`).
* IBANs written with dashes are accepted (`normalizeIban` removes them).
* `TurkishNumberFormat.format` works for doubles of 1e21 and more (it
  printed `1e.+21`).
* `TurkishNumberFormat.tryParse` returns a `double` for integers too large
  for an `int` instead of `null`.
* Thousands separators must be consistent: `1.234 567` is rejected (applies
  to `TurkishMoney.parse` too).
* `TurkishText.compare`: ties are broken like Unicode collation, circumflex
  first and then case, over the whole string (`kahta`, `Kahta`, `kâhta`,
  `Kâhta`).
* Example app: the business-day calculator shows a message instead of an
  error when the result falls outside 2020–2035.
* README: every example is now checked by `test/readme_test.dart`; links to
  the author's other packages.

**Türkçe**

* Ülke kodundan sonra 0 içeren telefon numaraları kabul ediliyor:
  `+90 (0532) 123 45 67`, `0090 0532 …`, `90 0532 …`.
* `TurkishInputMask.phone`, rakam rakam yazılan ülke kodunu yutuyor
  (`+90 5…` artık `0905…` olmuyor).
* Tireli yazılmış IBAN kabul ediliyor (`normalizeIban` tireleri siliyor).
* `TurkishNumberFormat.format`, 1e21 ve üstü double değerlerde doğru çalışıyor
  (önceden `1e.+21` yazıyordu).
* `TurkishNumberFormat.tryParse`, `int`'e sığmayan tam sayılar için `null`
  yerine `double` döndürüyor.
* Binlik ayırıcılar tutarlı olmalı: `1.234 567` reddediliyor
  (`TurkishMoney.parse` için de).
* `TurkishText.compare`: eşitlikler Unicode sıralamasındaki gibi, tüm metin
  boyunca önce şapkaya sonra büyük/küçük harfe göre bozuluyor (`kahta`,
  `Kahta`, `kâhta`, `Kâhta`).
* Örnek uygulama: iş günü hesabı sonuç 2020–2035 dışına çıkınca hata yerine
  mesaj gösteriyor.
* README: tüm örnekler artık `test/readme_test.dart` ile doğrulanıyor;
  geliştiricinin diğer paketlerine bağlantılar eklendi.

## 0.1.0

* First release.
* `TurkishValidators`: T.C. kimlik no, vergi kimlik no (VKN), tax number
  (VKN or TCKN), TR IBAN (mod-97) and Turkish phone numbers (validate,
  normalize to E.164, format, mobile/landline/non-geographic).
* `TurkishFormValidators`: `TextFormField`-ready validators with Turkish and
  English messages; `TurkishInputMask` for as-you-type formatting with
  cursor mapping.
* `TurkishMoney`: exact amounts in kuruş, Turkish formatting and parsing,
  rounding modes, amounts in words and the `Yalnız #...#` invoice style.
  `TurkishNumberWords` and `TurkishNumberFormat` for plain numbers.
* `TurkishText`: Turkish upper/lower/title case, search normalization and
  alphabetical sorting.
* `TurkishProvinces`: 81 provinces and 973 districts from the official
  e-İçişleri list (2026-10-22).
* `TurkishHolidays` and `TurkishBusinessCalendar`: public holidays under Law
  2429, Ramazan and Kurban Bayramı 2020–2035 from the Diyanet calendar,
  arife half days, working-day arithmetic.

**Türkçe**

* İlk sürüm.
* `TurkishValidators`: T.C. kimlik no, vergi kimlik no (VKN), vergi numarası
  (VKN veya TCKN), TR IBAN (mod-97) ve Türk telefon numaraları (doğrulama,
  E.164'e normalleştirme, biçimlendirme, cep/sabit/coğrafi olmayan).
* `TurkishFormValidators`: Türkçe ve İngilizce mesajlı, `TextFormField`'a
  doğrudan verilebilen doğrulayıcılar; yazarken biçimleyen ve imleci koruyan
  `TurkishInputMask`.
* `TurkishMoney`: kuruş cinsinden tam tutar, Türkçe biçimlendirme ve
  ayrıştırma, yuvarlama seçenekleri, tutarı yazıyla yazma ve `Yalnız #...#`
  fatura biçimi. Düz sayılar için `TurkishNumberWords` ve
  `TurkishNumberFormat`.
* `TurkishText`: Türkçe büyük/küçük/baş harf dönüşümü, arama normalleştirme ve
  alfabetik sıralama.
* `TurkishProvinces`: resmi e-İçişleri listesinden 81 il ve 973 ilçe
  (22.10.2026).
* `TurkishHolidays` ve `TurkishBusinessCalendar`: 2429 sayılı Kanun'a göre
  resmi tatiller, Diyanet takviminden 2020–2035 Ramazan ve Kurban Bayramı,
  arife yarım günleri, iş günü hesabı.
