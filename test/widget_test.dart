import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visa_run_test/graffiti_calendar.dart';
import 'package:visa_run_test/graffiti_widgets.dart';
import 'package:visa_run_test/main.dart';
import 'package:visa_run_test/transparent_stencil_button.dart';

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

  testWidgets('static image asset is bundled as the actual wall background',
      (tester) async {
    await render(tester);
    final data = await rootBundle.load('assets/images/banksy_wall.webp');
    expect(data.lengthInBytes, greaterThan(2000));
    expect(data.lengthInBytes, lessThan(100000));
    expect(find.byKey(const Key('concrete-wall-image')), findsOneWidget);
  });

  testWidgets('first visit shows only two language options on image',
      (tester) async {
    await render(tester);
    expect(find.text('ENGLISH'), findsOneWidget);
    expect(find.text('РУССКИЙ'), findsOneWidget);
    expect(find.byType(GraffitiBookingCalendar), findsNothing);
    expect(find.byKey(const Key('contact-whatsapp')), findsNothing);
    expect(find.byType(GraffitiTextField), findsNothing);
  });

  testWidgets('English opens a transparent calendar and contact buttons',
      (tester) async {
    await render(tester);
    await tester.tap(find.byKey(const Key('choose-en')));
    await tester.pumpAndSettle();
    expect(find.byType(GraffitiBookingCalendar), findsOneWidget);
    expect(find.byType(TransparentStencilButton), findsNWidgets(3));
    expect(find.byKey(const Key('contact-whatsapp')), findsOneWidget);
    expect(find.byKey(const Key('contact-telegram')), findsOneWidget);
    expect(find.text('PICK YOUR RUN DATE'), findsOneWidget);
    expect(find.byType(GraffitiTextField), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('visa_run_language'), 'en');
  });

  testWidgets('selecting a date shows honest demo feedback', (tester) async {
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

  testWidgets('Russian locale saved and switchable on mobile', (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'ru'});
    await render(tester, width: 390, height: 700);
    expect(find.text('РУССКИЙ'), findsNothing);
    expect(find.text('ВЫБЕРИ ДАТУ ПОЕЗДКИ'), findsOneWidget);
    await tester.tap(find.byKey(const Key('switch-en')));
    await tester.pumpAndSettle();
    expect(find.text('PICK YOUR RUN DATE'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('visa_run_language'), 'en');
  });

  testWidgets('selection survives recreating the Flutter app', (tester) async {
    await render(tester);
    await tester.tap(find.byKey(const Key('choose-ru')));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const VisaRunApp());
    await tester.pumpAndSettle();
    expect(find.text('ВЫБЕРИ ДАТУ ПОЕЗДКИ'), findsOneWidget);
    expect(find.text('ENGLISH'), findsNothing);
  });

  testWidgets('contact buttons are transparent demo controls', (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await render(tester);
    final telegram = find.byKey(const Key('contact-telegram'));
    expect(telegram, findsOneWidget);
    await tester.tap(telegram);
    await tester.pump();
    expect(find.textContaining('not configured yet'), findsOneWidget);
  });

  testWidgets('320px phone renders full art without horizontal overflow',
      (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await render(tester, width: 320, height: 640);
    expect(find.byKey(const Key('concrete-wall-image')), findsOneWidget);
    expect(find.byKey(const Key('contact-whatsapp')), findsOneWidget);
    expect(find.byKey(const Key('contact-telegram')), findsOneWidget);
    expect(find.byType(GraffitiBookingCalendar), findsOneWidget);

    final image = find.byKey(const Key('concrete-wall-image'));
    final initialY = tester.getTopLeft(image).dy;
    await tester.drag(find.byType(SingleChildScrollView),
        const Offset(0, -240));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(image).dy, lessThan(initialY));
  });
}
