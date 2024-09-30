import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
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
  late Animation<double> _fadeAnimation;
  bool _isControlsVisible = true;
  bool _isDocumentLoaded = false;
  bool _isYellowOverlayEnabled = true;
  double _currentZoomLevel = 1.0;
  static const double _minZoomLevel = 1.0;
  static const double _maxZoomLevel = 3.0;
  static const double _zoomStep = 0.25;
  final FocusNode _pdfFocusNode = FocusNode();
  GlobalKey _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.value = 1.0; // Start with visible controls
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    _animationController.dispose();
    _pdfFocusNode.dispose();
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

  void _toggleYellowOverlay() {
    setState(() {
      _isYellowOverlayEnabled = !_isYellowOverlayEnabled;
    });
  }

  void _zoomIn() {
    setState(() {
      _currentZoomLevel = min(_currentZoomLevel + _zoomStep, _maxZoomLevel);
      _pdfViewerController.zoomLevel = _currentZoomLevel;
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoomLevel = max(_currentZoomLevel - _zoomStep, _minZoomLevel);
      _pdfViewerController.zoomLevel = _currentZoomLevel;
    });
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.isControlPressed) {
        if (event.logicalKey == LogicalKeyboardKey.equal ||
            event.logicalKey == LogicalKeyboardKey.add) {
          _zoomIn();
        } else if (event.logicalKey == LogicalKeyboardKey.minus) {
          _zoomOut();
        }
      }
    }
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      if (RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.controlLeft) ||
          RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.controlRight)) {
        if (event.scrollDelta.dy < 0) {
          _zoomIn();
        } else if (event.scrollDelta.dy > 0) {
          _zoomOut();
        }
      } else {
        // Handle normal scrolling here if needed
        // For example, you might want to scroll the PDF viewer
        // _pdfViewerController.scrollTo(...)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: _pdfFocusNode,
        onKey: _handleKeyPress,
        autofocus: true,
        child: Listener(
          onPointerSignal: _handlePointerSignal,
          child: Stack(
            children: [
              GestureDetector(
                onTap: _toggleControls,
                child: SfPdfViewer.file(
                  File(widget.book.filePath),
                  key: _pdfViewerKey,
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
                  onZoomLevelChanged: (PdfZoomDetails details) {
                    setState(() {
                      _currentZoomLevel = details.newZoomLevel;
                    });
                  },
                  enableDoubleTapZooming: true,
                  canShowScrollHead: true,
                  canShowScrollStatus: true,
                  pageLayoutMode: PdfPageLayoutMode.continuous,
                  scrollDirection: PdfScrollDirection.vertical,
                  enableTextSelection: true,
                  interactionMode: PdfInteractionMode.selection,
                ),
              ),
              if (_isYellowOverlayEnabled && _isDocumentLoaded)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: YellowOverlayPainter(_pdfViewerKey, _currentZoomLevel),
                    ),
                  ),
                ),
              if (_isDocumentLoaded) _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildAppBar(),
          Spacer(),
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
          IconButton(
            icon: Icon(Icons.zoom_in, color: Colors.white),
            onPressed: _zoomIn,
          ),
          IconButton(
            icon: Icon(Icons.zoom_out, color: Colors.white),
            onPressed: _zoomOut,
          ),
          IconButton(
            icon: Icon(
              _isYellowOverlayEnabled ? Icons.wb_sunny : Icons.wb_sunny_outlined,
              color: Colors.white,
            ),
            onPressed: _toggleYellowOverlay,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page ${_pdfViewerController.pageNumber} of ${_pdfViewerController.pageCount}',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            'Zoom: ${(_currentZoomLevel * 100).toInt()}%',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}


class YellowOverlayPainter extends CustomPainter {
  final GlobalKey pdfViewerKey;
  final double zoomLevel;

  YellowOverlayPainter(this.pdfViewerKey, this.zoomLevel);

  @override
  void paint(Canvas canvas, Size size) {
    final RenderBox? renderBox = pdfViewerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size pdfSize = renderBox.size;

    final paint = Paint()
      ..color = Color(0x56F1DD57)  // Semi-transparent yellow
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.multiply;  // Use multiply blend mode

    canvas.drawRect(Rect.fromLTWH(
      position.dx,
      position.dy,
      pdfSize.width,
      pdfSize.height,
    ), paint);
  }

  @override
  bool shouldRepaint(covariant YellowOverlayPainter oldDelegate) {
    return oldDelegate.zoomLevel != zoomLevel;
  }
}