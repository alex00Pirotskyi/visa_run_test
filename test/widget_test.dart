import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visa_run_test/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('first visit shows only language selection painted on the wall', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const VisaRunApp());
    await tester.pumpAndSettle();

    expect(find.text('ENGLISH'), findsOneWidget);
    expect(find.text('РУССКИЙ'), findsOneWidget);
    expect(find.text('BORDER RUNS'), findsNothing);
    expect(find.text('ВИЗАРАНЫ'), findsNothing);
    expect(find.byKey(const Key('concrete-wall')), findsOneWidget);
    expect(find.byKey(const Key('architectural-concrete-light')), findsOneWidget);
  });

  testWidgets('choosing English opens the site and saves the preference', (tester) async {
    await tester.pumpWidget(const VisaRunApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('choose-en')));
    await tester.pumpAndSettle();

    expect(find.text('BORDER RUNS'), findsOneWidget);
    expect(find.text('HOW IT WORKS'), findsOneWidget);
    expect(find.text('CONTACT US'), findsOneWidget);
    expect(find.text('РУССКИЙ'), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('visa_run_language'), 'en');
  });

  testWidgets('saved Russian opens directly and can switch to English', (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'ru'});
    tester.view.physicalSize = const Size(390, 650);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const VisaRunApp());
    await tester.pumpAndSettle();

    expect(find.text('РУССКИЙ'), findsNothing);
    expect(find.text('ВИЗАРАНЫ'), findsOneWidget);
    expect(find.text('КАК ЭТО РАБОТАЕТ'), findsOneWidget);
    expect(find.text('BORDER RUNS'), findsNothing);

    await tester.tap(find.byKey(const Key('switch-en')));
    await tester.pumpAndSettle();
    expect(find.text('BORDER RUNS'), findsOneWidget);
    expect(find.text('ВИЗАРАНЫ'), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('visa_run_language'), 'en');
  });

  testWidgets('selected preference survives recreating the app', (tester) async {
    await tester.pumpWidget(const VisaRunApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('choose-ru')));
    await tester.pumpAndSettle();
    expect(find.text('ВИЗАРАНЫ'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const VisaRunApp());
    await tester.pumpAndSettle();

    expect(find.text('ВИЗАРАНЫ'), findsOneWidget);
    expect(find.text('ENGLISH'), findsNothing);
  });

  testWidgets('concrete and sunlight scroll together after language selection', (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    tester.view.physicalSize = const Size(390, 650);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const VisaRunApp());
    await tester.pumpAndSettle();

    final wall = find.byKey(const Key('concrete-wall'));
    final sunlight = find.byKey(const Key('architectural-concrete-light'));
    expect(find.ancestor(of: wall, matching: find.byType(SingleChildScrollView)), findsOneWidget);

    final startY = tester.getTopLeft(wall).dy;
    final lightStartY = tester.getTopLeft(sunlight).dy;
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -220));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(wall).dy, lessThan(startY));
    expect(tester.getTopLeft(sunlight).dy, lessThan(lightStartY));
  });
}
