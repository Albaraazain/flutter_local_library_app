import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/folder.dart';
import '../services/storage_service.dart';
import 'folder_dialog.dart';
import 'folder_list_item.dart';

class AnimatedSidebar extends StatelessWidget {
  final Animation<double> animation;

  const AnimatedSidebar({Key? key, required this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: 250 * animation.value,
          color: Colors.grey[900],
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: _SidebarContent(),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<StorageService>(
      builder: (context, storageService, child) {
        return Column(
          children: [
            SizedBox(height: 60), // Match the app bar height
            _buildAllBooksSection(context, storageService),
            Divider(height: 1),
            Expanded(
              child: ListView(
                children: [
                  ...storageService.rootFolders.map(
                        (folder) => FolderListItem(folder: folder),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            _buildCreateFolderButton(context),
          ],
        );
      },
    );
  }

  Widget _buildAllBooksSection(BuildContext context, StorageService storageService) {
    return ListTile(
      leading: Icon(Icons.library_books, color: Colors.white),
      title: Text(
        'All Books',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      onTap: () => storageService.setCurrentFolder(null),
      selected: storageService.currentFolder == null,
      selectedTileColor: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildCreateFolderButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () => _showCreateFolderDialog(context),
        icon: Icon(Icons.create_new_folder, color: Colors.black),
        label: Text(
          'Create Folder',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          minimumSize: Size(double.infinity, 48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FolderDialog(
          onSave: (name) {
            final newFolder = Folder(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: name,
            );
            Provider.of<StorageService>(context, listen: false).addFolder(newFolder);
          },
        );
      },
    );
  }
}