import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:stockzen/Attendance.dart';
import 'package:stockzen/Employees.dart';
import 'package:stockzen/Records.dart';
import 'package:stockzen/rec.dart';
import 'package:stockzen/sales.dart';
import 'package:stockzen/Products.dart';
import 'package:stockzen/sqllite.dart';
import 'package:stockzen/webpick.dart';
import 'package:path/path.dart';
import 'dart:io';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbHelper = DatabaseHelper();
    await dbHelper.database;

    runApp(MyApp());
  } catch (e) {
    // Log errors to a file
    final logFile = File('error_log.txt');
    await logFile.writeAsString('Error: $e');
  }
}class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Sales(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // Define your light theme
      darkTheme: ThemeData.dark(), // Define your dark theme
      themeMode: ThemeMode.system, // Use system theme mode
      routes: {
        'sales': (context) => Sales(),
        'records': (context) => record(),
        'product': (context) => product(),
        'employee': (context) => employe(),
        'attend': (context) => Attendanc(),
      },
    );
  }
}
