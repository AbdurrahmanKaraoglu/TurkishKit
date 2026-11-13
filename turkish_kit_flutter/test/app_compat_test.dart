// TurkishMoneyField must work in both kinds of apps that exist after
// Flutter 3.50: classic apps built with package:flutter/material.dart and
// apps built with package:material_ui. The two packages define separate
// Material, Theme and MaterialLocalizations classes.
import 'package:flutter/material.dart' as fm;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as mu;
import 'package:turkish_kit_flutter/turkish_kit_flutter.dart';

void main() {
  testWidgets('classic flutter/material app keeps its theme', (
    WidgetTester tester,
  ) async {
    final TurkishMoneyController controller = TurkishMoneyController();
    const fm.Color brand = fm.Color(0xFF1F3A5F);
    await tester.pumpWidget(
      fm.MaterialApp(
        theme: fm.ThemeData(primaryColor: brand),
        home: fm.Scaffold(body: TurkishMoneyField(controller: controller)),
      ),
    );
    await tester.enterText(find.byType(fm.TextField), '1234,5');
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(controller.text, '1.234,5 ₺');

    final BuildContext fieldContext = tester.element(find.byType(fm.TextField));
    expect(fm.Theme.of(fieldContext).primaryColor, brand);
    // The app's own Material is used; the field adds no Material of its own.
    expect(
      find.descendant(
        of: find.byType(TurkishMoneyField),
        matching: find.byType(fm.Material),
      ),
      findsNothing,
    );
  });

  testWidgets('material_ui app', (WidgetTester tester) async {
    final TurkishMoneyController controller = TurkishMoneyController();
    await tester.pumpWidget(
      mu.MaterialApp(
        home: mu.Scaffold(body: TurkishMoneyField(controller: controller)),
      ),
    );
    await tester.enterText(find.byType(fm.TextField), '1234,5');
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(controller.text, '1.234,5 ₺');
  });

  testWidgets('without any Material app around it', (
    WidgetTester tester,
  ) async {
    final TurkishMoneyController controller = TurkishMoneyController();
    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFF000000),
        pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
            PageRouteBuilder<T>(
              settings: settings,
              pageBuilder: (BuildContext context, _, _) => builder(context),
            ),
        home: TurkishMoneyField(controller: controller),
      ),
    );
    await tester.enterText(find.byType(fm.TextField), '99');
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(controller.text, '99 ₺');
  });
}
