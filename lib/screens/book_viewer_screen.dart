import 'package:flutter/material.dart';
import 'package:flutter_local_library_app/models/book.dart';
import 'package:flutter_local_library_app/models/reading_session.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookViewerScreen extends StatefulWidget {
  final Book book;
  final Function(Book) onBookUpdated;

  const BookViewerScreen({
    Key? key,
    required this.book,
    required this.onBookUpdated,
  }) : super(key: key);

  @override
  _BookViewerScreenState createState() => _BookViewerScreenState();
}

class _BookViewerScreenState extends State<BookViewerScreen> {
  late Book _book;
  ReadingSession? _currentSession;
  late SharedPreferences _prefs;
  late PdfViewerController _pdfViewerController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _pdfViewerController = PdfViewerController();
    _initializeViewer();
  }

  Future<void> _initializeViewer() async {
    await _initSharedPreferences();
    _startReadingSession();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    int lastPage = _prefs.getInt('lastPage_${_book.id}') ?? 1;
    _pdfViewerController.jumpToPage(lastPage);
  }

  void _startReadingSession() {
    _currentSession = ReadingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
    );
    _book.addReadingSession(_currentSession!);
  }

  void _endReadingSession() {
    if (_currentSession != null) {
      ReadingSession updatedSession = _currentSession!.copyWith(endTime: DateTime.now());
      _book.updateReadingSession(updatedSession);
      _currentSession = null;
    }
  }

  @override
  void dispose() {
    _endReadingSession();
    _saveLastPage();
    widget.onBookUpdated(_book);
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _saveLastPage() {
    _prefs.setInt('lastPage_${_book.id}', _pdfViewerController.pageNumber);
  }

  void _updateProgress() {
    setState(() {
      _book.progress = _pdfViewerController.pageNumber / _pdfViewerController.pageCount;
      widget.onBookUpdated(_book);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_book.title),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () {
              _pdfViewerController.jumpToPage(_pdfViewerController.pageNumber);
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SfPdfViewer.file(
        _book.file,
        controller: _pdfViewerController,
        onPageChanged: (PdfPageChangedDetails details) {
          setState(() {
            _saveLastPage();
            _updateProgress();
          });
        },
      ),
    );
  }
}