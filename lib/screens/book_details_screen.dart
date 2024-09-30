import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_library_app/models/book.dart';
import 'package:flutter_local_library_app/models/reading_session.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_local_library_app/screens/book_viewer_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BookDetailsScreen extends StatefulWidget {
  final Book book;
  final Function(Book) onBookUpdated;

  const BookDetailsScreen({
    Key? key,
    required this.book,
    required this.onBookUpdated,
  }) : super(key: key);

  @override
  _BookDetailsScreenState createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  late Book _book;
  int _lastPage = 1;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _loadLastPage();
  }

  Future<void> _loadLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastPage = prefs.getInt('lastPage_${_book.id}') ?? 1;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_book.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_book.coverPath != null)
              Center(
                child: Image.file(
                  File(_book.coverPath!),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
            else
              Center(
                child: Icon(Icons.book, size: 200),
              ),
            SizedBox(height: 16),
            Text('Title: ${_book.title}', style: Theme.of(context).textTheme.titleLarge),
            Text('Author: ${_book.author}', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            Text('Reading Status: ${_book.status.toString().split('.').last}'),
            LinearProgressIndicator(value: _book.progress),
            Text('Progress: ${(_book.progress * 100).toStringAsFixed(1)}%'),
            SizedBox(height: 16),
            Text('Tags:', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children: _book.tags.map((tag) => Chip(label: Text(tag))).toList(),
            ),
            SizedBox(height: 16),
            Text('File Path: ${_book.file.path}'),
            SizedBox(height: 16),
            Text('Total Reading Time: ${_book.totalReadingTime.inHours}h ${_book.totalReadingTime.inMinutes % 60}m'),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookViewerScreen(
                        book: _book,
                        onBookUpdated: (updatedBook) {
                          setState(() {
                            _book = updatedBook;
                            widget.onBookUpdated(_book);
                          });
                        },
                      ),
                    ),
                  );
                },
                child: Text('Read Book'),
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await OpenFile.open(_book.file.path);
                },
                child: Text('Open Book'),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _editMetadata(context);
                },
                child: Text('Edit Metadata'),
              ),
            ),
            SizedBox(height: 16),
            Text('Reading Sessions:', style: Theme.of(context).textTheme.titleMedium),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _book.readingSessions.length,
              itemBuilder: (context, index) {
                ReadingSession session = _book.readingSessions[index];
                return ListTile(
                  title: Text('Session ${index + 1}'),
                  subtitle: Text(
                      'Start: ${session.startTime}\n'
                          'End: ${session.endTime ?? 'Ongoing'}\n'
                          'Duration: ${session.duration.inHours}h ${session.duration.inMinutes % 60}m'
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editMetadata(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        String title = _book.title;
        String author = _book.author;
        ReadingStatus status = _book.status;
        double progress = _book.progress;
        List<String> tags = List<String>.from(_book.tags);
        TextEditingController tagsController = TextEditingController(
            text: tags.join(', ')
        );

        return AlertDialog(
          title: Text('Edit Book Metadata'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Title'),
                  onChanged: (value) => title = value,
                  controller: TextEditingController(text: _book.title),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Author'),
                  onChanged: (value) => author = value,
                  controller: TextEditingController(text: _book.author),
                ),
                DropdownButtonFormField<ReadingStatus>(
                  value: status,
                  onChanged: (ReadingStatus? newValue) {
                    if (newValue != null) {
                      status = newValue;
                    }
                  },
                  items: ReadingStatus.values.map((ReadingStatus status) {
                    return DropdownMenuItem<ReadingStatus>(
                      value: status,
                      child: Text(status.toString().split('.').last),
                    );
                  }).toList(),
                ),
                Slider(
                  value: progress,
                  onChanged: (double value) {
                    progress = value;
                  },
                  min: 0,
                  max: 1,
                  divisions: 100,
                  label: '${(progress * 100).round()}%',
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Tags (comma-separated)'),
                  controller: tagsController,
                  onChanged: (value) {
                    tags = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () => Navigator.of(context).pop({
                'title': title,
                'author': author,
                'status': status,
                'progress': progress,
                'tags': tags,
              }),
            ),
          ],
        );
      },
    );

    if (result != null) {
      _book.updateMetadata(
        title: result['title'],
        author: result['author'],
        status: result['status'],
        progress: result['progress'],
        tags: result['tags'],
      );
      widget.onBookUpdated(_book);
    }
  }
}