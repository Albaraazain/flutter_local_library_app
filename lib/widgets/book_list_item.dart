import 'package:flutter/material.dart';
import '../models/book.dart';
import '../screens/reader_screen.dart';

class BookListItem extends StatelessWidget {
  final Book book;

  const BookListItem({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
    );
  }
}