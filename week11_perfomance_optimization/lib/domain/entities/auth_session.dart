class AuthSession {
  const AuthSession({required this.access, required this.refresh, this.user});

  final String access;
  final String refresh;
  final AuthUser? user;
}

class AuthUser {
  const AuthUser({required this.id, required this.name, required this.email});

  final int id;
  final String name;
  final String email;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}
