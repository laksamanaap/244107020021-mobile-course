import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/local/note.dart';
import '../data/sync.dart';
import '../providers/note_providers.dart';
import '../widgets/note_form_dialog.dart';
import '../widgets/note_tile.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    Note? note,
  }) async {
    final result = await showDialog<({String title, String content})>(
      context: context,
      builder: (_) => NoteFormDialog(initial: note),
    );
    if (result == null) return;

    final actions = ref.read(noteActionsProvider);
    if (note == null) {
      await actions.add(title: result.title, content: result.content);
    } else {
      await actions.update(
        note.copyWith(title: result.title, content: result.content),
      );
    }
  }

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(noteActionsProvider).sync(
            latency: kIsWeb ? const Duration(milliseconds: 300) : const Duration(seconds: 1),
          );
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Sinkronisasi berhasil'),
          duration: Duration(seconds: 6),
        ),
      );
    } on OfflineException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('$e'), duration: const Duration(seconds: 6)),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal sync: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final dirtyAsync = ref.watch(dirtyCountProvider);
    final dirtyCount = dirtyAsync.value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          if (dirtyCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Badge(
                  label: Text('$dirtyCount'),
                  child: Icon(
                    Icons.cloud_upload_outlined,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.cloud_done, color: Colors.green.shade600),
            ),
          IconButton(
            tooltip: 'Posts',
            icon: const Icon(Icons.article_outlined),
            onPressed: () => context.push('/posts'),
          ),
          IconButton(
            tooltip: 'Sinkronkan',
            icon: const Icon(Icons.sync),
            onPressed: () => _sync(context, ref),
          ),
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Gagal memuat catatan:\n$error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(notesProvider),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(
              child: Text('Belum ada catatan. Tekan + untuk menambah.'),
            );
          }
          return ListView.separated(
            itemCount: notes.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final note = notes[index];
              return NoteTile(
                note: note,
                onTap: () => context.push('/note/${note.id}'),
                onDelete: () => ref.read(noteActionsProvider).delete(note.id!),
              );
            },
          );
        },
      ),
    );
  }
}
