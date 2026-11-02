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
