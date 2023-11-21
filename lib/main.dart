import 'package:allen12/themes.dart';
import 'package:flutter/material.dart';
import 'package:allen12/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Allen',
      theme: ThemeData.light(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: Themes.whiteColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Themes.whiteColor,
        ),
      ),
      home: const Homepage(),
    );
  }
}
