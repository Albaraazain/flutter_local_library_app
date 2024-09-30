// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_library_app/models/library_model.dart';
import 'main_screen.dart';

class LocalLibraryApp extends StatelessWidget {
  const LocalLibraryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryModel>(
      builder: (context, libraryModel, child) {
        return MaterialApp(
          title: 'Local Library',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: libraryModel!.isDarkMode ? Brightness.dark : Brightness.light,
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
            cardTheme: CardTheme(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          home: const MainScreen(),
        );
      },
    );
  }
}
