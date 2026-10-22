import 'package:flutter/material.dart';
import 'package:turkish_kit/turkish_kit.dart';

import 'app_strings.dart';
import 'app_theme.dart';
import 'widgets.dart';

class ProvincesPage extends StatefulWidget {
  const ProvincesPage({super.key});

  @override
  State<ProvincesPage> createState() => _ProvincesPageState();
}

class _ProvincesPageState extends State<ProvincesPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = AppStrings.of(context);
    final String key = _query.toSearchKey();
    final List<(TurkishProvince, List<String>)> rows =
        <(TurkishProvince, List<String>)>[
          for (final TurkishProvince province in TurkishProvinces.all)
            if (key.isEmpty || province.name.turkishContains(key))
              (province, const <String>[])
            else if (province.districts.any(
              (String d) => d.turkishContains(key),
            ))
              (
                province,
                province.districts
                    .where((String d) => d.turkishContains(key))
                    .toList(),
              ),
        ];

    return PageScaffold(
      title: strings.navProvinces,
      subtitle: strings.provincesSubtitle(
        TurkishProvinces.all.length,
        TurkishProvinces.districtCount,
      ),
      children: <Widget>[
        TextField(
          onChanged: (String value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: strings.searchHint,
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: rows.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(Gap.lg),
                  child: Center(child: Text(strings.noResults)),
                )
              : Column(
                  children: <Widget>[
                    for (int i = 0; i < rows.length; i++) ...<Widget>[
                      if (i > 0) const Divider(),
                      _ProvinceTile(province: rows[i].$1, matches: rows[i].$2),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _ProvinceTile extends StatelessWidget {
  const _ProvinceTile({required this.province, required this.matches});

  final TurkishProvince province;
  final List<String> matches;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = AppStrings.of(context);
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return ExpansionTile(
      key: PageStorageKey<int>(province.plateCode),
      shape: const Border(),
      leading: Container(
        width: 44,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          province.plateCodeText,
          style: theme.textTheme.titleSmall?.copyWith(
            color: scheme.onPrimaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(province.name),
      subtitle: Text(
        matches.isEmpty
            ? strings.districtCount(province.districts.length)
            : strings.matchingDistricts(matches.join(', ')),
      ),
      trailing: province.isMetropolitan
          ? Chip(
              label: Text(strings.metropolitan),
              visualDensity: VisualDensity.compact,
            )
          : null,
      childrenPadding: const EdgeInsets.fromLTRB(Gap.md, 0, Gap.md, Gap.md),
      expandedAlignment: Alignment.centerLeft,
      children: <Widget>[
        Wrap(
          spacing: Gap.xs,
          runSpacing: Gap.xs,
          children: <Widget>[
            for (final String district in province.districts)
              Chip(
                label: Text(district),
                visualDensity: VisualDensity.compact,
                backgroundColor: matches.contains(district)
                    ? scheme.secondaryContainer
                    : null,
              ),
          ],
        ),
      ],
    );
  }
}
