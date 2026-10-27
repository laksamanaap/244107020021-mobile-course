import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_theme.dart';
import '../messaging/inbox_service.dart';
import '../routes.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppTheme.appBar(
        'Notifikasi',
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      body: AppTheme.page(
        safeTop: false,
        child: ValueListenableBuilder<List<CampusInboxItem>>(
          valueListenable: InboxService.instance.unread,
          builder: (context, items, _) {
            if (items.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Tidak ada pengumuman belum dibaca.\n'
                    'Kirim FCM type=list ke topik pengumuman-kampus.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.muted, height: 1.5),
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return Material(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.brand,
                      child: Icon(
                        Icons.campaign_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.text,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.body.isEmpty
                            ? 'Ketuk untuk menandai sudah dibaca.'
                            : item.body,
                        style: const TextStyle(
                          color: AppTheme.muted,
                          height: 1.35,
                        ),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.brandSoft,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    onTap: () async {
                      final route = item.route.trim();
                      await InboxService.instance.markRead(item);
                      if (!context.mounted) return;
                      if (route.isNotEmpty && route != '/notifications') {
                        context.push(route.startsWith('/') ? route : '/$route');
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
