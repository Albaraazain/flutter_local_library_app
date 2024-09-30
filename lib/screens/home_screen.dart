import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../services/file_service.dart';
import '../widgets/sidebar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FileService _fileService = FileService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StorageService>(context, listen: false).loadBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final book = await _fileService.uploadBook();
              if (book != null) {
                Provider.of<StorageService>(context, listen: false).addBook(book);
              }
            },
          ),
        ],
      ),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Consumer<StorageService>(
              builder: (context, storageService, child) {
                if (storageService.books.isEmpty) {
                  return const Center(
                    child: Text('No books in your library. Add some books to get started!'),
                  );
                } else {
                  return const Center(
                    child: Text('Select a book from the sidebar to start reading.'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}