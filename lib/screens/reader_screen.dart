import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../models/book.dart';
import '../services/storage_service.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;

  const ReaderScreen({Key? key, required this.book}) : super(key: key);

  @override
  _ReaderScreenState createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late PdfViewerController _pdfViewerController;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pdfViewerController.jumpToPage(widget.book.currentPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
      ),
      body: SfPdfViewer.file(
        File(widget.book.filePath),
        controller: _pdfViewerController,
        onPageChanged: (PdfPageChangedDetails details) {
          Provider.of<StorageService>(context, listen: false)
              .updateBookProgress(widget.book.id, details.newPageNumber);
        },
      ),
    );
  }
}