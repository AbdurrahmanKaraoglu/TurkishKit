import 'package:flutter/material.dart';
import 'package:turkish_kit/turkish_kit.dart';

import 'app_strings.dart';
import 'app_theme.dart';
import 'widgets.dart';

class ValidatePage extends StatefulWidget {
  const ValidatePage({super.key});

  @override
  State<ValidatePage> createState() => _ValidatePageState();
}

class _ValidatePageState extends State<ValidatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _tc = TextEditingController();
  final TextEditingController _vkn = TextEditingController();
  final TextEditingController _iban = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (final TextEditingController c in <TextEditingController>[
      _iban,
      _phone,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _tc.dispose();
    _vkn.dispose();
    _iban.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _fillSample() {
    // Checksum-valid sample values (not real people or accounts).
    _tc.text = '10000000146';
    _vkn.text = '1234567890';
    _iban.text = TurkishInputMask.iban.format('TR330006100519786457841326');
    _phone.text = TurkishInputMask.phone.format('05321234567');
    _formKey.currentState?.validate();
  }

  void _checkAll(AppStrings strings) {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(strings.allValid)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = AppStrings.of(context);
    final TurkishValidationMessages messages = strings.messages;
    final String? bank = TurkishValidators.ibanBankCode(_iban.text);
    final String? e164 = TurkishValidators.normalizePhone(_phone.text);
    final TurkishPhoneType? type = TurkishValidators.phoneType(_phone.text);

    return PageScaffold(
      title: strings.navValidate,
      subtitle: strings.validateSubtitle,
      children: <Widget>[
        SectionCard(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _tc,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TurkishMaskFormatter>[
                    TurkishMaskFormatter(TurkishInputMask.tcKimlik),
                  ],
                  decoration: InputDecoration(
                    labelText: strings.tcKimlik,
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                  validator: TurkishFormValidators.tcKimlik(messages: messages),
                ),
                const SizedBox(height: Gap.md),
                TextFormField(
                  controller: _vkn,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TurkishMaskFormatter>[
                    TurkishMaskFormatter(TurkishInputMask.vergiKimlik),
                  ],
                  decoration: InputDecoration(
                    labelText: strings.vergiKimlik,
                    prefixIcon: const Icon(Icons.business_outlined),
                  ),
                  validator: TurkishFormValidators.vergiKimlik(
                    messages: messages,
                  ),
                ),
                const SizedBox(height: Gap.md),
                TextFormField(
                  controller: _iban,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TurkishMaskFormatter>[
                    TurkishMaskFormatter(TurkishInputMask.iban),
                  ],
                  decoration: InputDecoration(
                    labelText: strings.iban,
                    hintText: 'TR00 0000 0000 0000 0000 0000 00',
                    prefixIcon: const Icon(Icons.account_balance_outlined),
                    helperText: bank == null ? null : strings.bankCode(bank),
                  ),
                  validator: TurkishFormValidators.iban(messages: messages),
                ),
                const SizedBox(height: Gap.md),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: <TurkishMaskFormatter>[
                    TurkishMaskFormatter(TurkishInputMask.phone),
                  ],
                  decoration: InputDecoration(
                    labelText: strings.phone,
                    hintText: '05xx xxx xx xx',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    helperText: e164 == null || type == null
                        ? null
                        : strings.phoneInfo(e164, type),
                  ),
                  validator: TurkishFormValidators.phone(messages: messages),
                ),
                const SizedBox(height: Gap.lg),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _fillSample,
                        icon: const Icon(Icons.auto_fix_high_outlined),
                        label: Text(strings.fillSample),
                      ),
                    ),
                    const SizedBox(width: Gap.sm),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _checkAll(strings),
                        icon: const Icon(Icons.verified_outlined),
                        label: Text(strings.checkAll),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
