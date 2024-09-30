import 'package:flutter/material.dart';
import '../models/book.dart';
import '../screens/reader_screen.dart';

class BookGrid extends StatelessWidget {
  final List<Book> books;

  const BookGrid({Key? key, required this.books}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return _buildBookCard(context, books[index]);
      },
    );
  }

  Widget _buildBookCard(BuildContext context, Book book) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[800]!, width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReaderScreen(book: book),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Icon(Icons.book, size: 64, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    book.author,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[400],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: book.currentPage / book.totalPages,
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${((book.currentPage / book.totalPages) * 100).toInt()}% Complete',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[400],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}