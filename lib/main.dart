import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/post_provider.dart';
import 'data/db_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'utils/database_config.dart';
import 'screens/welcome_screen.dart';

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
        title: 'MU Blog',
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: Color(0xFF1976D2), // Blue
            secondary: Color(0xFFFFC107), // Yellow
            tertiary: Color(0xFFFFD54F), // Light Yellow
            onSecondary: Colors.black,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF1976D2),
            foregroundColor: Colors.white,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFFFC107),
            foregroundColor: Colors.black,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Color(0xFFFFC107),
            ),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => WelcomeScreen(),
          '/home': (context) => HomeScreen(),
        },
        navigatorObservers: [NavigatorObserver()],
      ),
    );
  }
}
