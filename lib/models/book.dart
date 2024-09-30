import 'dart:io';
import 'package:flutter_local_library_app/models/reading_session.dart';

enum ReadingStatus { unread, inProgress, completed }

class Book {
  String id;
  String title;
  String author;
  final File file;
  String? coverPath;
  ReadingStatus status;
  double progress;
  List<String> tags;
  List<ReadingSession> readingSessions;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.file,
    this.coverPath,
    this.status = ReadingStatus.unread,
    this.progress = 0.0,
    List<String>? tags,
    List<ReadingSession>? readingSessions,
  }) :
        tags = tags ?? [],
        readingSessions = readingSessions ?? [];

  void updateMetadata({
    String? title,
    String? author,
    String? coverPath,
    ReadingStatus? status,
    double? progress,
    List<String>? tags,
  }) {
    if (title != null) this.title = title;
    if (author != null) this.author = author;
    if (coverPath != null) this.coverPath = coverPath;
    if (status != null) this.status = status;
    if (progress != null) this.progress = progress;
    if (tags != null) this.tags = tags;
  }

  void addReadingSession(ReadingSession session) {
    readingSessions.add(session);
  }

  void updateReadingSession(ReadingSession updatedSession) {
    int index = readingSessions.indexWhere((session) => session.id == updatedSession.id);
    if (index != -1) {
      readingSessions[index] = updatedSession;
    }
  }

  Duration get totalReadingTime {
    return readingSessions.fold(Duration.zero, (total, session) => total + session.duration);
  }
}