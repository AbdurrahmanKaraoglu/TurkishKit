import 'package:flutter/material.dart';
import 'package:turkish_kit/turkish_kit.dart';

import 'formatters.dart';
import 'money_controller.dart';

/// A ready-made Turkish money input: a [TextFormField] that formats as
/// `1.234,56 ₺` while typing, uses the numeric keyboard and reports the
/// amount as [TurkishMoney].
///
/// ```dart
/// TurkishMoneyField(
///   decoration: const InputDecoration(labelText: 'Tutar'),
///   onChanged: (money) => print(money?.kurus),
///   validator: (money) =>
///       money != null && money.isZero ? 'Sıfırdan büyük olmalı' : null,
/// )
/// ```
///
/// Formatting rules come from [mask] (or from the [controller]'s mask when a
/// controller is given). When the field loses focus, the decimals are padded
/// (`1.234,5` → `1.234,50`) unless [completeOnUnfocus] is false.
class TurkishMoneyField extends StatefulWidget {
  /// Creates a money field.
  const TurkishMoneyField({
    super.key,
    this.controller,
    this.mask,
    this.initialValue,
    this.decoration = const InputDecoration(),
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.required = false,
    this.requiredMessage,
    this.autovalidateMode,
    this.focusNode,
    this.autofocus = false,
    this.enabled,
    this.readOnly = false,
    this.style,
    this.textAlign = TextAlign.start,
    this.textInputAction,
    this.completeOnUnfocus = true,
  }) : assert(
         controller == null || (mask == null && initialValue == null),
         'Pass the mask and the initial value to the controller instead.',
       );

  /// Controls the text; read the amount with [TurkishMoneyController.money].
  /// When `null`, the field creates its own.
  final TurkishMoneyController? controller;

  /// The formatting rules when no [controller] is given. Defaults to two
  /// decimals with a `₺` suffix.
  final TurkishMoneyInputMask? mask;

  /// The amount shown first when no [controller] is given.
  final TurkishMoney? initialValue;

  /// The decoration of the underlying [TextFormField].
  final InputDecoration decoration;

  /// Called with the new amount (or `null` when empty) after every edit.
  final ValueChanged<TurkishMoney?>? onChanged;

  /// Called with the amount when the user submits the field.
  final ValueChanged<TurkishMoney?>? onFieldSubmitted;

  /// Validates the amount (`null` when empty); return an error text or
  /// `null`. Runs after the [required] check.
  final String? Function(TurkishMoney? money)? validator;

  /// Whether an empty field is an error ([requiredMessage]).
  final bool required;

  /// The error for an empty [required] field. Defaults to
  /// [TurkishValidationMessages.tr]'s `required` text.
  final String? requiredMessage;

  /// See [TextFormField.autovalidateMode].
  final AutovalidateMode? autovalidateMode;

  /// See [TextField.focusNode].
  final FocusNode? focusNode;

  /// See [TextField.autofocus].
  final bool autofocus;

  /// See [TextField.enabled].
  final bool? enabled;

  /// See [TextField.readOnly].
  final bool readOnly;

  /// See [TextField.style].
  final TextStyle? style;

  /// See [TextField.textAlign].
  final TextAlign textAlign;

  /// See [TextField.textInputAction].
  final TextInputAction? textInputAction;

  /// Whether to pad the decimals when the field loses focus.
  final bool completeOnUnfocus;

  @override
  State<TurkishMoneyField> createState() => _TurkishMoneyFieldState();
}

const TurkishMoneyInputMask _defaultMask = TurkishMoneyInputMask(symbol: '₺');

class _TurkishMoneyFieldState extends State<TurkishMoneyField> {
  TurkishMoneyController? _ownController;
  FocusNode? _ownFocusNode;

  TurkishMoneyController get _controller =>
      widget.controller ??
      (_ownController ??= TurkishMoneyController(
        money: widget.initialValue,
        mask: widget.mask ?? _defaultMask,
      ));

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(TurkishMoneyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final TurkishMoneyController? own = _ownController;
    if (widget.controller == null &&
        own != null &&
        widget.mask != oldWidget.mask &&
        (widget.mask ?? _defaultMask) != own.mask) {
      // The rules changed: carry the amount over to a new controller.
      TurkishMoney? money = own.money;
      final TurkishMoneyInputMask mask = widget.mask ?? _defaultMask;
      try {
        mask.format(money);
      } on ArgumentError {
        money = null;
      }
      _ownController = TurkishMoneyController(money: money, mask: mask);
      WidgetsBinding.instance.addPostFrameCallback((_) => own.dispose());
    }
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_onFocusChange);
      _focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _ownFocusNode?.dispose();
    _ownController?.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && widget.completeOnUnfocus) {
      final String before = _controller.text;
      _controller.complete();
      if (_controller.text != before) widget.onChanged?.call(_controller.money);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TurkishMoneyInputMask mask = _controller.mask;
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: widget.decoration,
      keyboardType: TextInputType.numberWithOptions(
        decimal: mask.fractionDigits > 0,
        signed: mask.allowNegative,
      ),
      inputFormatters: <TurkishMoneyInputFormatter>[
        TurkishMoneyInputFormatter(mask),
      ],
      autovalidateMode: widget.autovalidateMode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      style: widget.style,
      textAlign: widget.textAlign,
      textInputAction: widget.textInputAction,
      onChanged: (String text) => widget.onChanged?.call(mask.parse(text)),
      onFieldSubmitted: (String text) =>
          widget.onFieldSubmitted?.call(mask.parse(text)),
      validator: (String? text) {
        final TurkishMoney? money = mask.parse(text ?? '');
        if (money == null && widget.required) {
          return widget.requiredMessage ??
              TurkishValidationMessages.tr.required;
        }
        return widget.validator?.call(money);
      },
    );
  }
}
