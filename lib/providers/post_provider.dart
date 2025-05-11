import 'package:coursetrack/data/db_helper.dart';
import 'package:coursetrack/models/blog_post.dart';
import 'package:flutter/foundation.dart';

class PostProvider extends ChangeNotifier {
  final DbHelper _dbHelper = DbHelper();
  List<BlogPost> _posts = [];

  List<BlogPost> get posts => _posts;

  Future<void> fetchAllPosts() async {
    _posts = await _dbHelper.getAllPosts();
    notifyListeners();
  }

  Future<void> fetchUserPosts(String author) async {
    _posts = await _dbHelper.getMyPosts(author);
    notifyListeners();
  }

  Future<void> addPost(BlogPost post) async {
    await _dbHelper.insertPost(post);
    await fetchAllPosts(); // Refresh the list after adding
  }

  Future<void> updatePost(BlogPost post) async {
    await _dbHelper.updatePost(post);
    await fetchAllPosts(); // Refresh the list after updating
  }

  Future<void> deletePost(int? id) async {
    if (id != null) {
      await _dbHelper.deletePost(id);
      await fetchAllPosts(); // Refresh the list after deleting
    }
  }

  Future<void> searchPosts(String keyword) async {
    _posts = await _dbHelper.searchPosts(keyword);
    notifyListeners();
  }
}
