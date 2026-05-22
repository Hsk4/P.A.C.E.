// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:personal_schedular/main.dart';

void main() {
  testWidgets('App navigation smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PersonalSchedulerApp());
    await tester.pumpAndSettle();

    // Starts on dashboard.
    expect(find.text('Performance Overview'), findsOneWidget);

    // Navigate to Alarms tab.
    await tester.tap(find.text('Alarms'));
    await tester.pumpAndSettle();
    expect(find.text('No alarms set'), findsOneWidget);

    // Navigate to Tasks tab.
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.text('No tasks yet'), findsOneWidget);
  });
}
