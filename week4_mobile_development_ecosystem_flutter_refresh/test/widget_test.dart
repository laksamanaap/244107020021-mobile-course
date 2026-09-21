import 'package:flutter_test/flutter_test.dart';

import 'package:week3_mobile_development_ecosystem_flutter_refresh/main.dart';

void main() {
  testWidgets('Music Playbox smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyAppWeek3());
    await tester.pumpAndSettle();

    expect(find.text('Music Playbox'), findsWidgets);
  });
}
