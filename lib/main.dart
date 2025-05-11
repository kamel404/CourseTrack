import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursetrack/providers/post_provider.dart';
import 'package:coursetrack/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PostProvider(),
      child: MaterialApp(
        title: 'University Blog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}


