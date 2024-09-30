// lib/screens/library_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_library_app/models/book.dart';
import 'package:flutter_local_library_app/models/library_model.dart';
import 'package:flutter_local_library_app/screens/book_viewer_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _isGridView = true;
  String _searchQuery = '';
  String _sortBy = 'title';
  bool _sortAscending = true;

  void _openBookViewer(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookViewerScreen(book: book),
      ),
    );
  }

  List<Book> _filterAndSortBooks(List<Book> books) {
    List<Book> displayedBooks = books.where((book) {
      return book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    displayedBooks.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'author':
          comparison = a.author.compareTo(b.author);
          break;
        case 'progress':
          comparison = a.progress.compareTo(b.progress);
          break;
        default:
          comparison = 0;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return displayedBooks;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryModel>(
      builder: (context, libraryModel, child) {
        List<Book> displayedBooks = _filterAndSortBooks(libraryModel.books);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Library'),
            actions: [
              IconButton(
                icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    if (value == _sortBy) {
                      _sortAscending = !_sortAscending;
                    } else {
                      _sortBy = value;
                      _sortAscending = true;
                    }
                  });
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'title',
                    child: Text('Sort by Title'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'author',
                    child: Text('Sort by Author'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'progress',
                    child: Text('Sort by Progress'),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search books',
                    suffixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: _isGridView
                    ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: displayedBooks.length,
                  itemBuilder: (context, index) {
                    return _buildBookGrid(displayedBooks[index]);
                  },
                )
                    : ListView.builder(
                  itemCount: displayedBooks.length,
                  itemBuilder: (context, index) {
                    return _buildBookItem(displayedBooks[index]);
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              try {
                await libraryModel.importBook();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to import book: ${e.toString()}')),
                );
              }
            },
            child: const Icon(Icons.add),
            tooltip: 'Import Book',
          ),
        );
      },
    );
  }

  Widget _buildBookItem(Book book) {
    return ListTile(
      leading: book.coverPath != null
          ? Image.file(File(book.coverPath!), width: 50, height: 75, fit: BoxFit.cover)
          : Icon(Icons.book, size: 50),
      title: Text(book.title),
      subtitle: Text(book.author),
      trailing: Text('${(book.progress * 100).toInt()}%'),
      onTap: () => _openBookViewer(book),
    );
  }

  Widget _buildBookGrid(Book book) {
    return GestureDetector(
      onTap: () => _openBookViewer(book),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: book.coverPath != null
                  ? Image.file(File(book.coverPath!), fit: BoxFit.cover)
                  : Container(
                color: Colors.grey[300],
                child: Icon(Icons.book, size: 50, color: Colors.grey[600]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  LinearProgressIndicator(value: book.progress),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
