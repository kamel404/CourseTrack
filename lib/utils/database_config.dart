import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Initialize the appropriate database factory based on platform
void initializeDatabaseFactory() {
  if (!kIsWeb) {
    // Don't initialize SQLite for web
    try {
      // Initialize FFI
      sqfliteFfiInit();
      // This is the critical line mentioned in the error message
      databaseFactory = databaseFactoryFfi;
      print('Successfully initialized SQLite with FFI for desktop/mobile');
    } catch (e) {
      print('Error initializing SQLite: $e');
    }
  } else {
    print('Running in web environment - SQLite initialization skipped');
  }
}
