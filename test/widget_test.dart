import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:visa_run_test/bus_mural.dart';
import 'package:visa_run_test/concrete_scene.dart';
import 'package:visa_run_test/glass_calendar.dart';
import 'package:visa_run_test/liquid_glass.dart';
import 'package:visa_run_test/main.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> openApp(
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

  testWidgets('matte concrete covers the full height with only faint seams',
      (tester) async {
    const width = 320;
    const height = 800;
    final recorder = ui.PictureRecorder();
    const painter = ConcreteScenePainter(null);
    painter.paint(ui.Canvas(recorder), const Size(320, 800));
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final raw = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    expect(raw, isNotNull);
    final pixels = raw!.buffer.asUint8List();
    int redAt(int x, int y) => pixels[(y * width + x) * 4];

    // It is the same pale surface all the way down, with no dark floor.
    expect((redAt(18, 12) - redAt(18, 780)).abs(), lessThan(14));

    // Delicate formwork joints remain visible, but don't dominate.
    final seamX = (width * ConcreteScenePainter.verticalSeamFraction).round();
    final seamY = (height * ConcreteScenePainter.horizontalSeamFraction).round();
    expect(redAt(seamX, 120), lessThan(redAt(seamX - 5, 120)));
    expect(redAt(40, seamY), lessThan(redAt(40, seamY - 5)));
    expect(redAt(seamX - 5, 120) - redAt(seamX, 120), lessThan(18));
    expect(redAt(40, seamY - 5) - redAt(40, seamY), lessThan(18));

    image.dispose();
    picture.dispose();
  });

  testWidgets('first visitor sees only language choice on concrete',
      (tester) async {
    await openApp(tester);
    expect(find.text('ENGLISH'), findsOneWidget);
    expect(find.text('РУССКИЙ'), findsOneWidget);
    expect(find.byKey(const Key('concrete-wall')), findsOneWidget);
    expect(find.byType(GlassBookingCalendar), findsNothing);
    expect(find.byKey(const Key('contact-whatsapp')), findsNothing);
    expect(find.byKey(const Key('open-booking')), findsNothing);
  });

  testWidgets('English directly reveals the open glass calendar and vector bus',
      (tester) async {
    await openApp(tester);
    await tester.tap(find.byKey(const Key('choose-en')));
    await tester.pumpAndSettle();

    expect(find.byType(GlassBookingCalendar), findsOneWidget);
    expect(find.byKey(const Key('booking-calendar')), findsOneWidget);
    expect(find.byKey(const Key('vector-bus-mural')), findsOneWidget);
    expect(find.byKey(const Key('contact-whatsapp')), findsOneWidget);
    expect(find.byKey(const Key('contact-telegram')), findsOneWidget);
    expect(find.byKey(const Key('open-booking')), findsNothing);
    expect(find.byType(LiquidGlass), findsWidgets);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('visa_run_language'), 'en');
  });

  testWidgets('the calendar is already usable without an open-booking tap',
      (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await openApp(tester);
    expect(find.byType(GlassBookingCalendar), findsOneWidget);
    await tester.tap(find.byKey(const Key('calendar-next-month')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('calendar-day-15')));
    await tester.pumpAndSettle();

    expect(find.textContaining('15,'), findsOneWidget);
    await tester.tap(find.byKey(const Key('calendar-book')));
    await tester.pump();
    expect(find.textContaining('booking is not connected yet'),
        findsOneWidget);
    expect(find.byType(GlassBookingCalendar), findsOneWidget);
  });

  testWidgets('Continue without a date asks user to select one',
      (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await openApp(tester);
    await tester.tap(find.byKey(const Key('calendar-book')));
    await tester.pump();
    expect(find.textContaining('choose your travel date'), findsOneWidget);
  });

  testWidgets('Russian preference restores and switching works',
      (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'ru'});
    await openApp(tester);
    expect(find.text('ENGLISH'), findsNothing);
    expect(find.byType(GlassBookingCalendar), findsOneWidget);
    await tester.tap(find.byKey(const Key('switch-en')));
    await tester.pumpAndSettle();
    expect(find.text('Continue'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('visa_run_language'), 'en');
  });

  testWidgets('selected language persists after app recreation',
      (tester) async {
    await openApp(tester);
    await tester.tap(find.byKey(const Key('choose-ru')));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const VisaRunApp());
    await tester.pumpAndSettle();

    expect(find.byType(GlassBookingCalendar), findsOneWidget);
    expect(find.text('ДАЛЕЕ'), findsOneWidget);
    expect(find.text('ENGLISH'), findsNothing);
  });

  testWidgets('WhatsApp and Telegram remain explicitly demo-only',
      (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await openApp(tester);
    await tester.tap(find.byKey(const Key('contact-telegram')));
    await tester.pump();
    expect(find.textContaining('not configured yet'), findsOneWidget);
  });

  testWidgets('vector bus contains the traced line art and paints as vector',
      (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await openApp(tester);
    expect(find.byWidgetPredicate((w) =>
        w is CustomPaint && w.painter is BusMuralPainter), findsOneWidget);
  });

  testWidgets('320px phone has visible calendar, contacts and bus without overflow',
      (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await openApp(tester, width: 320, height: 640);
    expect(find.byType(GlassBookingCalendar), findsOneWidget);
    expect(find.byKey(const Key('contact-whatsapp')), findsOneWidget);
    expect(find.byKey(const Key('contact-telegram')), findsOneWidget);
    expect(find.byKey(const Key('vector-bus-mural')), findsOneWidget);
    expect(find.byKey(const Key('open-booking')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tablet layout flows without content overlap',
      (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'ru'});
    await openApp(tester, width: 820, height: 650);
    expect(find.byType(GlassBookingCalendar), findsOneWidget);
    expect(find.byKey(const Key('vector-bus-mural')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bus is visibly layered behind glass calendar on desktop',
      (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await openApp(tester, width: 1440, height: 900);

    final bus = tester.getRect(find.byKey(const Key('vector-bus-mural')));
    final calendar = tester.getRect(find.byKey(const Key('booking-calendar')));
    expect(bus.overlaps(calendar), isTrue);

    final glass = tester.widget<LiquidGlass>(find.descendant(
      of: find.byKey(const Key('booking-calendar')),
      matching: find.byType(LiquidGlass),
    ));
    expect(glass.strongTopAlpha, closeTo(.78, .001));
    expect(glass.strongBottomAlpha, closeTo(.69, .001));
    expect(glass.blur, lessThan(6));
  });

  testWidgets('bus also shows behind calendar on a 320px phone',
      (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await openApp(tester, width: 320, height: 640);
    final bus = tester.getRect(find.byKey(const Key('vector-bus-mural')));
    final calendar = tester.getRect(find.byKey(const Key('booking-calendar')));
    expect(bus.overlaps(calendar), isTrue);
    expect(bus.left, greaterThanOrEqualTo(0));
    expect(bus.right, lessThanOrEqualTo(320));
    expect(bus.width, closeTo(296, .01));
    expect(find.byKey(const Key('open-booking')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bus scales proportionally and fits a 375px phone',
      (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await openApp(tester, width: 375, height: 667);
    final bus = tester.getRect(find.byKey(const Key('vector-bus-mural')));
    final calendar = tester.getRect(find.byKey(const Key('booking-calendar')));
    expect(bus.left, greaterThanOrEqualTo(0));
    expect(bus.right, lessThanOrEqualTo(375));
    expect(bus.width, closeTo(351, .01));
    expect(bus.overlaps(calendar), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('contact glass shares blur without touching calendar',
      (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await openApp(tester, width: 1440, height: 900);
    final first = find.byKey(const Key('contact-whatsapp'));
    final second = find.byKey(const Key('contact-telegram'));
    expect(find.ancestor(of: first, matching: find.byType(BackdropGroup)),
        findsOneWidget);
    expect(find.ancestor(of: second, matching: find.byType(BackdropGroup)),
        findsOneWidget);

    final firstGlass = tester.widget<LiquidGlass>(find.descendant(
      of: first, matching: find.byType(LiquidGlass)));
    final secondGlass = tester.widget<LiquidGlass>(find.descendant(
      of: second, matching: find.byType(LiquidGlass)));
    final calendarGlass = tester.widget<LiquidGlass>(find.descendant(
      of: find.byKey(const Key('booking-calendar')),
      matching: find.byType(LiquidGlass)));
    expect(firstGlass.groupedBackdrop, isTrue);
    expect(secondGlass.groupedBackdrop, isTrue);
    expect(calendarGlass.groupedBackdrop, isFalse);
    expect(firstGlass.blur, secondGlass.blur);
    expect(calendarGlass.strongTopAlpha, closeTo(.78, .001));
    expect(calendarGlass.strongBottomAlpha, closeTo(.69, .001));
  });

  testWidgets('mobile concrete, calendar and bus share scroll coordinates',
      (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await openApp(tester, width: 320, height: 600);
    final bus = find.byKey(const Key('vector-bus-mural'));
    final wall = find.byKey(const Key('concrete-wall'));
    final busY = tester.getTopLeft(bus).dy;
    final wallY = tester.getTopLeft(wall).dy;
    await tester.drag(find.byType(SingleChildScrollView),
      const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(bus).dy, lessThan(busY));
    expect(tester.getTopLeft(wall).dy, lessThan(wallY));
  });
}
