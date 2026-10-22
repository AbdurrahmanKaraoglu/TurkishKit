## 0.2.0

* First release, versioned together with turkish_kit 0.2.0.
* `TurkishMoneyField`: a money input formatted as `1.234,56 ₺` while typing,
  with a steady cursor, numeric keyboard, `required` and `validator`, and
  decimals completed when focus leaves.
* `TurkishMoneyController`: read and write the amount as `TurkishMoney` or
  kuruş; the cursor cannot move past the symbol.
* `TurkishMoneyInputFormatter` and `TurkishInputMaskFormatter`: Flutter
  adapters for turkish_kit's `TurkishMoneyInputMask` and `TurkishInputMask`.
* Re-exports `package:turkish_kit/turkish_kit.dart`.

**Türkçe**

* İlk sürüm; turkish_kit 0.2.0 ile aynı sürüm numarasını taşır.
* `TurkishMoneyField`: yazarken `1.234,56 ₺` biçimine giren, imleci kaymayan,
  sayısal klavyeli, `required` ve `validator` destekli, odaktan çıkınca
  ondalığı tamamlayan para alanı.
* `TurkishMoneyController`: tutarı `TurkishMoney` ya da kuruş olarak okur ve
  yazar; imleç sembolün arkasına geçemez.
* `TurkishMoneyInputFormatter` ve `TurkishInputMaskFormatter`: turkish_kit'in
  `TurkishMoneyInputMask` ve `TurkishInputMask` kuralları için Flutter
  bağdaştırıcıları.
* `package:turkish_kit/turkish_kit.dart` dışa aktarılır.
