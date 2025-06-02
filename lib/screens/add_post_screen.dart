// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/post_provider.dart';
import '../models/blog_post.dart';
import 'package:coursetrack/confirmation_dialog.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'Technology';
  String _imageUrl = '';
  XFile? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  
  final List<String> _categories = [
    'Technology',
    'Science',
    'Art',
    'Travel',
    'Food',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Content'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items:
                    _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              
              // Image Selection Section
              Text('Add an Image (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              
              // Show selected image preview
              if (_selectedImage != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: kIsWeb 
                    ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                    : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                ),
              
              SizedBox(height: 10),
              
              // Image picker buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icon(Icons.photo_library),
                    label: Text('Gallery'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: Icon(Icons.camera_alt),
                    label: Text('Camera'),
                  ),
                  if (_selectedImage != null)
                    ElevatedButton.icon(
                      onPressed: _clearSelectedImage,
                      icon: Icon(Icons.delete),
                      label: Text('Remove'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                ],
              ),
              
              SizedBox(height: 20),
              ElevatedButton(onPressed: _submitForm, child: Text('Save Post')),
            ],
          ),
        ),
      ),
    );
  }

  // Method to pick an image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80, // Reduce image quality to save storage
      );
      
      if (pickedImage != null) {
        setState(() {
          _selectedImage = pickedImage;
          _imageUrl = pickedImage.path; // Store the path for database
        });
        print('Image selected: ${pickedImage.path}');
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
  
  // Method to clear the selected image
  void _clearSelectedImage() {
    setState(() {
      _selectedImage = null;
      _imageUrl = '';
    });
  }
  
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newPost = BlogPost(
        id: Uuid().v4(),
        title: _titleController.text,
        content: _contentController.text,
        category: _selectedCategory,
        date: DateTime.now(),
        imageUrl: _imageUrl, // Include the image URL if an image was selected
      );

      await showDialog(
        context: context,
        builder: (ctx) => ConfirmationDialog(
          title: 'Confirm',
          content: 'Are you sure you want to add this post?',
          onConfirm: () async {
            try {
              // First add the post
              await Provider.of<PostProvider>(
                context,
                listen: false,
              ).addPost(newPost);
              
              // Print to debug
              print('Post added successfully: ${newPost.title}');
              
              // Close the dialog
              Navigator.pop(ctx);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Post added successfully!')),
              );
              
              // Explicitly reload posts
              final provider = Provider.of<PostProvider>(context, listen: false);
              await provider.loadPosts();
              print('Posts reloaded, count: ${provider.posts.length}');
              
              // Use a more direct navigation approach
              if (mounted) {
                // Instead of just popping, replace the current screen with the HomeScreen
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            } catch (e) {
              print('Error adding post: $e');
              // Close the dialog
              Navigator.pop(ctx);
              
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error adding post: $e')),
              );
            }
          },
        ),
      );
    }
  }
}
