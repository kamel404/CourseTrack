import 'package:flutter/material.dart';
import '../models/blog_post.dart';
import '../data/storage_service.dart';

class PostProvider with ChangeNotifier {
  // Use our platform-specific storage service
  final StorageService _storageService = StorageService();
  List<BlogPost> _posts = [];
  String _currentCategory = 'All';

  List<BlogPost> get posts => _posts;
  String get currentCategory => _currentCategory;

  Future<void> loadPosts() async {
    try {
      _posts = await _storageService.getPosts();
      print('Loaded ${_posts.length} posts from storage');
      notifyListeners();
    } catch (e) {
      print('Error loading posts: $e');
      // Make sure we always have a valid list even if there's an error
      _posts = _posts.isEmpty ? [] : _posts;
      notifyListeners();
    }
  }

  Future<void> addPost(BlogPost post) async {
    try {
      // First insert the post into storage
      await _storageService.insertPost(post);
      
      // Print debug info
      print('Added post to storage: ${post.title}');
      
      // Reload posts from storage to get a fresh list
      // This is more reliable than manually adding to the list
      await loadPosts();
      
      print('After adding, total posts: ${_posts.length}');
    } catch (e) {
      print('Error in addPost: $e');
      rethrow;
    }
  }

  Future<void> deletePost(String id) async {
    await _storageService.deletePost(id);
    await loadPosts();
  }

  Future<void> setCategory(String category) async {
    _currentCategory = category;
    
    if (category == 'All') {
      _posts = await _storageService.getPosts();
    } else {
      _posts = await _storageService.getPostsByCategory(category);
    }
    
    notifyListeners();
  }
}
