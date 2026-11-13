import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/app_strings.dart';
import 'src/app_theme.dart';
import 'src/holidays_page.dart';
import 'src/money_page.dart';
import 'src/provinces_page.dart';
import 'src/text_page.dart';
import 'src/validate_page.dart';

void main() {
  runApp(const TurkishKitExampleApp());
}

class TurkishKitExampleApp extends StatelessWidget {
  const TurkishKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: appLocale,
      builder: (BuildContext context, Locale? locale, _) => MaterialApp(
        title: 'Turkish Kit',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        // Null follows the device language (Turkish or English).
        locale: locale,
        supportedLocales: supportedLocales,
        localeListResolutionCallback: resolveLocale,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const HomeShell(),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = AppStrings.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const <Widget>[
          ValidatePage(),
          MoneyPage(),
          TextPage(),
          ProvincesPage(),
          HolidaysPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int index) => setState(() => _index = index),
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.verified_user_outlined),
            selectedIcon: const Icon(Icons.verified_user),
            label: strings.navValidate,
          ),
          NavigationDestination(
            icon: const Icon(Icons.payments_outlined),
            selectedIcon: const Icon(Icons.payments),
            label: strings.navMoney,
          ),
          NavigationDestination(
            icon: const Icon(Icons.text_fields_outlined),
            selectedIcon: const Icon(Icons.text_fields),
            label: strings.navText,
          ),
          NavigationDestination(
            icon: const Icon(Icons.location_city_outlined),
            selectedIcon: const Icon(Icons.location_city),
            label: strings.navProvinces,
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_outlined),
            selectedIcon: const Icon(Icons.event),
            label: strings.navHolidays,
          ),
        ],
      ),
    );
  }
}
