import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/post_provider.dart';
import 'data/db_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'utils/database_config.dart';

void main() async {
  // This must be the first line
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory before any database operations
  // This is crucial for resolving the error
  initializeDatabaseFactory();

  if (!kIsWeb) {
    try {
      // Pre-initialize the database for non-web platforms
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.database;
      print('Database successfully initialized');
    } catch (e) {
      print('Database initialization error: $e');
    }
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => PostProvider(),
      child: MaterialApp(
        title: 'Course Track',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(),
        },
        navigatorObservers: [NavigatorObserver()],
      ),
    );
  }
}
