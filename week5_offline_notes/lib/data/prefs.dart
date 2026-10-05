import 'package:shared_preferences/shared_preferences.dart';

/// Pintu tunggal ke SharedPreferences untuk preferensi aplikasi.
class PrefsRepository {
  PrefsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _keyDarkMode = 'dark_mode';
  static const _keyLastOpened = 'last_opened';

  bool getDarkMode() => _prefs.getBool(_keyDarkMode) ?? false;

  Future<void> setDarkMode(bool value) =>
      _prefs.setBool(_keyDarkMode, value);

  /// Mengembalikan nilai lama sebelum ditimpa (bisa null jika pertama kali).
  String? getLastOpened() => _prefs.getString(_keyLastOpened);

  Future<void> setLastOpened(String iso8601) =>
      _prefs.setString(_keyLastOpened, iso8601);
}
