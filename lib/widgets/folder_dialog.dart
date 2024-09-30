import 'package:flutter/material.dart';

class FolderDialog extends StatefulWidget {
  final String? initialName;
  final Function(String) onSave;

  const FolderDialog({Key? key, this.initialName, required this.onSave}) : super(key: key);

  @override
  _FolderDialogState createState() => _FolderDialogState();
}

class _FolderDialogState extends State<FolderDialog> {
  late TextEditingController _controller;
  bool _isNameValid = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _isNameValid = widget.initialName?.isNotEmpty ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initialName == null ? 'Create Folder' : 'Rename Folder',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _controller,
              autofocus: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Folder Name',
                labelStyle: TextStyle(color: Colors.white70),
                errorText: _isNameValid ? null : 'Please enter a valid folder name',
                errorStyle: TextStyle(color: Colors.red[300]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _isNameValid = value.trim().isNotEmpty;
                });
              },
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.white70)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  child: Text('Save', style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isNameValid
                      ? () {
                    widget.onSave(_controller.text.trim());
                    Navigator.of(context).pop();
                  }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}