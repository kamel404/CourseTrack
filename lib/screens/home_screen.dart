// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:coursetrack/screens/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import 'add_post_screen.dart';
import 'post_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Refresh posts when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPosts();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh posts when the app comes to the foreground
    if (state == AppLifecycleState.resumed) {
      _refreshPosts();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh posts when dependencies change
    _refreshPosts();
  }

  void _refreshPosts() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    // Force reload all posts from storage
    postProvider.loadPosts().then((_) {
      // Check if posts were loaded successfully
      // Force UI update if needed
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _performSearch(String query, PostProvider postProvider) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      postProvider.clearSearch();
    } else {
      setState(() {
        _isSearching = true;
      });
      postProvider.searchPostsByTitle(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen for changes in the PostProvider
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        // Debug print to verify posts are loaded

        return Scaffold(
          appBar: AppBar(
            title:
                _isSearching
                    ? TextField(
                      controller: _searchController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search posts...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      autofocus: true,
                      onChanged: (value) => _performSearch(value, postProvider),
                    )
                    : Text('MU Blog'),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      postProvider.clearSearch();
                    }
                  });
                },
              ),
            ],
          ),
          drawer: AppDrawer(),
          body: Column(
            children: [
              if (_isSearching)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Search Results (${postProvider.posts.length})',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              // If there are no posts, show a simple message
              if (postProvider.posts.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text('No posts yet', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Text(
                          'Add your first post with the + button',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // If we have posts, show them in a scrollable list
                Expanded(
                  child: ListView.builder(
                    itemCount: postProvider.posts.length,
                    itemBuilder: (context, index) {
                      final post = postProvider.posts[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PostDetailScreen(post: post),
                                ),
                              ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Show image if available
                              if (post.imageUrl.isNotEmpty)
                                SizedBox(
                                  height: 120,
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                    child:
                                        kIsWeb
                                            ? Image.network(
                                              post.imageUrl,
                                              fit: BoxFit.cover,
                                            )
                                            : Image.file(
                                              File(post.imageUrl),
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Container(
                                                  color: Colors.grey.shade200,
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                            ),
                                  ),
                                ),

                              Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            post.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Chip(
                                          label: Text(
                                            post.category,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      post.content.length > 100
                                          ? '${post.content.substring(0, 100)}...'
                                          : post.content,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              // Navigate to add post screen
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddPostScreen()),
              );

              // Force refresh posts when returning from add post screen
              setState(() {});
              _refreshPosts();
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}
