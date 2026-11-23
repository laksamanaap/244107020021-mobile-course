/// Tiga tipe notifikasi Tugas 7, dibaca dari `data.type` payload FCM.
enum NotifKind { list, icon, sound }

NotifKind notifKindFromMessage(Map<String, dynamic> data) {
  switch (data['type']?.toString().trim().toLowerCase()) {
    case 'list':
      return NotifKind.list;
    case 'icon':
      return NotifKind.icon;
    case 'sound':
      return NotifKind.sound;
    default:
      return NotifKind.sound;
  }
}

String notifKindLabel(NotifKind kind) {
  return switch (kind) {
    NotifKind.list => 'list',
    NotifKind.icon => 'icon',
    NotifKind.sound => 'sound',
  };
}
