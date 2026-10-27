import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'messaging/inbox_service.dart';

/// Design system LMS kampus — terang, teal, dipakai di Beranda / Kelas / Kursus / Profil.
abstract final class AppTheme {
  static const brand = Color(0xFF1B7A8F);
  static const brandSoft = Color(0xFF3A9BB0);
  static const brandDeep = Color(0xFF145F70);
  static const bg = Color(0xFFF3F7FB);
  static const bgMid = Color(0xFFE8F1F6);
  static const card = Color(0xFFFFFFFF);
  static const cardLift = Color(0xFFF7FBFD);
  static const muted = Color(0xFF5E7383);
  static const text = Color(0xFF163042);
  static const headerBg = Color(0xFFFFFFFF);
  static const onBrand = Color(0xFFFFFFFF);
  static const hairline = Color(0xFFD5E3EC);
  static const accent = Color(0xFFE2A336);

  static const pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [headerBg, bgMid, bg],
    stops: [0, 0.22, 0.55],
  );

  static BoxDecoration get pageDecoration =>
      const BoxDecoration(gradient: pageGradient);

  static List<BoxShadow> get cardShadow => const [
    BoxShadow(color: Color(0x140D3344), blurRadius: 18, offset: Offset(0, 8)),
  ];

  static Widget page({required Widget child, bool safeTop = true}) {
    return DecoratedBox(
      decoration: pageDecoration,
      child: SafeArea(bottom: false, top: safeTop, child: child),
    );
  }

  static AppBar appBar(
    String title, {
    List<Widget>? actions,
    Widget? leading,
  }) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: headerBg,
      elevation: 0,
      centerTitle: true,
      leading: leading,
      automaticallyImplyLeading: leading == null,
      iconTheme: const IconThemeData(color: text),
      actions: actions,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: ColoredBox(color: hairline, child: SizedBox(height: 1)),
      ),
    );
  }
}

/// Header sticky: avatar mahasiswa + judul + notifikasi/riwayat.
class AppStickyHeader extends StatelessWidget {
  const AppStickyHeader({
    super.key,
    required this.title,
    this.onAvatarTap,
    this.onBellTap,
  });

  final String title;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onBellTap;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Material(
        color: AppTheme.headerBg,
        elevation: 0,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onAvatarTap,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.brandSoft.withValues(alpha: 0.55),
                            width: 1.5,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.brand,
                          child: Text(
                            'LA',
                            style: TextStyle(
                              color: AppTheme.onBrand,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.text,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    ValueListenableBuilder<List<CampusInboxItem>>(
                      valueListenable: InboxService.instance.unread,
                      builder: (context, items, _) {
                        return IconButton(
                          onPressed: onBellTap,
                          tooltip: 'Notifikasi',
                          icon: Badge(
                            isLabelVisible: items.isNotEmpty,
                            label: Text('${items.length}'),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              color: AppTheme.text,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.calendar_month_outlined,
                        color: AppTheme.text,
                      ),
                      tooltip: 'Jadwal',
                    ),
                  ],
                ),
              ),
              const ColoredBox(
                color: AppTheme.hairline,
                child: SizedBox(height: 1, width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
