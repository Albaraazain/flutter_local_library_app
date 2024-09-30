import 'package:flutter/material.dart';
import 'package:flutter_local_library_app/screens/home_screen.dart';

class LocalLibraryApp extends StatelessWidget {
  const LocalLibraryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Library',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}