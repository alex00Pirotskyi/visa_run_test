import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visa_run_test/main.dart';
import 'package:visa_run_test/graffiti_widgets.dart';
import 'package:visa_run_test/stencil_mural.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> render(
    WidgetTester tester, {
    double width = 1440,
    double height = 900,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const VisaRunApp());
    await tester.pumpAndSettle();
  }

  testWidgets('first visit shows only the wall language gate', (tester) async {
    await render(tester);
    expect(find.text('ENGLISH'), findsOneWidget);
    expect(find.text('РУССКИЙ'), findsOneWidget);
    expect(find.text('BORDER RUNS'), findsNothing);
    expect(find.byType(StencilMuralPainter), findsNothing);
    expect(find.byKey(const Key('concrete-wall')), findsOneWidget);
    expect(find.byKey(const Key('architectural-concrete-light')), findsOneWidget);
  });

  testWidgets('choosing English shows a desktop mural and saves it',
      (tester) async {
    await render(tester);
    await tester.tap(find.byKey(const Key('choose-en')));
    await tester.pumpAndSettle();

    expect(find.text('BORDER RUNS'), findsWidgets);
    expect(find.text('HOW IT WORKS'), findsWidgets);
    expect(find.byType(GraffitiButton), findsWidgets);
    expect(find.byType(GraffitiTextField), findsOneWidget);
    expect(find.byWidgetPredicate((widget) =>
        widget is CustomPaint && widget.painter is StencilMuralPainter),
        findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('visa_run_language'), 'en');
  });

  testWidgets('Russian is restored on phone and can switch to English',
      (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'ru'});
    await render(tester, width: 390, height: 650);
    expect(find.text('РУССКИЙ'), findsNothing);
    expect(find.text('ВИЗАРАНЫ'), findsOneWidget);
    expect(find.text('КАК ЭТО РАБОТАЕТ'), findsOneWidget);

    await tester.tap(find.byKey(const Key('switch-en')));
    await tester.pumpAndSettle();
    expect(find.text('BORDER RUNS'), findsOneWidget);
    expect(find.text('ВИЗАРАНЫ'), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('visa_run_language'), 'en');
  });

  testWidgets('preference survives rebuilding the app', (tester) async {
    await render(tester);
    await tester.tap(find.byKey(const Key('choose-ru')));
    await tester.pumpAndSettle();
    expect(find.text('ВИЗАРАНЫ'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const VisaRunApp());
    await tester.pumpAndSettle();

    expect(find.text('ВИЗАРАНЫ'), findsWidgets);
    expect(find.text('ENGLISH'), findsNothing);
  });

  testWidgets('graffiti text field is editable but no submission happens',
      (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await render(tester, width: 390, height: 680);
    await tester.ensureVisible(find.byKey(const Key('graffiti-message-field')));
    await tester.enterText(find.byKey(const Key('graffiti-message-field')),
        'Border run in December');
    await tester.pump();

    expect(find.text('Border run in December'), findsOneWidget);
    expect(find.text('DESIGN PREVIEW. NO MESSAGES ARE SENT.'), findsOneWidget);
  });

  testWidgets('concrete and sunbeams scroll with the content on small phones',
      (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await render(tester, width: 320, height: 620);
    final wall = find.byKey(const Key('concrete-wall'));
    final light = find.byKey(const Key('architectural-concrete-light'));

    expect(find.ancestor(of: wall,
        matching: find.byType(SingleChildScrollView)), findsOneWidget);
    final wallY = tester.getTopLeft(wall).dy;
    final lightY = tester.getTopLeft(light).dy;
    await tester.drag(find.byType(SingleChildScrollView),
        const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(wall).dy, lessThan(wallY));
    expect(tester.getTopLeft(light).dy, lessThan(lightY));
  });
}
