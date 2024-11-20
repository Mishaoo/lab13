import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE notes (id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT, date TEXT)',
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    return await db.query('notes', orderBy: 'id DESC');
  }

  Future<int> addNote(String text) async {
    final db = await database;
    return await db.insert('notes', {
      'text': text,
      'date': DateTime.now().toString(),
    });
  }

  Future<void> closeDatabase() async {
    final db = await _database;
    if (db != null) {
      await db.close();
    }
  }
}
