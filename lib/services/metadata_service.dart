import 'dart:io';
import 'package:epub_view/epub_view.dart';
import 'package:flutter_local_library_app/models/book.dart';

class MetadataService {
  Future<Book> extractMetadata(File file) async {
    String fileName = file.path.split('/').last;
    String title = fileName.split('.').first;
    String author = 'Unknown Author';

    if (file.path.toLowerCase().endsWith('.epub')) {
      try {
        final epubBook = await EpubReader.readBook(file.readAsBytesSync());
        title = epubBook.Title ?? title;
        author = epubBook.Author ?? author;
      } catch (e) {
        print('Error extracting EPUB metadata: $e');
      }
    }

    return Book(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      author: author,
      file: file,
    );
  }
}
