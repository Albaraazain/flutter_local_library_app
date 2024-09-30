import 'package:flutter/material.dart';
import 'package:flutter_local_library_app/models/book.dart';
import 'package:flutter_local_library_app/services/file_manager.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final FileManager _fileManager = FileManager();
  List<Book> _recommendedBooks = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendedBooks();
  }

  Future<void> _loadRecommendedBooks() async {
    // TODO: Implement a recommendation system or integrate with an API
    // For now, we'll use placeholder data
    setState(() {
      _recommendedBooks = [
        Book(
          id: '1',
          title: 'The Great Gatsby',
          author: 'F. Scott Fitzgerald',
          file: null,
        ),
        Book(
          id: '2',
          title: '1984',
          author: 'George Orwell',
          file: null,
        ),
        Book(
          id: '3',
          title: 'To Kill a Mockingbird',
          author: 'Harper Lee',
          file: null,
        ),
      ];
    });
  }

  Widget _buildRecommendedBookItem(Book book) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement book details or download functionality
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: book.coverPath != null
                  ? Image.asset(book.coverPath!, fit: BoxFit.cover)
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
        title: const Text('Discover'),
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Recommended Books',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    ),
    Expanded(
    child: GridView.builder(
    padding: const EdgeInsets.all(16.0),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: 0.7,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
    ),
      itemCount: _recommendedBooks.length,
      itemBuilder: (context, index) {
        return _buildRecommendedBookItem(_recommendedBooks[index]);
      },
    ),
    ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Import Books',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: _importBook,
                child: Text('Import from Device'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement online book store or catalog browsing
                },
                child: Text('Browse Online Catalog'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
          ],
      ),
    );
  }

  Future<void> _importBook() async {
    try {
      Book book = await _fileManager.importFile();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully imported: ${book.title}')),
      );
      // TODO: Update the app's global book list or use a state management solution
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import book: ${e.toString()}')),
      );
    }
  }
}