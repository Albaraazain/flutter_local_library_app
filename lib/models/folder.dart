import 'book.dart';

class Folder {
  String id;
  String name;
  List<String> bookIds;
  List<String> subFolderIds;
  String? parentId;

  Folder({
    required this.id,
    required this.name,
    this.bookIds = const [],
    this.subFolderIds = const [],
    this.parentId,
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'],
      name: json['name'],
      bookIds: List<String>.from(json['bookIds']),
      subFolderIds: List<String>.from(json['subFolderIds']),
      parentId: json['parentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bookIds': bookIds,
      'subFolderIds': subFolderIds,
      'parentId': parentId,
    };
  }
}