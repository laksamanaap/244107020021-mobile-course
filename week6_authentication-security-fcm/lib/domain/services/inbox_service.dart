import 'package:flutter/foundation.dart';

class CampusInboxItem {
  const CampusInboxItem({
    required this.localId,
    this.serverId,
    required this.title,
    required this.body,
    required this.route,
    required this.createdAt,
  });

  final String localId;
  final int? serverId;
  final String title;
  final String body;
  final String route;
  final DateTime createdAt;

  CampusInboxItem copyWith({int? serverId}) {
    return CampusInboxItem(
      localId: localId,
      serverId: serverId ?? this.serverId,
      title: title,
      body: body,
      route: route,
      createdAt: createdAt,
    );
  }

  factory CampusInboxItem.fromApi(Map<String, dynamic> json) {
    final id = (json['id'] as num?)?.toInt();
    return CampusInboxItem(
      localId: 'api-${id ?? DateTime.now().microsecondsSinceEpoch}',
      serverId: id,
      title: json['title']?.toString() ?? 'Pengumuman',
      body: json['body']?.toString() ?? '',
      route: json['route']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

/// Kotak masuk in-app untuk FCM `type=list`. Item hilang saat ditandai dibaca.
class InboxService {
  InboxService._();
  static final InboxService instance = InboxService._();

  final ValueNotifier<List<CampusInboxItem>> unread = ValueNotifier(const []);

  Future<int?> Function(CampusInboxItem item)? persistCreate;
  Future<void> Function(CampusInboxItem item)? persistRead;

  void replace(List<CampusInboxItem> items) {
    unread.value = List.unmodifiable(items);
  }

  void add(CampusInboxItem item) {
    unread.value = List.unmodifiable([item, ...unread.value]);
  }

  void upsertServerId(String localId, int serverId) {
    unread.value = List.unmodifiable([
      for (final item in unread.value)
        if (item.localId == localId) item.copyWith(serverId: serverId) else item,
    ]);
  }

  Future<void> ingestList({
    required String title,
    required String body,
    required String route,
  }) async {
    final item = CampusInboxItem(
      localId: 'fcm-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      body: body,
      route: route,
      createdAt: DateTime.now(),
    );
    add(item);
    try {
      final serverId = await persistCreate?.call(item);
      if (serverId != null) {
        upsertServerId(item.localId, serverId);
      }
    } catch (_) {
      // Inbox lokal tetap tampil meski API gagal.
    }
  }

  Future<void> markRead(CampusInboxItem item) async {
    unread.value = List.unmodifiable(
      unread.value.where((row) => row.localId != item.localId),
    );
    try {
      await persistRead?.call(item);
    } catch (_) {}
  }

  void clear() {
    unread.value = const [];
  }
}
