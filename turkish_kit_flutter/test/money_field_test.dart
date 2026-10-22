import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkish_kit_flutter/turkish_kit_flutter.dart';

Widget app(Widget child) => MaterialApp(
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

/// Sends [input] as the keyboard would: replacing the current selection.
Future<void> typeKeys(
  WidgetTester tester,
  TextEditingController c,
  String keys,
) async {
  for (final String key in keys.split('')) {
    final TextSelection s = c.selection;
    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: c.text.replaceRange(s.start, s.end, key),
        selection: TextSelection.collapsed(offset: s.start + 1),
      ),
    );
    await tester.pump();
  }
}

Future<void> backspace(WidgetTester tester, TextEditingController c) async {
  final TextSelection s = c.selection;
  final int start = s.isCollapsed ? s.start - 1 : s.start;
  tester.testTextInput.updateEditingValue(
    TextEditingValue(
      text: c.text.replaceRange(start, s.end, ''),
      selection: TextSelection.collapsed(offset: start),
    ),
  );
  await tester.pump();
}

String marked(TextEditingController c) =>
    c.text.replaceRange(c.selection.baseOffset, c.selection.baseOffset, '|');

void main() {
  testWidgets('types, regroups and reports the amount', (
    WidgetTester tester,
  ) async {
    final TurkishMoneyController controller = TurkishMoneyController();
    final List<TurkishMoney?> changes = <TurkishMoney?>[];
    await tester.pumpWidget(
      app(TurkishMoneyField(controller: controller, onChanged: changes.add)),
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();

    await typeKeys(tester, controller, '1234.5');
    expect(marked(controller), '1.234,5| ₺');
    expect(controller.kurus, 123450);
    expect(changes.last, TurkishMoney.fromKurus(123450));

    // Move the cursor into the middle and type there.
    controller.selection = const TextSelection.collapsed(offset: 3);
    await typeKeys(tester, controller, '9');
    expect(marked(controller), '12.9|34,5 ₺');

    // Backspace right after a thousands separator.
    controller.selection = const TextSelection.collapsed(offset: 3);
    await backspace(tester, controller);
    expect(marked(controller), '1|.934,5 ₺');
  });

  testWidgets('uses the numeric keyboard', (WidgetTester tester) async {
    await tester.pumpWidget(app(const TurkishMoneyField()));
    final TextField field = tester.widget<TextField>(find.byType(TextField));
    expect(
      field.keyboardType,
      const TextInputType.numberWithOptions(decimal: true),
    );
    await tester.pumpWidget(
      app(
        const TurkishMoneyField(
          mask: TurkishMoneyInputMask(allowNegative: true, fractionDigits: 0),
        ),
      ),
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).keyboardType,
      const TextInputType.numberWithOptions(signed: true),
    );
  });

  testWidgets('pads the decimals when focus leaves', (
    WidgetTester tester,
  ) async {
    final TurkishMoneyController controller = TurkishMoneyController();
    TurkishMoney? last;
    await tester.pumpWidget(
      app(
        Column(
          children: <Widget>[
            TurkishMoneyField(
              controller: controller,
              onChanged: (TurkishMoney? m) => last = m,
            ),
            const TextField(key: Key('other')),
          ],
        ),
      ),
    );
    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    await typeKeys(tester, controller, '12,5');
    expect(controller.text, '12,5 ₺');
    await tester.tap(find.byKey(const Key('other')));
    await tester.pump();
    expect(controller.text, '12,50 ₺');
    expect(last, TurkishMoney.fromKurus(1250));
  });

  testWidgets('initial value, required and custom validation', (
    WidgetTester tester,
  ) async {
    final GlobalKey<FormState> form = GlobalKey<FormState>();
    await tester.pumpWidget(
      app(
        Form(
          key: form,
          child: TurkishMoneyField(
            initialValue: TurkishMoney.lira(5),
            required: true,
            validator: (TurkishMoney? m) =>
                m != null && m < TurkishMoney.lira(10) ? 'En az 10 ₺' : null,
          ),
        ),
      ),
    );
    expect(find.text('5,00 ₺'), findsOneWidget);
    expect(form.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('En az 10 ₺'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    expect(form.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text(TurkishValidationMessages.tr.required), findsOneWidget);

    await tester.enterText(find.byType(TextField), '1250');
    expect(form.currentState!.validate(), isTrue);
  });

  testWidgets('max value rejects the keystroke', (WidgetTester tester) async {
    final TurkishMoneyController controller = TurkishMoneyController(
      mask: TurkishMoneyInputMask(maxValue: TurkishMoney.lira(100)),
    );
    await tester.pumpWidget(app(TurkishMoneyField(controller: controller)));
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await typeKeys(tester, controller, '1000');
    expect(marked(controller), '100|');
  });

  testWidgets('phone mask formatter in a TextFormField', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller = TextEditingController();
    await tester.pumpWidget(
      app(
        TextFormField(
          controller: controller,
          inputFormatters: <TextInputFormatter>[
            TurkishInputMaskFormatter(TurkishInputMask.phone),
          ],
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), '+90 532 123 45 67');
    expect(controller.text, '0532 123 45 67');
  });
}
