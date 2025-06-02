// ignore_for_file: use_build_context_synchronously

import 'package:coursetrack/confirmation_dialog.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../models/blog_post.dart';

class PostDetailScreen extends StatelessWidget {
  final BlogPost post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(post.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // DateFormat.yMMMd().format(post.date),
              // style: TextStyle(color: Colors.grey),
              post.date.toString(),
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            
            // Display image if available
            if (post.imageUrl.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: kIsWeb
                    ? Image.network(post.imageUrl, fit: BoxFit.cover)
                    : Image.file(File(post.imageUrl), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return Center(child: Text('Unable to load image', style: TextStyle(color: Colors.red)));
                      },
                  ),
                ),
              ),
            
            Text(post.content),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () => _deletePost(context),
        child: Icon(Icons.delete),
      ),
    );
  }

  void _deletePost(BuildContext context) async {
    await showDialog(
      context: context,
      builder:
          (ctx) => ConfirmationDialog(
            title: 'Delete Post',
            content: 'Are you sure you want to delete this post?',
            onConfirm: () async {
              try {
                // Delete the post
                await Provider.of<PostProvider>(
                  context,
                  listen: false,
                ).deletePost(post.id);
                
                // Close the dialog
                Navigator.pop(ctx);
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Post deleted successfully'))
                );
                
                // Navigate back to home page with clean navigation stack
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              } catch (e) {
                // Close the dialog
                Navigator.pop(ctx);
                
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting post: $e'))
                );
              }
            },
          ),
    );
  }
}
