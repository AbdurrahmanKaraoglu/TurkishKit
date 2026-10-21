import 'package:flutter/material.dart';
import 'package:turkish_kit/turkish_kit.dart';

import 'app_strings.dart';
import 'app_theme.dart';
import 'widgets.dart';

class HolidaysPage extends StatefulWidget {
  const HolidaysPage({super.key});

  @override
  State<HolidaysPage> createState() => _HolidaysPageState();
}

class _HolidaysPageState extends State<HolidaysPage> {
  late int _year = _clampYear(DateTime.now().year);
  late DateTime _start = _clampDate(DateTime.now());
  int _days = 5;

  static int _clampYear(int year) => year.clamp(TurkishHolidays.firstYear, TurkishHolidays.lastYear);

  static DateTime _clampDate(DateTime date) {
    final DateTime first = DateTime(TurkishHolidays.firstYear);
    final DateTime last = DateTime(TurkishHolidays.lastYear, 11, 30);
    if (date.isBefore(first)) return first;
    if (date.isAfter(last)) return last;
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(TurkishHolidays.firstYear),
      lastDate: DateTime(TurkishHolidays.lastYear, 11, 30),
    );
    if (picked != null) setState(() => _start = picked);
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = AppStrings.of(context);
    final ThemeData theme = Theme.of(context);
    final List<TurkishHoliday> holidays = TurkishHolidays.forYear(_year);
    final DateTime result = TurkishHolidays.addBusinessDays(_start, _days);
    final bool startIsBusiness = TurkishHolidays.isBusinessDay(_start);

    return PageScaffold(
      title: strings.navHolidays,
      subtitle: strings.holidaysSubtitle,
      children: <Widget>[
        SectionCard(
          title: strings.businessDays,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(strings.startDate),
                subtitle: Text('${strings.date(_start)} · '
                    '${startIsBusiness ? strings.isBusinessDay : strings.notBusinessDay}'),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: _pickDate,
              ),
              Row(
                children: <Widget>[
                  Expanded(child: Text(strings.days, style: theme.textTheme.bodyLarge)),
                  IconButton.outlined(
                    onPressed: _days > -60 ? () => setState(() => _days--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text('$_days', textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
                  ),
                  IconButton.outlined(
                    onPressed: _days < 60 ? () => setState(() => _days++) : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: Gap.sm),
              ResultRow(label: strings.result, value: strings.date(result)),
            ],
          ),
        ),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DropdownButtonFormField<int>(
                initialValue: _year,
                decoration: InputDecoration(labelText: strings.year, prefixIcon: const Icon(Icons.calendar_month)),
                items: <DropdownMenuItem<int>>[
                  for (int y = TurkishHolidays.firstYear; y <= TurkishHolidays.lastYear; y++)
                    DropdownMenuItem<int>(value: y, child: Text('$y')),
                ],
                onChanged: (int? value) => setState(() => _year = value ?? _year),
              ),
              const SizedBox(height: Gap.sm),
              for (final TurkishHoliday holiday in holidays)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    holiday.kind.isReligious ? Icons.nightlight_outlined : Icons.flag_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(strings.holidayName(holiday)),
                  subtitle: Text(strings.date(holiday.date)),
                  trailing: holiday.isHalfDay
                      ? Chip(label: Text(strings.halfDay), visualDensity: VisualDensity.compact)
                      : null,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
