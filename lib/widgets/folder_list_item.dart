import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/folder.dart';
import '../services/storage_service.dart';
import 'folder_dialog.dart';

class FolderListItem extends StatefulWidget {
  final Folder folder;
  final int depth;

  const FolderListItem({Key? key, required this.folder, this.depth = 0}) : super(key: key);

  @override
  _FolderListItemState createState() => _FolderListItemState();
}

class _FolderListItemState extends State<FolderListItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final storageService = Provider.of<StorageService>(context, listen: false);
    final theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          onTap: () {
            storageService.setCurrentFolder(widget.folder);
            _handleTap();
          },
          child: Padding(
            padding: EdgeInsets.only(left: 16.0 * widget.depth),
            child: ListTile(
              leading: SizedBox(
                width: 24,
                height: 24,
                child: RotationTransition(
                  turns: _iconTurns,
                  child: Icon(
                    Icons.folder,
                    color: Colors.white,
                  ),
                ),
              ),
              title: Text(
                widget.folder.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              selected: storageService.currentFolder?.id == widget.folder.id,
              selectedTileColor: Colors.white.withOpacity(0.1),
              trailing: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  switch (value) {
                    case 'rename':
                      _showRenameDialog(context);
                      break;
                    case 'delete':
                      _showDeleteDialog(context);
                      break;
                    case 'add_subfolder':
                      _showCreateSubfolderDialog(context);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'rename',
                    child: Text('Rename', style: TextStyle(color: Colors.white)),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.white)),
                  ),
                  PopupMenuItem<String>(
                    value: 'add_subfolder',
                    child: Text('Add Subfolder', style: TextStyle(color: Colors.white)),
                  ),
                ],
                color: Colors.grey[850],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(height: 0),
          secondChild: Column(
            children: storageService.getSubfolders(widget.folder).map(
                  (subfolder) => FolderListItem(folder: subfolder, depth: widget.depth + 1),
            ).toList(),
          ),
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: Duration(milliseconds: 200),
        ),
      ],
    );
  }

  void _showRenameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FolderDialog(
          initialName: widget.folder.name,
          onSave: (newName) {
            final updatedFolder = Folder(
              id: widget.folder.id,
              name: newName,
              bookIds: widget.folder.bookIds,
              subFolderIds: widget.folder.subFolderIds,
              parentId: widget.folder.parentId,
            );
            Provider.of<StorageService>(context, listen: false).updateFolder(updatedFolder);
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Delete Folder', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to delete this folder and all its contents?',
              style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Provider.of<StorageService>(context, listen: false).removeFolder(widget.folder.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showCreateSubfolderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FolderDialog(
          onSave: (name) {
            final newFolder = Folder(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: name,
              parentId: widget.folder.id,
            );
            Provider.of<StorageService>(context, listen: false).addFolder(newFolder);
          },
        );
      },
    );
  }
}