import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visa_run_test/glass_calendar.dart';
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

  testWidgets('reference mural is packaged locally', (tester) async {
    await render(tester);
    final data = await rootBundle.load('assets/images/banksy_wall.webp');
    expect(data.lengthInBytes, greaterThan(30000));
    expect(data.lengthInBytes, lessThan(250000));
    expect(find.byKey(const Key('concrete-wall-image')), findsOneWidget);
  });

  testWidgets('first visit only shows English/Russian language choices', (tester) async {
    await render(tester);
    expect(find.text('ENGLISH'), findsOneWidget);
    expect(find.text('РУССКИЙ'), findsOneWidget);
    expect(find.byKey(const Key('open-booking')), findsNothing);
    expect(find.byType(GlassBookingCalendar), findsNothing);
  });

  testWidgets('English reveals glass capsules but no calendar yet', (tester) async {
    await render(tester);
    await tester.tap(find.byKey(const Key('choose-en')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('open-booking')), findsOneWidget);
    expect(find.byKey(const Key('contact-whatsapp')), findsOneWidget);
    expect(find.byKey(const Key('contact-telegram')), findsOneWidget);
    expect(find.byType(GlassBookingCalendar), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('visa_run_language'), 'en');
  });

  testWidgets('booking capsule opens and close icon dismisses calendar', (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await render(tester);
    await tester.tap(find.byKey(const Key('open-booking')));
    await tester.pumpAndSettle();
    expect(find.byType(GlassBookingCalendar), findsOneWidget);
    expect(find.text('PICK A DATE'), findsOneWidget);
    await tester.tap(find.byKey(const Key('calendar-close')));
    await tester.pumpAndSettle();
    expect(find.byType(GlassBookingCalendar), findsNothing);
  });

  testWidgets('calendar date selection shows demo feedback and closes', (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await render(tester);
    await tester.tap(find.byKey(const Key('open-booking')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('calendar-next-month')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('calendar-day-15')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('calendar-book')));
    await tester.pump();
    expect(find.textContaining('booking is not connected'), findsOneWidget);
    expect(find.byType(GlassBookingCalendar), findsNothing);
  });

  testWidgets('language can change and persist across app recreation', (tester) async {
    await render(tester);
    await tester.tap(find.byKey(const Key('choose-ru')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-booking')));
    await tester.pumpAndSettle();
    expect(find.text('ВЫБЕРИ ДАТУ'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const VisaRunApp());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('open-booking')), findsOneWidget);
    expect(find.text('ENGLISH'), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('visa_run_language'), 'ru');
  });

  testWidgets('WhatsApp and Telegram remain honest demo controls', (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await render(tester);
    await tester.tap(find.byKey(const Key('contact-telegram')));
    await tester.pump();
    expect(find.textContaining('not configured yet'), findsOneWidget);
  });

  testWidgets('320px phone keeps mural and floating actions visible', (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await render(tester, width: 320, height: 640);
    expect(find.byKey(const Key('concrete-wall-image')), findsOneWidget);
    expect(find.byKey(const Key('open-booking')), findsOneWidget);
    expect(find.byKey(const Key('contact-whatsapp')), findsOneWidget);
    expect(find.byKey(const Key('contact-telegram')), findsOneWidget);
    expect(find.byType(GlassBookingCalendar), findsNothing);
    await tester.tap(find.byKey(const Key('open-booking')));
    await tester.pumpAndSettle();
    expect(find.byType(GlassBookingCalendar), findsOneWidget);
    await tester.tap(find.byKey(const Key('calendar-close')));
    await tester.pumpAndSettle();
    expect(find.byType(GlassBookingCalendar), findsNothing);
  });

  testWidgets('mural scrolls with controls on small phones', (tester) async {
    SharedPreferences.setMockInitialValues({'visa_run_language': 'en'});
    await render(tester, width: 320, height: 600);
    final mural = find.byKey(const Key('concrete-wall-image'));
    final before = tester.getTopLeft(mural).dy;
    await tester.drag(find.byType(SingleChildScrollView),
      const Offset(0, -100));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(mural).dy, lessThan(before));
  });
}
