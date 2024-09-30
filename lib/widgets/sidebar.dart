import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import 'book_list_item.dart';
import 'folder_list_item.dart';
import '../models/folder.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey[200],
      child: Consumer<StorageService>(
        builder: (context, storageService, child) {
          return Column(
            children: [
              _buildAllBooksSection(context, storageService),
              Divider(),
              Expanded(
                child: ListView(
                  children: [
                    ...storageService.rootFolders.map(
                          (folder) => FolderListItem(folder: folder),
                    ),
                  ],
                ),
              ),
              Divider(),
              _buildCurrentFolderBooks(context, storageService),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllBooksSection(BuildContext context, StorageService storageService) {
    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        return ListTile(
          leading: Icon(Icons.library_books),
          title: Text('All Books'),
          onTap: () => storageService.setCurrentFolder(null),
          selected: storageService.currentFolder == null,
        );
      },
      onWillAccept: (data) => data != null,
      onAccept: (bookId) {
        final currentFolder = storageService.currentFolder;
        if (currentFolder != null) {
          storageService.moveBook(bookId, currentFolder.id, null);
        }
      },
    );
  }

  Widget _buildCurrentFolderBooks(BuildContext context, StorageService storageService) {
    final books = storageService.getBooksInFolder(storageService.currentFolder);

    return Expanded(
      child: ListView(
        children: books.map((book) => BookListItem(book: book)).toList(),
      ),
    );
  }
}