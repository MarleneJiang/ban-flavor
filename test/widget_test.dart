// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:ban_flavor_detector/main.dart';

void main() {
  testWidgets('Ban Flavor Detector smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DailyPhotoApp());

    // Verify that the app starts with gallery screen
    expect(find.text('班味档案'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);

    // Tap the settings tab
    await tester.tap(find.text('设置'));
    await tester.pump();

    // Verify that settings screen is shown
    expect(find.text('设置'), findsWidgets);
  });
}
