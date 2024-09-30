import 'package:flutter/material.dart';
import 'package:flutter_local_library_app/models/book.dart';
import 'package:flutter_local_library_app/models/reading_session.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/library_model.dart';

class BookViewerScreen extends StatefulWidget {
  final Book book;

  const BookViewerScreen({
    Key? key,
    required this.book,
  }) : super(key: key);

  @override
  _BookViewerScreenState createState() => _BookViewerScreenState();
}

class _BookViewerScreenState extends State<BookViewerScreen> {
  late Book _book;
  ReadingSession? _currentSession;
  late SharedPreferences _prefs;
  late PdfViewerController _pdfViewerController;
  late LibraryModel _libraryModel;  // Store reference to LibraryModel
  bool _isLoading = true;
  PdfTextSearchResult _searchResult = PdfTextSearchResult();
  final TextEditingController _searchController = TextEditingController();

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch and store the LibraryModel here safely
    _libraryModel = Provider.of<LibraryModel>(context, listen: false);
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
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
    _pdfViewerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _saveLastPage() {
    _prefs.setInt('lastPage_${_book.id}', _pdfViewerController.pageNumber);
    _book.progress = _pdfViewerController.pageNumber / _pdfViewerController.pageCount;
    _book.status = ReadingStatus.inProgress;

    // Use the previously stored _libraryModel
    _libraryModel.updateBook(_book);
  }

  void _jumpToLastReadPage() {
    int lastPage = _prefs.getInt('lastPage_${_book.id}') ?? 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pdfViewerController.jumpToPage(lastPage);
    });
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Text'),
          content: TextField(
            controller: _searchController,
            decoration: InputDecoration(hintText: 'Enter search text'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _searchText(_searchController.text);
                Navigator.of(context).pop();
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _searchText(String searchText) {
    _searchResult = _pdfViewerController.searchText(searchText);
    _searchResult.addListener(() {
      if (_searchResult.hasResult) {
        setState(() {}); // Trigger UI update when search results are found
      }
    });
  }

  void _showBookDetails() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_book.title, style: Theme.of(context).textTheme.headlineSmall),
                Text(_book.author, style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 16),
                Text('Reading Progress: ${(_book.progress * 100).toStringAsFixed(1)}%'),
                LinearProgressIndicator(value: _book.progress),
                SizedBox(height: 16),
                Text('Total Reading Time: ${_book.totalReadingTime.inHours}h ${_book.totalReadingTime.inMinutes % 60}m'),
                SizedBox(height: 16),
                Text('Tags:', style: Theme.of(context).textTheme.titleMedium),
                Wrap(
                  spacing: 8,
                  children: _book.tags.map((tag) => Chip(label: Text(tag))).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_book.title),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showBookDetails,
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          if (_searchResult.hasResult)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchResult.clear();
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          SfPdfViewer.file(
            _book.file!,
            controller: _pdfViewerController,
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              _jumpToLastReadPage();
            },
            onPageChanged: (PdfPageChangedDetails details) {
              _saveLastPage();
            },
            enableDoubleTapZooming: true,
            canShowScrollStatus: true,
            canShowPaginationDialog: true,
            pageSpacing: 0,
            pageLayoutMode: PdfPageLayoutMode.continuous,
          ),
          if (_searchResult.hasResult)
            Positioned(
              bottom: 16,
              right: 16,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _searchResult.previousInstance();
                    },
                    child: Icon(Icons.arrow_upward),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _searchResult.nextInstance();
                    },
                    child: Icon(Icons.arrow_downward),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.first_page),
              onPressed: () => _pdfViewerController.firstPage(),
            ),
            IconButton(
              icon: Icon(Icons.navigate_before),
              onPressed: () => _pdfViewerController.previousPage(),
            ),
            Text('${_pdfViewerController.pageNumber} / ${_pdfViewerController.pageCount}'),
            IconButton(
              icon: Icon(Icons.navigate_next),
              onPressed: () => _pdfViewerController.nextPage(),
            ),
            IconButton(
              icon: Icon(Icons.last_page),
              onPressed: () => _pdfViewerController.lastPage(),
            ),
          ],
        ),
      ),
    );
  }
}
