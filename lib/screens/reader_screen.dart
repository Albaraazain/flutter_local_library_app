import 'dart:io';
import 'dart:math';
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

class _ReaderScreenState extends State<ReaderScreen> with SingleTickerProviderStateMixin {
  late PdfViewerController _pdfViewerController;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isControlsVisible = true;
  bool _isDocumentLoaded = false;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
      if (_isControlsVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            SfPdfViewer.file(
              File(widget.book.filePath),
              controller: _pdfViewerController,
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                setState(() {
                  _isDocumentLoaded = true;
                });
                _pdfViewerController.jumpToPage(max(1, widget.book.currentPage));
              },
              onPageChanged: (PdfPageChangedDetails details) {
                Provider.of<StorageService>(context, listen: false)
                    .updateBookProgress(widget.book.id, details.newPageNumber);
              },
              // pageLayoutMode: PdfPageLayoutMode.single,
              scrollDirection: PdfScrollDirection.vertical,
              // interactionMode: PdfInteractionMode.pan,
            ),
            if (_isDocumentLoaded) _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: child,
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildAppBar(),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: Colors.black.withOpacity(0.7),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              widget.book.title,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Page ${_pdfViewerController.pageNumber} of ${_pdfViewerController.pageCount}',
                style: TextStyle(color: Colors.white70),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.navigate_before, color: Colors.white),
                    onPressed: () => _pdfViewerController.previousPage(),
                  ),
                  IconButton(
                    icon: Icon(Icons.navigate_next, color: Colors.white),
                    onPressed: () => _pdfViewerController.nextPage(),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          if (_pdfViewerController.pageCount > 0)
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.grey[800],
                thumbColor: Colors.white,
                overlayColor: Colors.white.withOpacity(0.3),
              ),
              child: Slider(
                value: _pdfViewerController.pageNumber.toDouble(),
                min: 1,
                max: _pdfViewerController.pageCount.toDouble(),
                onChanged: (value) {
                  _pdfViewerController.jumpToPage(value.toInt());
                },
              ),
            ),
        ],
      ),
    );
  }
}