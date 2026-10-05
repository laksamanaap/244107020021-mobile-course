import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/prefs.dart';

final prefsRepositoryProvider = Provider<PrefsRepository>((ref) {
  throw UnimplementedError(
    'prefsRepositoryProvider harus di-override di main.dart',
  );
});

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return ref.watch(prefsRepositoryProvider).getDarkMode();
  }

  /// Optimistic update: UI berubah dulu, rollback jika tulis gagal.
  Future<void> toggle() async {
    final previous = state.value ?? false;
    final next = !previous;
    state = AsyncData(next);
    try {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

/// Membaca waktu terakhir dibuka (nilai lama), lalu menimpa dengan sekarang.
final lastOpenedProvider = FutureProvider<String?>((ref) async {
  final prefs = ref.watch(prefsRepositoryProvider);
  final previous = prefs.getLastOpened();
  await prefs.setLastOpened(DateTime.now().toIso8601String());
  return previous;
});
