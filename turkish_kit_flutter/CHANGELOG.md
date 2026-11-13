## 0.3.0

* **Breaking:** the widgets now use
  [material_ui](https://pub.dev/packages/material_ui) instead of
  `package:flutter/material.dart`, which is deprecated in Flutter 3.50.
  `TurkishMoneyField.decoration` takes material_ui's `InputDecoration`; import
  it from `package:material_ui/material_ui.dart` (or run
  `dart fix --apply --code=migrate_design_widgets` on Flutter 3.50).
* Requires Flutter 3.47.0 / Dart 3.13 or later (material_ui 1.11.0).
* Accepts turkish_kit 0.2.x and 0.3.x.
* Example and tests use material_ui.

**Türkçe**

* **Kırıcı değişiklik:** widget'lar artık Flutter 3.50'de kullanımdan kalkan
  `package:flutter/material.dart` yerine
  [material_ui](https://pub.dev/packages/material_ui) kullanıyor.
  `TurkishMoneyField.decoration`, material_ui'ın `InputDecoration` sınıfını
  alıyor; onu `package:material_ui/material_ui.dart`'tan içe aktarın (ya da
  Flutter 3.50'de `dart fix --apply --code=migrate_design_widgets` çalıştırın).
* Flutter 3.47.0 / Dart 3.13 veya üstü gerekiyor (material_ui 1.11.0).
* turkish_kit 0.2.x ve 0.3.x ile çalışıyor.
* Örnek ve testler material_ui kullanıyor.

## 0.2.1

* DOCS: README "Other packages" list updated to all 11 other packages by the
  author, with links to pub.dev.

**Türkçe**

* DOCS: README'deki "Diğer paketler" listesi geliştiricinin diğer 11 paketini
  pub.dev bağlantılarıyla gösterecek şekilde güncellendi.

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
