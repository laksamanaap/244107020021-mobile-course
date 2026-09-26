import 'package:flutter/material.dart';

/// Design system merah gelap — selaras di Home / Playbox / Library / Profile.
abstract final class AppTheme {
  static const brand = Color.fromARGB(255, 161, 29, 29);
  static const brandSoft = Color(0xFFC44A4A);
  static const bg = Color(0xFF140A0B);
  static const bgMid = Color(0xFF1E1012);
  static const card = Color(0xFF2A1719);
  static const cardLift = Color(0xFF3A1F22);
  static const muted = Color(0xFFC9A8A8);
  static const text = Colors.white;
  static const headerBg = Color(0xFF4A1518);

  static const pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [headerBg, bgMid, bg],
    stops: [0, 0.28, 0.55],
  );

  static BoxDecoration get pageDecoration =>
      const BoxDecoration(gradient: pageGradient);

  static Widget page({required Widget child, bool safeTop = true}) {
    return DecoratedBox(
      decoration: pageDecoration,
      child: SafeArea(bottom: false, top: safeTop, child: child),
    );
  }

  static AppBar appBar(String title, {List<Widget>? actions}) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: bgMid,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: text),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: brandSoft.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}

/// Header sticky: avatar LA + judul + notifikasi/riwayat.
class AppStickyHeader extends StatelessWidget {
  const AppStickyHeader({
    super.key,
    required this.title,
    this.onAvatarTap,
  });

  final String title;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.headerBg,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
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
                        color: Colors.white,
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
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                tooltip: 'Notifikasi',
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.history_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                tooltip: 'Riwayat',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
