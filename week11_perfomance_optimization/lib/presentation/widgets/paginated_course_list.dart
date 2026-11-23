import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/course_catalog_repository.dart';
import '../theme/app_theme.dart';
import 'lms_cover.dart';

/// Daftar mata kuliah. Hanya membangun tile yang terlihat,
/// dan mengambil halaman berikutnya saat scroll mendekati bawah.
class PaginatedCourseList extends ConsumerStatefulWidget {
  const PaginatedCourseList({super.key, this.onOpenCourse});

  final VoidCallback? onOpenCourse;

  @override
  ConsumerState<PaginatedCourseList> createState() =>
      _PaginatedCourseListState();
}

class _PaginatedCourseListState extends ConsumerState<PaginatedCourseList> {
  final _scrollController = ScrollController();
  final _items = <CourseListItem>[];
  var _page = 1;
  var _isLoading = false;
  var _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPage();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoading || !_hasMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadPage();
    }
  }

  Future<void> _loadPage() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    try {
      final repo = ref.read(courseCatalogRepositoryProvider);
      final next = await repo.fetchPage(_page);
      if (!mounted) return;
      setState(() {
        if (next.isEmpty) {
          _hasMore = false;
        } else {
          _items.addAll(next);
          _page++;
          _hasMore = _items.length < CourseCatalogRepository.catalog.length;
        }
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final extra = _hasMore ? 1 : 0;
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _items.length + 1 + extra,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) return const _CourseListHeader();
        final dataIndex = index - 1;
        if (dataIndex >= _items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return CourseTile(item: _items[dataIndex], onTap: widget.onOpenCourse);
      },
    );
  }
}

class _CourseListHeader extends StatelessWidget {
  const _CourseListHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          SizedBox(
            width: 3,
            height: 18,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.brandSoft,
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Mata kuliah kamu',
            style: TextStyle(
              color: AppTheme.text,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class CourseTile extends StatelessWidget {
  const CourseTile({super.key, required this.item, this.onTap});

  final CourseListItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final image = item.asset;
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: image == null && (item.imageUrl == null)
            ? const _TaskGlyph()
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LmsCover(
                  asset: image,
                  imageUrl: item.imageUrl,
                  width: 48,
                  height: 48,
                ),
              ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.text,
          ),
        ),
        subtitle: Text(
          item.subtitle,
          style: const TextStyle(color: AppTheme.muted, fontSize: 13),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.brandSoft,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _TaskGlyph extends StatelessWidget {
  const _TaskGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        gradient: LinearGradient(colors: [AppTheme.brand, AppTheme.brandSoft]),
      ),
      child: const Icon(
        Icons.assignment_turned_in_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}
