import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import '../models/folder.dart';

class StorageService extends ChangeNotifier {
  List<Book> _books = [];
  List<Book> get books => _books;

  List<Folder> _folders = [];
  List<Folder> get folders => _folders;

  Folder? _currentFolder;
  Folder? get currentFolder => _currentFolder;

  List<Folder> get rootFolders => _folders.where((folder) => folder.parentId == null).toList();

  void addFolder(Folder folder) {
    _folders.add(folder);
    if (folder.parentId != null) {
      final parentFolder = _folders.firstWhere((f) => f.id == folder.parentId);
      parentFolder.subFolderIds.add(folder.id);
    }
    saveData();
    notifyListeners();
  }

  void updateFolder(Folder updatedFolder) {
    final index = _folders.indexWhere((folder) => folder.id == updatedFolder.id);
    if (index != -1) {
      _folders[index] = updatedFolder;
      saveData();
      notifyListeners();
    }
  }

  void removeFolder(String folderId) {
    final folderToRemove = _folders.firstWhere((folder) => folder.id == folderId);

    // Remove this folder from its parent's subFolderIds
    if (folderToRemove.parentId != null) {
      final parentFolder = _folders.firstWhere((f) => f.id == folderToRemove.parentId);
      parentFolder.subFolderIds.remove(folderId);
    }

    // Recursively remove all subfolders
    _removeSubfoldersRecursively(folderId);

    // Remove the folder itself
    _folders.removeWhere((folder) => folder.id == folderId);

    saveData();
    notifyListeners();
  }

  void _removeSubfoldersRecursively(String folderId) {
    final subFolderIds = _folders.firstWhere((f) => f.id == folderId).subFolderIds;
    for (final subFolderId in subFolderIds) {
      _removeSubfoldersRecursively(subFolderId);
    }
    _folders.removeWhere((folder) => folder.id == folderId);
  }

  void setCurrentFolder(Folder? folder) {
    _currentFolder = folder;
    notifyListeners();
  }

  void moveBook(String bookId, String? sourceFolderId, String? destinationFolderId) {
    if (sourceFolderId != null) {
      final sourceFolder = _folders.firstWhere((folder) => folder.id == sourceFolderId);
      sourceFolder.bookIds.remove(bookId);
    }
    if (destinationFolderId != null) {
      final destinationFolder = _folders.firstWhere((folder) => folder.id == destinationFolderId);
      destinationFolder.bookIds.add(bookId);
    }
    saveData();
    notifyListeners();
  }

  List<Book> getBooksInFolder(Folder? folder) {
    if (folder == null) {
      return _books.where((book) => !_folders.any((f) => f.bookIds.contains(book.id))).toList();
    } else {
      return _books.where((book) => folder.bookIds.contains(book.id)).toList();
    }
  }

  List<Folder> getSubfolders(Folder? parentFolder) {
    if (parentFolder == null) {
      return rootFolders;
    } else {
      return _folders.where((folder) => parentFolder.subFolderIds.contains(folder.id)).toList();
    }
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load books
    final String? booksJson = prefs.getString('books');
    if (booksJson != null) {
      final List<dynamic> decodedBooks = jsonDecode(booksJson);
      _books = decodedBooks.map((bookJson) => Book.fromJson(bookJson)).toList();
    }

    // Load folders
    final String? foldersJson = prefs.getString('folders');
    if (foldersJson != null) {
      final List<dynamic> decodedFolders = jsonDecode(foldersJson);
      _folders = decodedFolders.map((folderJson) => Folder.fromJson(folderJson)).toList();
    }

    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    final String booksJson = jsonEncode(_books.map((book) => book.toJson()).toList());
    await prefs.setString('books', booksJson);

    final String foldersJson = jsonEncode(_folders.map((folder) => folder.toJson()).toList());
    await prefs.setString('folders', foldersJson);
  }

  void addBook(Book book) {
    _books.add(book);
    if (_currentFolder != null) {
      _currentFolder!.bookIds.add(book.id);
    }
    saveData();
    notifyListeners();
  }

  void updateBookProgress(String bookId, int currentPage) {
    final bookIndex = _books.indexWhere((book) => book.id == bookId);
    if (bookIndex != -1) {
      _books[bookIndex].currentPage = currentPage;
      saveData();
      notifyListeners();
    }
  }

  void removeBook(String bookId) {
    _books.removeWhere((book) => book.id == bookId);
    _folders.forEach((folder) => folder.bookIds.remove(bookId));
    saveData();
    notifyListeners();
  }
}