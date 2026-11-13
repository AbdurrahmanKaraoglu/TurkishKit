// A minimal form with a Turkish money field and a phone field.
// The full demo app (Turkish/English, all features) is in the repository:
// https://github.com/AbdurrahmanKaraoglu/TurkishKit/tree/main/turkish_kit/example
import 'package:flutter/material.dart';
import 'package:turkish_kit_flutter/turkish_kit_flutter.dart';

void main() => runApp(const MaterialApp(home: PaymentForm()));

class PaymentForm extends StatefulWidget {
  const PaymentForm({super.key});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TurkishMoneyController _amount = TurkishMoneyController(
    mask: TurkishMoneyInputMask(
      symbol: '₺',
      maxValue: TurkishMoney.lira(50000),
    ),
  );

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState!.validate()) {
      final TurkishMoney money = _amount.money!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(money.toInvoiceText())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ödeme')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TurkishMoneyField(
              controller: _amount,
              required: true,
              decoration: const InputDecoration(labelText: 'Tutar'),
              validator: (TurkishMoney? money) => money != null && money.isZero
                  ? 'Sıfırdan büyük olmalı'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              keyboardType: TextInputType.phone,
              inputFormatters: <TurkishInputMaskFormatter>[
                TurkishInputMaskFormatter(TurkishInputMask.phone),
              ],
              decoration: const InputDecoration(labelText: 'Telefon'),
              validator: TurkishFormValidators.mobilePhone(),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _submit, child: const Text('Öde')),
          ],
        ),
      ),
    );
  }
}
