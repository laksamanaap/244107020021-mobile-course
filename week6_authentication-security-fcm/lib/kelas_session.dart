import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'lms_content.dart';

void showSyllabusSheet({
  required BuildContext context,
  ScrollController? controller,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.card,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      final height = MediaQuery.of(context).size.height * 0.82;
      return SafeArea(
        child: SizedBox(
          height: height,
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  LmsImages.authFcm,
                  height: 148,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Silabus pertemuan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pemrograman Mobile · TI-3C · JTI Polinema',
                style: TextStyle(color: AppTheme.muted, fontSize: 13),
              ),
              const SizedBox(height: 14),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  LmsChip(label: 'Modul 6'),
                  LmsChip(label: 'Praktikum'),
                  LmsChip(label: 'Wajib hadir'),
                ],
              ),
              const SizedBox(height: 20),
              const LmsSyllabusBlock(
                icon: Icons.flag_outlined,
                title: 'Capaian pembelajaran',
                points: [
                  'Menjelaskan alur autentikasi di aplikasi kampus',
                  'Membedakan ID token, access token, dan refresh token',
                  'Menyimpan token secara aman di perangkat',
                ],
              ),
              const SizedBox(height: 12),
              const LmsSyllabusBlock(
                icon: Icons.menu_book_outlined,
                title: 'Materi inti',
                points: [
                  'Mock authentication provider + JWT simulasi',
                  'Secure storage dan token refresh otomatis',
                  'Dio interceptor untuk HTTP 401',
                ],
              ),
              const SizedBox(height: 12),
              const LmsSyllabusBlock(
                icon: Icons.assignment_outlined,
                title: 'Tugas',
                points: [
                  'Login mock, simpan token, uji refresh 401',
                  'Jangan men-log token atau secret',
                  'Siapkan akun Firebase untuk sesi FCM',
                ],
              ),
              const SizedBox(height: 12),
              const LmsSyllabusBlock(
                icon: Icons.campaign_outlined,
                title: 'Pengumuman',
                points: [
                  'Praktikum 1 dikumpulkan sebelum sesi berikutnya',
                  'Uji notifikasi paling mudah di HP fisik',
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.brand,
                  foregroundColor: AppTheme.onBrand,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Tutup silabus'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class KelasQueueDrawer extends StatelessWidget {
  const KelasQueueDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.bg,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Urutan belajar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.text,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppTheme.muted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _NowLearningCard(item: LmsCatalog.current),
            const SizedBox(height: 16),
            const Text(
              'Berikutnya',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 10),
            for (final item in LmsCatalog.upcoming) ...[
              _QueueTile(item: item),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _NowLearningCard extends StatelessWidget {
  const _NowLearningCard({required this.item});

  final LmsMaterial item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.brand,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sedang dipelajari',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  item.image,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.course,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QueueTile extends StatelessWidget {
  const _QueueTile({required this.item});

  final LmsMaterial item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            item.image,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.text,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '${item.course} · ${item.meta}',
          style: const TextStyle(color: AppTheme.muted, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.brand,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class KelasSessionBody extends StatelessWidget {
  const KelasSessionBody({
    super.key,
    required this.onOpenSyllabus,
    required this.onOpenQueue,
  });

  final VoidCallback onOpenSyllabus;
  final VoidCallback onOpenQueue;

  @override
  Widget build(BuildContext context) {
    final item = LmsCatalog.current;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Image.asset(
                item.image,
                height: 210,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x330D3344), Color(0xCC0D3344)],
                    ),
                  ),
                ),
              ),
              const Positioned(
                left: 14,
                bottom: 14,
                child: LmsChip(label: 'Modul 6', dark: true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          item.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.text,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${item.course} · TI-3C',
          style: const TextStyle(color: AppTheme.muted, fontSize: 14),
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LmsChip(label: 'Auth'),
            LmsChip(label: 'Security'),
            LmsChip(label: 'FCM'),
          ],
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Text(
              'Progress modul',
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer(),
            Text(
              '35%',
              style: TextStyle(
                color: AppTheme.brandDeep,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: const LinearProgressIndicator(
            value: 0.35,
            minHeight: 6,
            backgroundColor: AppTheme.hairline,
            color: AppTheme.brand,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onOpenSyllabus,
          icon: const Icon(Icons.list_alt_rounded, size: 18),
          label: const Text('Lihat silabus'),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.brand,
            foregroundColor: AppTheme.onBrand,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 22),
        const _SectionTitle('Ringkasan pertemuan'),
        const SizedBox(height: 10),
        const LmsSyllabusBlock(
          icon: Icons.flag_outlined,
          title: 'Yang akan kamu kuasai',
          points: [
            'Alur login, token, dan refresh otomatis',
            'Cara menyimpan sesi tanpa membocorkan secret',
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const Expanded(child: _SectionTitle('Materi berikutnya')),
            TextButton(
              onPressed: onOpenQueue,
              child: const Text('Lihat semua'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final next in LmsCatalog.upcoming) ...[
          _NextMaterialCard(item: next),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _NextMaterialCard extends StatelessWidget {
  const _NextMaterialCard({required this.item});

  final LmsMaterial item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                item.image,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.course,
                    style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.meta,
                    style: const TextStyle(
                      color: AppTheme.brandDeep,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppTheme.text,
      ),
    );
  }
}

class LmsChip extends StatelessWidget {
  const LmsChip({super.key, required this.label, this.dark = false});

  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withValues(alpha: 0.16) : AppTheme.bgMid,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dark ? Colors.white.withValues(alpha: 0.2) : AppTheme.hairline,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: dark ? Colors.white : AppTheme.text,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class LmsSyllabusBlock extends StatelessWidget {
  const LmsSyllabusBlock({
    super.key,
    required this.icon,
    required this.title,
    required this.points,
  });

  final IconData icon;
  final String title;
  final List<String> points;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.brand),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final point in points)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: CircleAvatar(
                      radius: 3,
                      backgroundColor: AppTheme.brandSoft,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        color: AppTheme.text,
                        height: 1.35,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
