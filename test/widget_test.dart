import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visa_run_test/main.dart';

void main() {
  testWidgets('landing has the main stencil headline and demo actions', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const VisaRunApp());
    await tester.pumpAndSettle();

    expect(find.text('VISA RUN'), findsWidgets);
    expect(find.text('BORDER RUNS'), findsOneWidget);
    expect(find.text('HOW IT WORKS'), findsOneWidget);
    expect(find.text('CONTACT US'), findsOneWidget);
    expect(find.byKey(const Key('concrete-wall')), findsOneWidget);
    expect(find.byKey(const Key('architectural-concrete-light')), findsOneWidget);
  });

  testWidgets('the concrete moves with the scrolled graffiti content', (tester) async {
    tester.view.physicalSize = const Size(390, 650);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const VisaRunApp());
    await tester.pumpAndSettle();

    final wall = find.byKey(const Key('concrete-wall'));
    final sunlight = find.byKey(const Key('architectural-concrete-light'));
    expect(
      find.ancestor(of: wall, matching: find.byType(SingleChildScrollView)),
      findsOneWidget,
    );

    final startY = tester.getTopLeft(wall).dy;
    final lightStartY = tester.getTopLeft(sunlight).dy;
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -220));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(wall).dy, lessThan(startY));
    expect(tester.getTopLeft(sunlight).dy, lessThan(lightStartY));
  });
}
