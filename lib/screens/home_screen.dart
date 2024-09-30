// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_library_app/models/book.dart';
import 'package:flutter_local_library_app/models/library_model.dart';
import 'package:flutter_local_library_app/screens/book_viewer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _openBookViewer(BuildContext context, Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookViewerScreen(book: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryModel>(
      builder: (context, libraryModel, child) {
        List<Book> readingNowBooks = libraryModel.books
            .where((book) => book.status == ReadingStatus.inProgress)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
          ),
          body: readingNowBooks.isEmpty
              ? Center(child: Text('No books currently being read.'))
              : ListView.builder(
            itemCount: readingNowBooks.length,
            itemBuilder: (context, index) {
              Book book = readingNowBooks[index];
              return ListTile(
                title: Text(book.title),
                subtitle: Text(book.author),
                onTap: () => _openBookViewer(context, book),
              );
            },
          ),
        );
      },
    );
  }
}
