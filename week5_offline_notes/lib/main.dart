import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_router.dart';
import 'data/prefs.dart';
import 'data/repositories/memory_note_repository.dart';
import 'data/repositories/memory_post_repository.dart';
import 'providers/note_providers.dart';
import 'providers/post_providers.dart';
import 'providers/prefs_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Agar browser automation bisa membaca tombol (screenshot praktikum).
    SemanticsBinding.instance.ensureSemantics();
  }
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        prefsRepositoryProvider.overrideWithValue(PrefsRepository(prefs)),
        if (kIsWeb) ...[
          // sqflite tidak support web — pakai memori agar bisa demo/screenshot.
          noteRepositoryProvider.overrideWithValue(
            MemoryNoteRepository(seedDemo: true),
          ),
          postRepositoryProvider.overrideWithValue(MemoryPostRepository()),
        ],
      ],
      child: const OfflineNotesApp(),
    ),
  );
}

class OfflineNotesApp extends ConsumerWidget {
  const OfflineNotesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);

    return MaterialApp.router(
      title: 'Week 5 Offline Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: (darkMode.value ?? false) ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
