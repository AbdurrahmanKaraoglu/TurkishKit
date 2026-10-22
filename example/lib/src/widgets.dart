import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:turkish_kit/turkish_kit.dart';

import 'app_strings.dart';
import 'app_theme.dart';

/// Adapts a pure-Dart [TurkishInputMask] to Flutter's [TextInputFormatter].
///
/// turkish_kit has no Flutter dependency; this is all the glue an app needs.
class TurkishMaskFormatter extends TextInputFormatter {
  TurkishMaskFormatter(this.mask);

  final TurkishInputMask mask;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final TurkishMaskResult result = mask.apply(
      newValue.text,
      newValue.selection.end,
    );
    return TextEditingValue(
      text: result.text,
      selection: TextSelection.collapsed(offset: result.cursor),
    );
  }
}

/// A page scaffold with a large title, a subtitle and the language menu.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const <Widget>[LanguageMenu()],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Gap.md, 0, Gap.md, Gap.lg),
              children: <Widget>[
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Gap.md),
                for (final Widget child in children) ...<Widget>[
                  child,
                  const SizedBox(height: Gap.md),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A flat card with an optional section title.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gap.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (title != null) ...<Widget>[
              Text(
                title!,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Gap.sm),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

/// A labelled, selectable result line with a copy button.
class ResultRow extends StatelessWidget {
  const ResultRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppStrings strings = AppStrings.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Gap.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
          IconButton(
            tooltip: strings.copy,
            icon: const Icon(Icons.copy_rounded, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(strings.copied),
                    duration: const Duration(seconds: 1),
                  ),
                );
            },
          ),
        ],
      ),
    );
  }
}

/// Switches between device language, Turkish and English.
class LanguageMenu extends StatelessWidget {
  const LanguageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = AppStrings.of(context);
    return PopupMenuButton<String>(
      tooltip: strings.language,
      icon: const Icon(Icons.translate_rounded),
      onSelected: (String code) =>
          appLocale.value = code.isEmpty ? null : Locale(code),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        CheckedPopupMenuItem<String>(
          value: '',
          checked: appLocale.value == null,
          child: Text(strings.systemLanguage),
        ),
        CheckedPopupMenuItem<String>(
          value: 'tr',
          checked: appLocale.value?.languageCode == 'tr',
          child: const Text('Türkçe'),
        ),
        CheckedPopupMenuItem<String>(
          value: 'en',
          checked: appLocale.value?.languageCode == 'en',
          child: const Text('English'),
        ),
      ],
    );
  }
}
