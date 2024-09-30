import 'package:flutter/material.dart';
import '../models/book.dart';
import '../screens/reader_screen.dart';

class BookListItem extends StatelessWidget {
  final Book book;

  const BookListItem({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: book.id,
      feedback: Material(
        elevation: 4.0,
        child: Container(
          padding: EdgeInsets.all(8.0),
          color: Colors.grey[200],
          child: Text(book.title, style: TextStyle(fontSize: 16.0)),
        ),
      ),
      childWhenDragging: _buildBookTile(context, opacity: 0.5),
      child: _buildBookTile(context),
    );
  }

  Widget _buildBookTile(BuildContext context, {double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: ListTile(
        title: Text(book.title),
        subtitle: Text(book.author),
        trailing: Text('${book.currentPage}/${book.totalPages}'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReaderScreen(book: book),
            ),
          );
        },
      ),
    );
  }
}