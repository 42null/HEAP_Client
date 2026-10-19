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
      version: 4,
      onCreate: (db, version) async {
        // Create queue_items table
        await db.execute('''
          CREATE TABLE queue_items (
            queueId TEXT PRIMARY KEY,
            itemId INTEGER,
            jobId TEXT,
            payload TEXT,
            jobType INTEGER,
            status INTEGER,
            priority INTEGER,
            createdAt INTEGER,
            retryCount INTEGER,
            errorMessage TEXT
          )
        ''');

        // Create jobs table
        await db.execute('''
          CREATE TABLE jobs (
            jobId TEXT PRIMARY KEY,
            itemId INTEGER,
            jobType INTEGER,
            payload TEXT,
            priority INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // Create queue_items table if it doesn't exist
          await db.execute('''
            CREATE TABLE IF NOT EXISTS queue_items (
              queueId TEXT PRIMARY KEY,
              itemId INTEGER,
              jobId TEXT,
              payload TEXT,
              jobType INTEGER,
              status INTEGER,
              priority INTEGER,
              createdAt INTEGER,
              retryCount INTEGER,
              errorMessage TEXT
            )
          ''');

          // Create jobs table if it doesn't exist
          await db.execute('''
            CREATE TABLE IF NOT EXISTS jobs (
              jobId TEXT PRIMARY KEY,
              itemId INTEGER,
              jobType INTEGER,
              payload TEXT,
              priority INTEGER
            )
          ''');
        }

        if (oldVersion < 4) {
          try {
            await db.execute('ALTER TABLE queue_items ADD COLUMN jobId TEXT');
          } catch (e) {}
          try {
            await db.execute('ALTER TABLE queue_items ADD COLUMN jobType INTEGER');
          } catch (e) {}
        }
      },
    );
  }
}