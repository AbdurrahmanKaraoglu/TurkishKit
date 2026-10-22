import 'package:flutter/services.dart';
import 'package:turkish_kit/turkish_kit.dart';

/// Formats a money field as `1.234,56` (optionally `1.234,56 ₺`) while the
/// user types, keeping the cursor where it belongs.
///
/// All rules live in the pure-Dart [TurkishMoneyInputMask]; this class only
/// converts between Flutter's [TextEditingValue] and the mask.
///
/// ```dart
/// TextField(
///   keyboardType: const TextInputType.numberWithOptions(decimal: true),
///   inputFormatters: [TurkishMoneyInputFormatter()],
/// )
/// ```
///
/// [TurkishMoneyField] sets this up for you.
class TurkishMoneyInputFormatter extends TextInputFormatter {
  /// Creates a formatter that uses [mask].
  TurkishMoneyInputFormatter([this.mask = const TurkishMoneyInputMask()]);

  /// The formatting rules.
  final TurkishMoneyInputMask mask;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final TurkishEditValue old = _toEdit(oldValue);
    final TurkishEditValue result = mask.apply(old, _toEdit(newValue));
    if (result == old) return oldValue;
    return TextEditingValue(
      text: result.text,
      selection: TextSelection(
        baseOffset: result.selectionStart,
        extentOffset: result.selectionEnd,
      ),
    );
  }
}

/// Adapts a [TurkishInputMask] (phone, IBAN, T.C. kimlik, VKN, date) to a
/// [TextInputFormatter].
///
/// ```dart
/// TextFormField(
///   keyboardType: TextInputType.phone,
///   inputFormatters: [TurkishInputMaskFormatter(TurkishInputMask.phone)],
///   validator: TurkishFormValidators.phone(),
/// )
/// ```
class TurkishInputMaskFormatter extends TextInputFormatter {
  /// Creates a formatter that uses [mask].
  TurkishInputMaskFormatter(this.mask);

  /// The mask pattern.
  final TurkishInputMask mask;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final TurkishMaskResult result = mask.apply(
      newValue.text,
      newValue.selection.isValid ? newValue.selection.end : null,
    );
    return TextEditingValue(
      text: result.text,
      selection: TextSelection.collapsed(offset: result.cursor),
    );
  }
}

TurkishEditValue _toEdit(TextEditingValue value) => (
  text: value.text,
  selectionStart: value.selection.isValid
      ? value.selection.baseOffset
      : value.text.length,
  selectionEnd: value.selection.isValid
      ? value.selection.extentOffset
      : value.text.length,
);
