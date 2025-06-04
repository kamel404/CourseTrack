// ignore_for_file: use_build_context_synchronously

import 'package:coursetrack/confirmation_dialog.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../models/blog_post.dart';
import 'package:intl/intl.dart';
import 'edit_post_screen.dart';

class PostDetailScreen extends StatelessWidget {
  final BlogPost post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          post.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor:
            post.imageUrl.isNotEmpty ? Colors.transparent : colorScheme.primary,
        foregroundColor:
            post.imageUrl.isNotEmpty ? Colors.white : colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Navigate to edit post screen and wait for the result
              final updatedPost = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPostScreen(post: post),
                ),
              );

              // If we got back an updated post, refresh this screen
              if (updatedPost != null && updatedPost is BlogPost) {
                // Replace the current route with the updated post
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailScreen(post: updatedPost),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First section - either image or colored header
            if (post.imageUrl.isNotEmpty)
              // Enhanced image section with overlay
              GestureDetector(
                onTap: () => _showFullScreenImage(context, post.imageUrl),
                child: SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // The image
                      kIsWeb
                          ? Image.network(post.imageUrl, fit: BoxFit.cover)
                          : Image.file(
                            File(post.imageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: colorScheme.primary,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported_outlined,
                                        color: colorScheme.onPrimary,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Image not available',
                                        style: TextStyle(
                                          color: colorScheme.onPrimary,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      // Gradient overlay for better text visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black,
                              Colors.transparent,
                              Colors.black,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                      // Category chip and date
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category chip
                            Chip(
                              label: Text(
                                post.category,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: colorScheme.primary.withValues(
                                alpha: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Date with icon
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat.yMMMd().format(post.date),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Colored header when no image
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                color: colorScheme.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category chip
                    Chip(
                      label: Text(
                        post.category,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                    const SizedBox(height: 8),
                    // Date with icon
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: colorScheme.onPrimary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat.yMMMd().format(post.date),
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Content Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    post.imageUrl.isNotEmpty
                        ? const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        )
                        : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              // Using transform instead of negative margin
              transform:
                  post.imageUrl.isNotEmpty
                      ? Matrix4.translationValues(0, -16, 0)
                      : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Only show title again if no image (as it's already in AppBar)
                  if (!post.imageUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        post.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),

                  // Post content
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      post.content,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.7,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Share and bookmark buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Share feature coming soon'),
                            ),
                          );
                        },
                        icon: Icon(Icons.share, color: colorScheme.primary),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bookmark feature coming soon'),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.bookmark_border,
                          color: colorScheme.primary,
                        ),
                        label: const Text('Bookmark'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 2,
        onPressed: () => _deletePost(context),
        child: const Icon(Icons.delete),
      ),
    );
  }

  // Show full screen image dialog
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Image container
                InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4,
                  child:
                      kIsWeb
                          ? Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            height: MediaQuery.of(context).size.height,
                          )
                          : Image.file(
                            File(imageUrl),
                            fit: BoxFit.contain,
                            height: MediaQuery.of(context).size.height,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Theme.of(context).colorScheme.error,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported_outlined,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onError,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Image not available',
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onError,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
                // Close button
                Positioned(
                  top: 10,
                  right: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
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
                  SnackBar(content: Text('Post deleted successfully')),
                );

                // Navigate back to home page with clean navigation stack
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/home', (route) => false);
              } catch (e) {
                // Close the dialog
                Navigator.pop(ctx);

                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting post: $e')),
                );
              }
            },
          ),
    );
  }
}
