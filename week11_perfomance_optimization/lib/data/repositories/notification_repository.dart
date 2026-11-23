/// Cache notifikasi: tampilkan data lama dulu, lalu segarkan di belakang.
/// Pola stale-while-revalidate dari codelab minggu 11.
class NotificationRepository {
  NotificationRepository(this._fetch);

  final Future<List<Map<String, dynamic>>> Function() _fetch;

  List<Map<String, dynamic>>? _cached;
  Future<void>? _pending;

  List<Map<String, dynamic>>? get cached => _cached;

  /// Selesai saat refresh latar belakang (kalau ada) sudah berakhir.
  Future<void> get settled => _pending ?? Future<void>.value();

  Future<List<Map<String, dynamic>>> load({
    void Function(List<Map<String, dynamic>> fresh)? onFresh,
  }) async {
    final cached = _cached;
    if (cached != null && cached.isNotEmpty) {
      final pending = _refresh(onFresh);
      _pending = pending;
      return List<Map<String, dynamic>>.from(cached);
    }
    final pending = _refresh(onFresh);
    _pending = pending;
    await pending;
    return List<Map<String, dynamic>>.from(_cached ?? const []);
  }

  Future<void> _refresh(
    void Function(List<Map<String, dynamic>> fresh)? onFresh,
  ) async {
    try {
      final fresh = await _fetch();
      _cached = List<Map<String, dynamic>>.unmodifiable(fresh);
      onFresh?.call(_cached!);
    } catch (_) {
      final cached = _cached;
      if (cached == null || cached.isEmpty) rethrow;
    }
  }
}
