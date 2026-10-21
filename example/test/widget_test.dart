import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkish_kit_example/main.dart';
import 'package:turkish_kit_example/src/app_strings.dart';

void main() {
  testWidgets('every tab renders in Turkish and English', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    for (final String code in <String>['tr', 'en']) {
      appLocale.value = Locale(code);
      await tester.pumpWidget(const TurkishKitExampleApp());
      await tester.pumpAndSettle();
      for (final IconData icon in <IconData>[
        Icons.verified_user_outlined,
        Icons.payments_outlined,
        Icons.text_fields_outlined,
        Icons.location_city_outlined,
        Icons.event_outlined,
      ]) {
        final Finder tab = find.descendant(of: find.byType(NavigationBar), matching: find.byIcon(icon));
        if (tab.evaluate().isNotEmpty) await tester.tap(tab);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    }
    appLocale.value = null;
  });

  testWidgets('amount in words and phone mask', (WidgetTester tester) async {
    appLocale.value = const Locale('tr');
    await tester.pumpWidget(const TurkishKitExampleApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(3), '5321234567');
    await tester.pump();
    expect(find.text('0532 123 45 67'), findsOneWidget);

    await tester.tap(find.text('Tutar'));
    await tester.pumpAndSettle();
    expect(find.text('Bin İki Yüz Otuz Dört Türk Lirası Elli Kuruş'), findsOneWidget);
    appLocale.value = null;
  });
}
