import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visa_run_test/balloon_mural.dart';
import 'package:visa_run_test/graffiti_calendar.dart';
import 'package:visa_run_test/graffiti_widgets.dart';
import 'package:visa_run_test/main.dart';

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

  testWidgets('first visit shows only language selection on the wall',
      (tester) async {
    await render(tester);
    expect(find.text('ENGLISH'), findsOneWidget);
    expect(find.text('РУССКИЙ'), findsOneWidget);
    expect(find.byType(GraffitiBookingCalendar), findsNothing);
    expect(find.byKey(const Key('contact-whatsapp')), findsNothing);
    expect(find.byKey(const Key('concrete-wall')), findsOneWidget);
    expect(find.byKey(const Key('concrete-surface-detail')), findsOneWidget);
  });

  testWidgets('English selection shows minimalist calendar and balloon mural',
      (tester) async {
    await render(tester);
    await tester.tap(find.byKey(const Key('choose-en')));
    await tester.pumpAndSettle();
    expect(find.byType(GraffitiBookingCalendar), findsOneWidget);
    expect(find.byKey(const Key('balloon-girl-art')), findsOneWidget);
    expect(find.byKey(const Key('contact-whatsapp')), findsOneWidget);
    expect(find.byKey(const Key('contact-telegram')), findsOneWidget);
    expect(find.text('PICK YOUR RUN DATE'), findsOneWidget);
    expect(find.byType(GraffitiTextField), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('visa_run_language'), 'en');
  });

  testWidgets('calendar can select a future day and demo booking gives feedback',
      (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await render(tester);
    await tester.tap(find.byKey(const Key('calendar-next-month')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('calendar-day-15')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('calendar-book')));
    await tester.pump();
    expect(find.textContaining('booking is not connected'), findsOneWidget);
  });

  testWidgets('Russian preference loads directly and switches back to English',
      (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'ru'});
    await render(tester, width: 390, height: 780);
    expect(find.text('РУССКИЙ'), findsNothing);
    expect(find.text('ВЫБЕРИ ДАТУ ПОЕЗДКИ'), findsOneWidget);
    await tester.tap(find.byKey(const Key('switch-en')));
    await tester.pumpAndSettle();
    expect(find.text('PICK YOUR RUN DATE'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('visa_run_language'), 'en');
  });

  testWidgets('a chosen language survives reopening the site',
      (tester) async {
    await render(tester);
    await tester.tap(find.byKey(const Key('choose-ru')));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const VisaRunApp());
    await tester.pumpAndSettle();
    expect(find.text('ВЫБЕРИ ДАТУ ПОЕЗДКИ'), findsOneWidget);
    expect(find.text('ENGLISH'), findsNothing);
  });

  testWidgets('contacts do not imply a working service', (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await render(tester);
    await tester.tap(find.byKey(const Key('contact-telegram')));
    await tester.pump();
    expect(find.textContaining('not configured yet'), findsOneWidget);
  });

  testWidgets('320px phone renders mural, calendar and both contact buttons',
      (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'ru'});
    await render(tester, width: 320, height: 640);
    expect(find.byKey(const Key('balloon-girl-art')), findsOneWidget);
    expect(find.byKey(const Key('contact-whatsapp')), findsOneWidget);
    expect(find.byKey(const Key('contact-telegram')), findsOneWidget);
    expect(find.byType(BalloonGirlPainter), findsNothing);
    expect(find.byType(GraffitiBookingCalendar), findsOneWidget);

    final wall = find.byKey(const Key('concrete-wall'));
    final details = find.byKey(const Key('concrete-surface-detail'));
    final startWallY = tester.getTopLeft(wall).dy;
    final startDetailsY = tester.getTopLeft(details).dy;
    await tester.drag(find.byType(SingleChildScrollView),
        const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(wall).dy, lessThan(startWallY));
    expect(tester.getTopLeft(details).dy, lessThan(startDetailsY));
  });
}
