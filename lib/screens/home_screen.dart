import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursetrack/models/blog_post.dart';
import 'package:coursetrack/providers/post_provider.dart';
import 'package:coursetrack/screens/add_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  final String _username = 'student1'; // Simulated current user

  @override
  void initState() {
    super.initState();
    // Load all posts when screen initializes
    // Capture the provider before the async gap
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    Future.microtask(() {
      postProvider.fetchAllPosts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        // Reset to show all posts
        Provider.of<PostProvider>(context, listen: false).fetchAllPosts();
      }
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      Provider.of<PostProvider>(context, listen: false).fetchAllPosts();
    } else {
      Provider.of<PostProvider>(context, listen: false).searchPosts(query);
    }
  }

  void _showMyPosts() {
    Provider.of<PostProvider>(context, listen: false).fetchUserPosts(_username);
  }

  void _showAllPosts() {
    Provider.of<PostProvider>(context, listen: false).fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search posts...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
                onChanged: _performSearch,
              )
            : const Text('University Blog'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'myPosts') {
                _showMyPosts();
              } else if (value == 'allPosts') {
                _showAllPosts();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'myPosts',
                child: Text('My Posts'),
              ),
              const PopupMenuItem(
                value: 'allPosts',
                child: Text('All Posts'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          final posts = postProvider.posts;
          
          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'No posts found. Create your first post!',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _buildPostCard(context, post);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPostScreen(username: _username),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, BlogPost post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${post.date.day}/${post.date.month}/${post.date.year}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (post.author == _username)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(context, post);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Post title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              post.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Post image
          if (post.imagePath != null && post.imagePath!.isNotEmpty) ...[  
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Image.file(
                File(post.imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ],
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, BlogPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<PostProvider>(context, listen: false)
                  .deletePost(post.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
