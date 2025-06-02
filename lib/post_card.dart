import 'package:flutter/material.dart';
import 'models/blog_post.dart';

class PostCard extends StatelessWidget {
  final BlogPost post;
  final VoidCallback onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(post.title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          post.content.length > 100
              ? '${post.content.substring(0, 100)}...'
              : post.content,
        ),
        trailing: Chip(label: Text(post.category)),
        onTap: onTap,
      ),
    );
  }
}
