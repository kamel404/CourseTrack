import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/post_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Blog Categories',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            title: Text('All Posts'),
            onTap: () {
              Provider.of<PostProvider>(
                context,
                listen: false,
              ).setCategory('All');
              Navigator.pop(context);
            },
          ),
          Divider(),
          ...['Technology', 'Science', 'Art', 'Travel', 'Food'].map((category) {
            return ListTile(
              title: Text(category),
              onTap: () {
                Provider.of<PostProvider>(
                  context,
                  listen: false,
                ).setCategory(category);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
}
