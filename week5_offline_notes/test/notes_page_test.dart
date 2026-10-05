import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/pages/notes_page.dart';
import 'package:week5_offline_notes/providers/note_providers.dart';

void main() {
  testWidgets('NotesPage menampilkan empty state tanpa menyentuh SQLite', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const NotesPage()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notesProvider.overrideWith((ref) async => <Note>[]),
          dirtyCountProvider.overrideWith((ref) async => 0),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Belum ada catatan. Tekan + untuk menambah.'),
      findsOneWidget,
    );
  });
}
