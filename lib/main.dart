import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_library_app/models/library_model.dart';
import 'package:flutter_local_library_app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => LibraryModel(),
      child: const LocalLibraryApp(),
    ),
  );
}
