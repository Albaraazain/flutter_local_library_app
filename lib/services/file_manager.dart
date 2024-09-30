import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_local_library_app/models/book.dart';
import 'package:flutter_local_library_app/services/metadata_service.dart';

class FileManager {
  final MetadataService _metadataService = MetadataService();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, 'LocalLibrary');
  }

  Future<Book> importFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub', 'pdf'],
    );

    if (result != null) {
      String sourcePath = result.files.single.path!;
      String fileName = path.basename(sourcePath);
      String destinationPath = path.join(await _localPath, fileName);

      File sourceFile = File(sourcePath);
      File destinationFile = await sourceFile.copy(destinationPath);

      return await _metadataService.extractMetadata(destinationFile);
    } else {
      throw Exception('No file selected');
    }
  }

  Future<List<Book>> getLibraryBooks() async {
    String libraryPath = await _localPath;
    Directory libraryDir = Directory(libraryPath);

    if (!await libraryDir.exists()) {
      await libraryDir.create(recursive: true);
    }

    List<FileSystemEntity> entities = await libraryDir.list().toList();
    List<Book> books = [];

    for (var entity in entities) {
      if (entity is File && (entity.path.endsWith('.epub') || entity.path.endsWith('.pdf'))) {
        books.add(await _metadataService.extractMetadata(entity));
      }
    }

    return books;
  }
}