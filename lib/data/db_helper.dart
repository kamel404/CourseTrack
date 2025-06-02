import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/blog_post.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Initialize database for desktop platforms
void initializeDatabase() {
  if (!kIsWeb) {
    // Initialize FFI
    sqfliteFfiInit();
    // Set database factory - THIS IS THE CRUCIAL LINE
    databaseFactory = databaseFactoryFfi;
  }
}

class DatabaseHelper {
  // Use static field initialization to ensure database is initialized first
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init() {
    // Ensure database is initialized during construction
    if (!kIsWeb) {
      initializeDatabase();
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Make sure SQLite is initialized before opening database
    if (!kIsWeb) {
      initializeDatabase();
    }

    try {
      _database = await _initDB('blog.db');
      return _database!;
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE posts (
        id TEXT PRIMARY KEY,
        title TEXT,
        content TEXT,
        category TEXT,
        date TEXT,
        imageUrl TEXT
      )
    ''');
  }

  Future<int> insertPost(BlogPost post) async {
    final db = await instance.database;
    return await db.insert('posts', post.toMap());
  }

  Future<List<BlogPost>> getPosts() async {
    final db = await instance.database;
    final maps = await db.query('posts', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => BlogPost.fromMap(maps[i]));
  }

  Future<List<BlogPost>> getPostsByCategory(String category) async {
    final db = await instance.database;
    final maps = await db.query(
      'posts',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => BlogPost.fromMap(maps[i]));
  }

  Future<int> deletePost(String id) async {
    final db = await instance.database;
    return await db.delete('posts', where: 'id = ?', whereArgs: [id]);
  }
}
