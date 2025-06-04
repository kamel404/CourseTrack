import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import 'package:coursetrack/post_card.dart';
import 'post_details_screen.dart';

class PostListScreen extends StatelessWidget {
  final bool isHomeView;

  const PostListScreen({super.key, this.isHomeView = false});

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final posts =
        isHomeView ? postProvider.posts.take(3).toList() : postProvider.posts;

    // Debug print to see what's happening with the posts
    if (posts.isNotEmpty) {}

    // If there are no posts, show a message
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No posts yet', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text(
              'Add your first post with the + button',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Otherwise show the list of posts
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (ctx, i) {
        // Get the post for this index
        final post = posts[i];

        try {
          return PostCard(
            post: post,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(post: post),
                  ),
                ),
          );
        } catch (e) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Error displaying post: $e'),
            ),
          );
        }
      },
    );
  }
}
