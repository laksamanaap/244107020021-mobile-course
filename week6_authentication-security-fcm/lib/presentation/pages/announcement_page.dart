import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_theme.dart';
import '../routes.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppTheme.appBar(
        'Pengumuman',
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
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(
              Icons.campaign_outlined,
              size: 48,
              color: AppTheme.brand,
            ),
            const SizedBox(height: 16),
            Text(
              'Pengumuman #$id',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Halaman tujuan klik notifikasi (data.route). '
              'Isi lengkap menunggu backend kampus.',
              style: TextStyle(color: AppTheme.muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
