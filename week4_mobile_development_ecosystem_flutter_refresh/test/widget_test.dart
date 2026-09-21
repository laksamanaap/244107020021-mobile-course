import 'package:flutter_test/flutter_test.dart';

import 'package:week4_mobile_development_ecosystem_flutter_refresh/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyAppWeek4());
    await tester.pump();

    expect(find.text('Home'), findsWidgets);
  });
}
