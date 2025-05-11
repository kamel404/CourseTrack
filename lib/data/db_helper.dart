import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/blog_post.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static Database? _database;

  // Singleton pattern
  factory DbHelper() => _instance;

  DbHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'blog_posts.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE blog_posts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        author TEXT NOT NULL,
        date TEXT NOT NULL,
        imagePath TEXT // Ensure this matches the BlogPost model
      )
    ''');
  }

  // Insert a blog post into the DB
  Future<void> insertPost(BlogPost post) async {
    final db = await database;
    await db.insert(
      'blog_posts',
      post.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve all posts (for Home screen)
  Future<List<BlogPost>> getAllPosts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'blog_posts',
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return BlogPost.fromMap(maps[i]);
    });
  }

  // Retrieve posts by user
  Future<List<BlogPost>> getMyPosts(String author) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'blog_posts',
      where: 'author = ?',
      whereArgs: [author],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return BlogPost.fromMap(maps[i]);
    });
  }

  // Edit an existing post
  Future<int> updatePost(BlogPost post) async {
    final db = await database;
    return await db.update(
      'blog_posts',
      post.toMap(),
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }

  // Remove post by ID
  Future<void> deletePost(int id) async {
    final db = await database;
    await db.delete('blog_posts', where: 'id = ?', whereArgs: [id]);
  }

  // Search posts by keywords in title or content
  Future<List<BlogPost>> searchPosts(String keyword) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'blog_posts',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return BlogPost.fromMap(maps[i]);
    });
  }
}
