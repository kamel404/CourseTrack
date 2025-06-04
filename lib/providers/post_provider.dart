import 'package:flutter/material.dart';
import '../models/blog_post.dart';
import '../data/storage_service.dart';

class PostProvider with ChangeNotifier {
  // Use our platform-specific storage service
  final StorageService _storageService = StorageService();
  List<BlogPost> _posts = [];
  List<BlogPost> _allPosts = []; // Store all posts for search functionality
  String _currentCategory = 'All';
  bool _isSearchActive = false;

  List<BlogPost> get posts => _posts;
  String get currentCategory => _currentCategory;
  bool get isSearchActive => _isSearchActive;

  Future<void> loadPosts() async {
    try {
      _posts = await _storageService.getPosts();
      _allPosts = List.from(_posts); // Keep a copy of all posts for search
      notifyListeners();
    } catch (e) {
      // Make sure we always have a valid list even if there's an error
      _posts = _posts.isEmpty ? [] : _posts;
      _allPosts = List.from(_posts);
      notifyListeners();
    }
  }

  Future<void> addPost(BlogPost post) async {
    try {
      // First insert the post into storage
      await _storageService.insertPost(post);
      // Reload posts from storage to get a fresh list
      await loadPosts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePost(String id) async {
    await _storageService.deletePost(id);
    await loadPosts();
  }

  Future<void> updatePost(BlogPost post) async {
    try {
      // Update the post in storage
      await _storageService.updatePost(post);

      // Reload posts from storage to get a fresh list
      await loadPosts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setCategory(String category) async {
    _currentCategory = category;
    _isSearchActive = false;

    if (category == 'All') {
      _posts = await _storageService.getPosts();
      _allPosts = List.from(_posts);
    } else {
      _posts = await _storageService.getPostsByCategory(category);
      _allPosts = List.from(_posts);
    }

    notifyListeners();
  }

  // Search posts by title
  void searchPostsByTitle(String query) {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    _isSearchActive = true;
    final lowercaseQuery = query.toLowerCase();

    _posts =
        _allPosts.where((post) {
          return post.title.toLowerCase().contains(lowercaseQuery);
        }).toList();

    notifyListeners();
  }

  // Clear search and restore original posts
  void clearSearch() {
    if (_isSearchActive) {
      _isSearchActive = false;
      _posts = List.from(_allPosts);
      notifyListeners();
    }
  }
}
