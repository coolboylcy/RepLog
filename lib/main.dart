import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/database_helper.dart';
import 'di/service_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final db = DatabaseHelper();
  await db.init();

  runApp(
    ServiceProvider(
      databaseHelper: db,
      child: const RepLogApp(),
    ),
  );
}
