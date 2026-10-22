import 'package:flutter/widgets.dart';
import 'package:turkish_kit/turkish_kit.dart';

/// A [TextEditingController] for a Turkish money field that reads and writes
/// the amount as [TurkishMoney] or as whole kuruş.
///
/// ```dart
/// final controller = TurkishMoneyController(money: TurkishMoney.lira(1250));
/// controller.text;   // '1.250,00 ₺'
/// controller.kurus;  // 125000
/// controller.kurus = 99; // shows '0,99 ₺'
/// ```
///
/// The cursor can never be placed after the currency symbol.
class TurkishMoneyController extends TextEditingController {
  /// Creates a controller showing [money] (empty when `null`).
  TurkishMoneyController({
    TurkishMoney? money,
    this.mask = const TurkishMoneyInputMask(symbol: '₺'),
  }) : super(text: mask.format(money));

  /// Creates a controller showing [kurus] kuruş (empty when `null`).
  TurkishMoneyController.fromKurus(
    int? kurus, {
    TurkishMoneyInputMask mask = const TurkishMoneyInputMask(symbol: '₺'),
  }) : this(
         money: kurus == null ? null : TurkishMoney.fromKurus(kurus),
         mask: mask,
       );

  /// The formatting rules, shared with [TurkishMoneyField] and
  /// `TurkishMoneyInputFormatter`.
  final TurkishMoneyInputMask mask;

  /// The amount in the field, or `null` when it is empty or only `-`.
  TurkishMoney? get money => mask.parse(text);

  /// Shows [money] in the field (clears it for `null`) and puts the cursor
  /// at the end. Throws an [ArgumentError] if [money] has more decimals than
  /// the mask allows.
  set money(TurkishMoney? money) {
    final String formatted = mask.format(money);
    value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: mask.maxCursor(formatted)),
    );
  }

  /// The amount in kuruş, or `null` when the field is empty. For amounts
  /// beyond the `int` range use [money].
  int? get kurus => money?.kurus.toInt();

  /// Shows [kurus] kuruş in the field (clears it for `null`).
  set kurus(int? kurus) =>
      money = kurus == null ? null : TurkishMoney.fromKurus(kurus);

  /// Pads the decimals and clears an incomplete value (`1.234,5` →
  /// `1.234,50`, `-` → empty). [TurkishMoneyField] calls this when the field
  /// loses focus.
  void complete() {
    final String completed = mask.complete(text);
    if (completed != text) {
      value = TextEditingValue(
        text: completed,
        selection: TextSelection.collapsed(offset: mask.maxCursor(completed)),
      );
    }
  }

  @override
  set value(TextEditingValue newValue) {
    final TextSelection selection = newValue.selection;
    final int limit = mask.maxCursor(newValue.text);
    if (selection.isValid &&
        selection.isCollapsed &&
        selection.baseOffset > limit) {
      newValue = newValue.copyWith(
        selection: TextSelection.collapsed(offset: limit),
      );
    }
    super.value = newValue;
  }
}
