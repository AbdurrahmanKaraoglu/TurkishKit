import 'package:flutter/material.dart';
import 'package:turkish_kit/turkish_kit.dart';

import 'app_strings.dart';
import 'app_theme.dart';
import 'widgets.dart';

const List<String> _words = <String>[
  'Zonguldak', 'Iğdır', 'Çorum', 'İzmir', 'Uşak', 'Şırnak', 'Ağrı', 'Ordu', 'Ödemiş', 'Siirt', 'Ünye', 'Gümüşhane', //
];

class TextPage extends StatefulWidget {
  const TextPage({super.key});

  @override
  State<TextPage> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  final TextEditingController _input = TextEditingController(text: 'ışık ılık süt iç, İSTANBUL');

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = AppStrings.of(context);
    final ThemeData theme = Theme.of(context);
    final String text = _input.text;
    final List<String> turkish = <String>[..._words]..sort(TurkishText.compare);
    final List<String> plain = <String>[..._words]..sort();

    return PageScaffold(
      title: strings.navText,
      subtitle: strings.textSubtitle,
      children: <Widget>[
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _input,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(labelText: strings.input, prefixIcon: const Icon(Icons.text_fields)),
              ),
              const SizedBox(height: Gap.sm),
              ResultRow(label: strings.upperCase, value: text.toTurkishUpperCase()),
              _DefaultHint(label: strings.dartDefault, value: text.toUpperCase()),
              const Divider(),
              ResultRow(label: strings.lowerCase, value: text.toTurkishLowerCase()),
              _DefaultHint(label: strings.dartDefault, value: text.toLowerCase()),
              const Divider(),
              ResultRow(label: strings.titleCase, value: text.toTurkishTitleCase()),
              const Divider(),
              ResultRow(label: strings.searchKey, value: text.toSearchKey()),
            ],
          ),
        ),
        SectionCard(
          title: strings.sorting,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: _SortColumn(title: strings.turkishOrder, words: turkish, highlight: true)),
              const SizedBox(width: Gap.md),
              Expanded(child: _SortColumn(title: strings.codeUnitOrder, words: plain, highlight: false)),
            ],
          ),
        ),
        Text(
          'TurkishText.compare · List.sort()',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _DefaultHint extends StatelessWidget {
  const _DefaultHint({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Text(
      '$label: $value',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.error,
        decoration: TextDecoration.lineThrough,
      ),
    );
  }
}

class _SortColumn extends StatelessWidget {
  const _SortColumn({required this.title, required this.words, required this.highlight});

  final String title;
  final List<String> words;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: highlight ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Gap.sm),
        for (int i = 0; i < words.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text('${i + 1}. ${words[i]}', style: theme.textTheme.bodyMedium),
          ),
      ],
    );
  }
}
