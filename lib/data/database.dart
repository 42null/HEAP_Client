import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/queue_item.dart';

class DatabaseHelper {
  static final DatabaseHelper Instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = join(await getDatabasesPath(), 'heap_queue.db');
    return await openDatabase(
      dbPath,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE queue_items (
            queueId TEXT PRIMARY KEY,
            itemId INTEGER,
            payload TEXT,
            status INTEGER,
            priority INTEGER,
            createdAt INTEGER,
            retryCount INTEGER,
            errorMessage TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS queue_items (
              queueId TEXT PRIMARY KEY,
              itemId INTEGER,
              payload TEXT,
              status INTEGER,
              priority INTEGER,
              createdAt INTEGER,
              retryCount INTEGER,
              errorMessage TEXT
            )
          ''');
        }
      },
    );
  }
}