// ignore_for_file: await_only_futures

import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/blog_post.dart';
import 'db_helper.dart' if (dart.library.html) 'web_db_helper.dart';

// Abstract base class for storage operations
abstract class StorageService {
  Future<List<BlogPost>> getPosts();
  Future<List<BlogPost>> getPostsByCategory(String category);
  Future<int> insertPost(BlogPost post);
  Future<int> updatePost(BlogPost post);
  Future<int> deletePost(String id);

  // Factory constructor to return the appropriate implementation
  factory StorageService() {
    if (kIsWeb) {
      return WebStorageService();
    } else {
      return SqliteStorageService();
    }
  }
}

// Web-specific implementation using in-memory storage
class WebStorageService implements StorageService {
  // In-memory storage for web
  static final List<BlogPost> _posts = [];

  @override
  Future<List<BlogPost>> getPosts() async {
    return _posts;
  }

  @override
  Future<List<BlogPost>> getPostsByCategory(String category) async {
    return _posts.where((post) => post.category == category).toList();
  }

  @override
  Future<int> insertPost(BlogPost post) async {
    _posts.add(post);
    return 1; // Simulate successful insert
  }

  @override
  Future<int> deletePost(String id) async {
    final initialLength = _posts.length;
    _posts.removeWhere((post) => post.id == id);
    return initialLength - _posts.length; // Return number of deleted items
  }

  @override
  Future<int> updatePost(BlogPost post) async {
    final index = _posts.indexWhere((p) => p.id == post.id);
    if (index != -1) {
      _posts[index] = post;
      return 1; // Success
    }
    return 0; // Not found
  }
}

// SQLite implementation for non-web platforms
class SqliteStorageService implements StorageService {
  @override
  Future<List<BlogPost>> getPosts() async {
    // This will be implemented by calling the actual SQLite operations
    // We'll integrate this with the existing DatabaseHelper
    final dbHelper = await _getDbHelper();
    return dbHelper.getPosts();
  }

  @override
  Future<List<BlogPost>> getPostsByCategory(String category) async {
    final dbHelper = await _getDbHelper();
    return dbHelper.getPostsByCategory(category);
  }

  @override
  Future<int> insertPost(BlogPost post) async {
    final dbHelper = await _getDbHelper();
    return dbHelper.insertPost(post);
  }

  @override
  Future<int> deletePost(String id) async {
    final dbHelper = await _getDbHelper();
    return dbHelper.deletePost(id);
  }

  @override
  Future<int> updatePost(BlogPost post) async {
    final dbHelper = await _getDbHelper();
    return dbHelper.updatePost(post);
  }

  // Get the database helper instance
  DatabaseHelper _getDbHelper() {
    return DatabaseHelper.instance;
  }
}
