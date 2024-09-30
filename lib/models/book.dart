
class Book {
  final String id;
  final String title;
  final String author;
  final String filePath;
  int currentPage;
  final int totalPages;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.filePath,
    this.currentPage = 0,
    required this.totalPages,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      filePath: json['filePath'],
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'filePath': filePath,
      'currentPage': currentPage,
      'totalPages': totalPages,
    };
  }
}