import 'dart:io';
import 'package:epub_view/epub_view.dart';
import 'package:flutter_local_library_app/models/book.dart';
import 'package:path/path.dart' as path;


class MetadataService {
  Future<Book> extractMetadata(File file) async {
    String fileName = path.basename(file.path);
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

    // Use the file path as id
    String id = file.path;

    return Book(
      id: id,
      title: title,
      author: author,
      file: file,
    );
  }

}
