import 'package:flutter_test/flutter_test.dart';

import 'package:hamilton_car_service/main.dart';

void main() {
  testWidgets('first splash then Get Started leads to phone registration',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HamiltonCarServiceApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Get Started'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('What Is Your Mobile Number?'), findsOneWidget);
  });
}
