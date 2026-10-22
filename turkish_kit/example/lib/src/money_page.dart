import 'package:flutter/material.dart';
import 'package:turkish_kit_flutter/turkish_kit_flutter.dart';

import 'app_strings.dart';
import 'app_theme.dart';
import 'widgets.dart';

class MoneyPage extends StatefulWidget {
  const MoneyPage({super.key});

  @override
  State<MoneyPage> createState() => _MoneyPageState();
}

class _MoneyPageState extends State<MoneyPage> {
  final TurkishMoneyController _amount = TurkishMoneyController(
    money: TurkishMoney.fromKurus(123450),
    mask: TurkishMoneyInputMask(
      symbol: '₺',
      allowNegative: true,
      maxValue: TurkishMoney.lira(999999999999),
    ),
  );
  TurkishWordCase _case = TurkishWordCase.title;
  bool _compact = false;
  bool _short = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = AppStrings.of(context);
    final TurkishMoney? money = _amount.money;
    final String currency = _short ? 'TL' : 'Türk Lirası';
    final String subunit = _short ? 'Kr' : 'Kuruş';
    final String separator = _compact ? '' : ' ';

    return PageScaffold(
      title: strings.navMoney,
      subtitle: strings.moneySubtitle,
      children: <Widget>[
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TurkishMoneyField(
                controller: _amount,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: strings.amount,
                  helperText: strings.amountHelper,
                  prefixIcon: const Icon(Icons.payments_outlined),
                ),
              ),
              const SizedBox(height: Gap.md),
              Text(
                strings.wordCase,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: Gap.sm),
              SegmentedButton<TurkishWordCase>(
                showSelectedIcon: false,
                segments: <ButtonSegment<TurkishWordCase>>[
                  ButtonSegment<TurkishWordCase>(
                    value: TurkishWordCase.title,
                    label: Text(strings.caseTitle),
                  ),
                  ButtonSegment<TurkishWordCase>(
                    value: TurkishWordCase.upper,
                    label: Text(strings.caseUpper),
                  ),
                  ButtonSegment<TurkishWordCase>(
                    value: TurkishWordCase.lower,
                    label: Text(strings.caseLower),
                  ),
                ],
                selected: <TurkishWordCase>{_case},
                onSelectionChanged: (Set<TurkishWordCase> value) =>
                    setState(() => _case = value.first),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(strings.compact),
                value: _compact,
                onChanged: (bool value) => setState(() => _compact = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(strings.shortUnits),
                value: _short,
                onChanged: (bool value) => setState(() => _short = value),
              ),
            ],
          ),
        ),
        if (money != null)
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ResultRow(label: strings.formatted, value: money.format()),
                const Divider(),
                ResultRow(label: strings.kurusValue, value: '${money.kurus}'),
                const Divider(),
                ResultRow(
                  label: strings.inWords,
                  value: money.toWords(
                    wordCase: _case,
                    currency: currency,
                    subunit: subunit,
                    separator: separator,
                  ),
                ),
                const Divider(),
                ResultRow(
                  label: strings.invoice,
                  value: money.toInvoiceText(
                    wordCase: _case,
                    currency: currency,
                    subunit: subunit,
                    separator: separator,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
