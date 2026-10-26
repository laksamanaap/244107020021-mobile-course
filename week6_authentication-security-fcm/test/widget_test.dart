import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:week6_authentication_security_fcm/data/token_store.dart';
import 'package:week6_authentication_security_fcm/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('App menampilkan halaman login', (WidgetTester tester) async {
    final store = MemoryTokenStore();
    await tester.pumpWidget(MyAppWeek6(tokenStore: store));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('Campus LMS'), findsWidgets);
  });

  testWidgets('Login valid membuka LMS dan menyimpan token simulasi', (
    WidgetTester tester,
  ) async {
    final store = MemoryTokenStore();
    await tester.pumpWidget(MyAppWeek6(tokenStore: store));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.enterText(find.byType(TextFormField).last, '123456');
    await tester.tap(find.text('Masuk'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(store.access, contains('mock-access-for-'));
    expect(store.refresh, contains('mock-refresh-for-'));
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Masuk'), findsNothing);
  });

  testWidgets('Login menolak kata sandi terlalu pendek', (
    WidgetTester tester,
  ) async {
    final store = MemoryTokenStore();
    await tester.pumpWidget(MyAppWeek6(tokenStore: store));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.enterText(find.byType(TextFormField).last, '123');
    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.text('Kata sandi minimal 6 karakter'), findsOneWidget);
    expect(store.access, isNull);
    expect(find.text('Masuk'), findsWidgets);
  });
}
