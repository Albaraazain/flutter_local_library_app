import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class StorageService extends ChangeNotifier {
  List<Book> _books = [];
  List<Book> get books => _books;

  Future<void> loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? booksJson = prefs.getString('books');
    if (booksJson != null) {
      final List<dynamic> decodedBooks = jsonDecode(booksJson);
      _books = decodedBooks.map((bookJson) => Book.fromJson(bookJson)).toList();
      notifyListeners();
    }
  }

  Future<void> saveBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final String booksJson = jsonEncode(_books.map((book) => book.toJson()).toList());
    await prefs.setString('books', booksJson);
  }

  void addBook(Book book) {
    _books.add(book);
    saveBooks();
    notifyListeners();
  }

  void updateBookProgress(String bookId, int currentPage) {
    final bookIndex = _books.indexWhere((book) => book.id == bookId);
    if (bookIndex != -1) {
      _books[bookIndex].currentPage = currentPage;
      saveBooks();
      notifyListeners();
    }
  }

  void removeBook(String bookId) {
    _books.removeWhere((book) => book.id == bookId);
    saveBooks();
    notifyListeners();
  }
}