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
  });
}
