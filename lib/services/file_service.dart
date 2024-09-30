import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/book.dart';

class FileService {
  Future<Book?> uploadBook() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      // Copy the file to the app's documents directory
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String filePath = '$appDocPath/$fileName';
      await file.copy(filePath);

      // Get total pages
      PdfDocument document = PdfDocument(inputBytes: await file.readAsBytes());
      int totalPages = document.pages.count;
      document.dispose();

      // Create a new Book object
      return Book(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: fileName.replaceAll('.pdf', ''),
        author: 'Unknown', // You might want to implement a way to input the author name
        filePath: filePath,
        totalPages: totalPages,
      );
    }

    return null;
  }

  Future<void> deleteBook(Book book) async {
    File file = File(book.filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}