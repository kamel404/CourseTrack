import '../models/blog_post.dart';
import 'dart:developer' as developer;
import 'dart:convert';

// A mock implementation of DatabaseHelper for web environments
// This avoids SQLite initialization on web which causes the error
class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();
  
  // In-memory storage for web - must be static to persist between page reloads
  static final List<Map<String, dynamic>> _postsData = [];
  
  // Flag to know if we've initialized test data
  static bool _initialized = false;
  
  // Private constructor
  DatabaseHelper._init() {
    developer.log('Web DatabaseHelper initialized');
    _initializeTestDataIfNeeded();
  }
  
  // Add a sample post if there are none - for testing only
  void _initializeTestDataIfNeeded() {
    if (!_initialized) {
      developer.log('Initializing test data for web');
      _initialized = true;
      
      // If we don't have any posts yet, add a welcome post
      if (_postsData.isEmpty) {
        final welcomePost = {
          'id': 'welcome-post',
          'title': 'Welcome to the Blog App!',
          'content': 'This is a sample post to get you started. Try adding your own posts!',
          'category': 'General',
          'date': DateTime.now().toIso8601String(),
          'imageUrl': '',
        };
        _postsData.add(welcomePost);
        developer.log('Added welcome post to web storage');
      }
    }
  }

  // Mock implementation of database getter - no actual database for web
  Future<dynamic> get database async {
    developer.log('Web database getter called');
    return Future.value(null); // Return null for web as there's no actual SQLite database
  }
  
  // Mock implementation of database operations for web
  Future<int> insertPost(BlogPost post) async {
    developer.log('Inserting post in web storage: ${post.title}');
    final postMap = post.toMap();
    // Ensure we don't add duplicates
    final exists = _postsData.any((p) => p['id'] == postMap['id']);
    if (!exists) {
      _postsData.add(postMap);
      developer.log('Post added successfully. Current posts: ${jsonEncode(_postsData)}');
    } else {
      developer.log('Post already exists, not adding duplicate');
    }
    developer.log('Current posts count: ${_postsData.length}');
    return 1; // Simulate success
  }
  
  Future<List<BlogPost>> getPosts() async {
    developer.log('Getting posts from web storage, count: ${_postsData.length}');
    if (_postsData.isEmpty) {
      developer.log('No posts found in web storage');
      return [];
    }
    
    try {
      final posts = List.generate(_postsData.length, (i) => BlogPost.fromMap(_postsData[i]));
      developer.log('Retrieved ${posts.length} posts, first post title: ${posts.isNotEmpty ? posts.first.title : "none"}');
      return posts;
    } catch (e) {
      developer.log('Error getting posts from web storage: $e');
      return [];
    }
  }
  
  Future<List<BlogPost>> getPostsByCategory(String category) async {
    final filteredData = _postsData.where((map) => map['category'] == category).toList();
    return List.generate(filteredData.length, (i) => BlogPost.fromMap(filteredData[i]));
  }
  
  Future<int> deletePost(String id) async {
    final initialLength = _postsData.length;
    _postsData.removeWhere((map) => map['id'] == id);
    return initialLength - _postsData.length; // Return number of items removed
  }
  
  Future<int> updatePost(BlogPost post) async {
    developer.log('Updating post in web storage: ${post.title}');
    final index = _postsData.indexWhere((map) => map['id'] == post.id);
    if (index != -1) {
      _postsData[index] = post.toMap();
      developer.log('Post updated successfully. Current posts: ${jsonEncode(_postsData)}');
      return 1; // Success
    }
    developer.log('Post not found for update');
    return 0; // Not found
  }
}
