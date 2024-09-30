import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../services/file_service.dart';
import '../widgets/animated_sidebar.dart';
import '../widgets/folder_dialog.dart';
import '../models/folder.dart';
import '../widgets/book_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final FileService _fileService = FileService();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StorageService>(context, listen: false).loadData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AnimatedSidebar(animation: _animation),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Consumer<StorageService>(
                    builder: (context, storageService, child) {
                      final books = storageService.getBooksInFolder(storageService.currentFolder);
                      return books.isEmpty
                          ? _buildEmptyState()
                          : BookGrid(books: books);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _animation,
              color: Colors.white,
            ),
            onPressed: () {
              _animationController.isDismissed
                  ? _animationController.forward()
                  : _animationController.reverse();
            },
          ),
          SizedBox(width: 16),
          Text(
            'My Library',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books, size: 64, color: Colors.grey[700]),
          SizedBox(height: 16),
          Text(
            'Your library is empty',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[300]),
          ),
          SizedBox(height: 8),
          Text(
            'Add books to get started',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () async {
        final book = await _fileService.uploadBook();
        if (book != null) {
          Provider.of<StorageService>(context, listen: false).addBook(book);
        }
      },
      child: Icon(Icons.add, color: Colors.black),
      backgroundColor: Colors.white,
      tooltip: 'Add Book',
    );
  }
}