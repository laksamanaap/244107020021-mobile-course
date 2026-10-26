import 'package:flutter_test/flutter_test.dart';

import 'package:week6_authentication_security_fcm/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyAppWeek6());
    await tester.pump();

    expect(find.text('Beranda'), findsWidgets);
  });
}
