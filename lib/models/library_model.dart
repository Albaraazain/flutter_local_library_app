// lib/models/library_model.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_library_app/models/book.dart';
import 'package:flutter_local_library_app/services/file_manager.dart';

class LibraryModel extends ChangeNotifier {
  final FileManager _fileManager = FileManager();
  final List<Book> _books = [];
  bool _isDarkMode = false;

  List<Book> get books => List.unmodifiable(_books);
  bool get isDarkMode => _isDarkMode;

  LibraryModel() {
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    _books.clear();
    _books.addAll(await _fileManager.getLibraryBooks());
    notifyListeners();
  }

  Future<void> addBook(Book book) async {
    _books.add(book);
    notifyListeners();
  }

  Future<void> importBook() async {
    try {
      Book book = await _fileManager.importFile();
      await addBook(book);
    } catch (e) {
      rethrow;
    }
  }

  void updateBook(Book updatedBook) {
    int index = _books.indexWhere((book) => book.id == updatedBook.id);
    if (index != -1) {
      _books[index] = updatedBook;
      notifyListeners();
    }
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
