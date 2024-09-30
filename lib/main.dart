import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StorageService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Library',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.grey[800]!,
          surface: Colors.grey[900]!,
          background: Colors.black,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        textTheme: GoogleFonts.robotoTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey[800],
          thickness: 1,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: Colors.grey[900],
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}