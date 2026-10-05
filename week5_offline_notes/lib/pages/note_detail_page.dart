import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/note_providers.dart';
import '../widgets/note_form_dialog.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.noteId});

  final int noteId;

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final note = await ref.read(noteByIdProvider(noteId).future);
    if (note == null || !context.mounted) return;

    final result = await showDialog<({String title, String content})>(
      context: context,
      builder: (_) => NoteFormDialog(initial: note),
    );
    if (result == null) return;

    await ref.read(noteActionsProvider).update(
      note.copyWith(title: result.title, content: result.content),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteByIdProvider(noteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail catatan'),
        actions: [
          IconButton(
            tooltip: 'Ubah',
            icon: const Icon(Icons.edit),
            onPressed: () => _edit(context, ref),
          ),
        ],
      ),
      body: noteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Gagal memuat:\n$error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(noteByIdProvider(noteId)),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (note) {
          if (note == null) {
            return const Center(child: Text('Catatan tidak ditemukan.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(note.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Diperbarui: ${note.updatedAt.toIso8601String()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (note.dirty) ...[
                  const SizedBox(height: 8),
                  const Chip(label: Text('belum tersinkron')),
                ],
                const Divider(height: 32),
                Text(note.content),
              ],
            ),
          );
        },
      ),
    );
  }
}
