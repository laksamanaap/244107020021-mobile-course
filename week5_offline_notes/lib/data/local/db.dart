import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> openAppDatabase() async {
  final dbPath = join(await getDatabasesPath(), 'offline_notes.db');
  return openDatabase(
    dbPath,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          dirty INTEGER NOT NULL DEFAULT 1,
          updated_at TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE cached_posts (
          id INTEGER PRIMARY KEY,
          userId INTEGER NOT NULL,
          title TEXT NOT NULL,
          body TEXT NOT NULL
        )
      ''');
    },
  );
}
