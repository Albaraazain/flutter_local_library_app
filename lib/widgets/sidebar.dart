import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import 'book_list_item.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey[200],
      child: Consumer<StorageService>(
        builder: (context, storageService, child) {
          return ListView.builder(
            itemCount: storageService.books.length,
            itemBuilder: (context, index) {
              final book = storageService.books[index];
              return BookListItem(book: book);
            },
          );
        },
      ),
    );
  }
}