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

---

## 0.1.0 (Türkçe)

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
