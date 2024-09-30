import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_library_app/services/file_manager.dart';
import 'package:flutter_local_library_app/models/book.dart';
import 'package:flutter_local_library_app/screens/book_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FileManager _fileManager = FileManager();
  List<Book> _allBooks = [];
  List<Book> _displayedBooks = [];
  bool _isGridView = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    List<Book> books = await _fileManager.getLibraryBooks();
    setState(() {
      _allBooks = books;
      _displayedBooks = books;
    });
  }

  void _searchBooks(String query) {
    setState(() {
      _displayedBooks = _allBooks.where((book) {
        final titleLower = book.title.toLowerCase();
        final authorLower = book.author.toLowerCase();
        final tagsLower = book.tags.map((tag) => tag.toLowerCase()).toList();
        final searchLower = query.toLowerCase();
        return titleLower.contains(searchLower) ||
            authorLower.contains(searchLower) ||
            book.file.path.toLowerCase().contains(searchLower) ||
            tagsLower.any((tag) => tag.contains(searchLower));
      }).toList();
    });
  }

  Future<void> _importBook() async {
    try {
      Book book = await _fileManager.importFile();
      setState(() {
        _allBooks.add(book);
        _searchBooks(_searchController.text);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import book: ${e.toString()}')),
      );
    }
  }

  void _navigateToBookDetails(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsScreen(
          book: book,
          onBookUpdated: (updatedBook) {
            setState(() {
              int index = _allBooks.indexWhere((b) => b.id == updatedBook.id);
              if (index != -1) {
                _allBooks[index] = updatedBook;
                _searchBooks(_searchController.text);
              }
            });
          },
        ),
      ),
    );
  }


  Widget _buildBookItem(Book book) {
    return Card(
      child: ListTile(
        leading: book.coverPath != null
            ? Image.file(File(book.coverPath!))
            : Icon(Icons.book),
        title: Text(book.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.author),
            Text('Status: ${book.status.toString().split('.').last}'),
            LinearProgressIndicator(value: book.progress),
            Wrap(
              spacing: 4,
              children: book.tags.map((tag) => Chip(label: Text(tag))).toList(),
            ),
          ],
        ),
        onTap: () => _navigateToBookDetails(book),
      ),
    );
  }



  Widget _buildBookGrid(Book book) {
    return Card(
      child: InkWell(
        onTap: () => _navigateToBookDetails(book),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: book.coverPath != null
                  ? Image.file(File(book.coverPath!), fit: BoxFit.cover)
                  : Icon(Icons.book, size: 50),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: Theme.of(context).textTheme.titleMedium),
                  Text(book.author, style: Theme.of(context).textTheme.bodySmall),
                  Text('Status: ${book.status.toString().split('.').last}', style: Theme.of(context).textTheme.bodySmall),
                  LinearProgressIndicator(value: book.progress),
                  Wrap(
                    spacing: 4,
                    children: book.tags.map((tag) => Chip(label: Text(tag, style: Theme.of(context).textTheme.labelSmall))).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Library'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search books',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _searchBooks,
            ),
          ),
          Expanded(
            child: _isGridView
                ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.7,
              ),
              itemCount: _displayedBooks.length,
              itemBuilder: (context, index) {
                return _buildBookGrid(_displayedBooks[index]);
              },
            )
                : ListView.builder(
              itemCount: _displayedBooks.length,
              itemBuilder: (context, index) {
                return _buildBookItem(_displayedBooks[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _importBook,
        child: const Icon(Icons.add),
        tooltip: 'Import Book',
      ),
    );
  }
}