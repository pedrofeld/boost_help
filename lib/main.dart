import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'pages/Login_page.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MaterialApp(home: Login()));
}
