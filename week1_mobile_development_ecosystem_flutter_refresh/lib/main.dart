import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ProfilMahasiswaPage(),
    );
  }
}

class CatalogItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const CatalogItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class ProfilMahasiswaPage extends StatelessWidget {
  const ProfilMahasiswaPage({super.key});

  static const String nama = 'Laksamana AryaPutra';

  static String getInitials(String name) {
    return name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase())
        .join();
  }

  static const List<CatalogItem> catalog = [
    CatalogItem(
      title: 'Flutter Basics',
      subtitle: 'Widget & layout',
      icon: Icons.flutter_dash,
      color: Colors.blue,
    ),
    CatalogItem(
      title: 'Dart Refresh',
      subtitle: 'Syntax & OOP',
      icon: Icons.code,
      color: Colors.teal,
    ),
    CatalogItem(
      title: 'Hot Reload',
      subtitle: 'Dev workflow',
      icon: Icons.bolt,
      color: Colors.orange,
    ),
    CatalogItem(
      title: 'State UI',
      subtitle: 'Deklaratif',
      icon: Icons.account_tree,
      color: Colors.purple,
    ),
    CatalogItem(
      title: 'Git Commit',
      subtitle: 'Version control',
      icon: Icons.commit,
      color: Colors.green,
    ),
    CatalogItem(
      title: 'Native vs XP',
      subtitle: 'Platform choice',
      icon: Icons.phone_android,
      color: Colors.indigo,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final initials = getInitials(nama);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Mahasiswa'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    nama,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'AI Native Software Engineer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pemrograman Mobile — Minggu 1',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.badge_outlined, size: 20),
                      SizedBox(width: 4),
                      Text('NIM'),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '244107020021',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.class_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Kelas'),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'TI-3C',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'My Catalog',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: catalog.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  return CatalogCard(item: catalog[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CatalogCard extends StatelessWidget {
  const CatalogCard({super.key, required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 72,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, size: 36, color: item.color),
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
