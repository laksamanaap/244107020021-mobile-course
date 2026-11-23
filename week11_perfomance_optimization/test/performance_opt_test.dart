import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week11_perfomance_optimization/data/repositories/course_catalog_repository.dart';
import 'package:week11_perfomance_optimization/data/repositories/notification_repository.dart';
import 'package:week11_perfomance_optimization/presentation/pages/spotify_home_page.dart';
import 'package:week11_perfomance_optimization/presentation/widgets/paginated_course_list.dart';

void main() {
  test('notifikasi stale-while-revalidate mengembalikan cache dulu', () async {
    var calls = 0;
    final repo = NotificationRepository(() async {
      calls++;
      final id = calls;
      await Future<void>.delayed(const Duration(milliseconds: 30));
      return [
        {
          'id': id,
          'title': 'Pengumuman $id',
          'body': 'isi',
          'route': '/pengumuman/$id',
          'created_at': '2026-11-23T03:00:00Z',
        },
      ];
    });

    final first = await repo.load();
    expect(calls, 1);
    expect(first.single['title'], 'Pengumuman 1');

    Map<String, dynamic>? fresh;
    final second = await repo.load(onFresh: (rows) => fresh = rows.single);
    expect(second.single['title'], 'Pengumuman 1');
    expect(fresh, isNull);

    await repo.settled;
    expect(calls, 2);
    expect(fresh?['title'], 'Pengumuman 2');
  });

  test('fetch gagal tetap mengembalikan cache', () async {
    var calls = 0;
    final repo = NotificationRepository(() async {
      calls++;
      if (calls == 1) {
        return [
          {'id': 1, 'title': 'Cache'},
        ];
      }
      throw Exception('jaringan putus');
    });

    expect((await repo.load()).single['title'], 'Cache');
    final again = await repo.load();
    await repo.settled;
    expect(again.single['title'], 'Cache');
    expect(calls, 2);
  });

  test('katalog memotong halaman dan halaman habis kosong', () async {
    final repo = CourseCatalogRepository(pageSize: 6, delay: Duration.zero);
    final page1 = await repo.fetchPage(1);
    final page2 = await repo.fetchPage(2);
    final last = await repo.fetchPage(99);
    expect(page1, hasLength(6));
    expect(page1.first.title, 'Pemrograman Mobile');
    expect(page2.first.title, 'Poster pengumuman JTI');
    expect(last, isEmpty);
  });

  testWidgets('ganti filter tidak membangun ulang grid statis', (tester) async {
    FeedRebuildMark.builds = 0;
    recentListBuilds = 0;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SpotifyHomePage())),
    );
    await tester.pump();

    final gridBuilds = FeedRebuildMark.builds;
    final recentBefore = recentListBuilds;
    expect(gridBuilds, greaterThan(0));
    expect(find.text('Modul 4 — ERD & Relasi'), findsOneWidget);

    await tester.tap(find.text('Tugas'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(FeedRebuildMark.builds, gridBuilds);
    expect(recentListBuilds, greaterThan(recentBefore));
    expect(find.text('Modul 4 — ERD & Relasi'), findsNothing);
    expect(find.text('Quiz subnetting'), findsOneWidget);
    // ignore: avoid_print
    print(
      'REBUILD grid=$gridBuilds tetap, recent $recentBefore -> $recentListBuilds',
    );
  });

  testWidgets('pagination hanya memuat satu halaman sampai di-scroll', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseCatalogRepositoryProvider.overrideWithValue(
            CourseCatalogRepository(pageSize: 6, delay: Duration.zero),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: PaginatedCourseList())),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Pemrograman Mobile'), findsOneWidget);
    expect(find.text('Poster pengumuman JTI'), findsNothing);
    expect(find.byType(CourseTile), findsNWidgets(6));

    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pump();
    await tester.pump();
    expect(find.text('Poster pengumuman JTI'), findsOneWidget);
  });

  testWidgets('ListView.builder tidak membuat tile di luar viewport', (
    tester,
  ) async {
    const count = 80;

    Future<int> mountedTiles(Widget list) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: list)));
      await tester.pump();
      return find.byType(ListTile).evaluate().length;
    }

    final eagerSw = Stopwatch()..start();
    final eager = await mountedTiles(
      SingleChildScrollView(
        child: Column(
          children: [
            for (var i = 0; i < count; i++)
              ListTile(title: Text('Mata kuliah eager $i')),
          ],
        ),
      ),
    );
    eagerSw.stop();

    final lazySw = Stopwatch()..start();
    final lazy = await mountedTiles(
      ListView.builder(
        itemCount: count,
        itemBuilder: (context, i) =>
            ListTile(title: Text('Mata kuliah lazy $i')),
      ),
    );
    lazySw.stop();

    expect(eager, count);
    expect(lazy, lessThan(count));
    expect(find.text('Mata kuliah lazy 0'), findsOneWidget);
    expect(find.text('Mata kuliah lazy ${count - 1}'), findsNothing);
    // ignore: avoid_print
    print(
      'LIST eager_tiles=$eager ${eagerSw.elapsedMicroseconds}us '
      'builder_tiles=$lazy ${lazySw.elapsedMicroseconds}us',
    );
  });
}
