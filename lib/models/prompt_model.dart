// models/prompt_model.dart
class Prompt {
  String id;
  String title;
  String content;
  String authorId;
  String authorName;
  List<String> tags;
  String createdAt;
  String updatedAt;

  Prompt({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      id: json['_id'],
      title: json['title'],
      content: json['content'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      tags: List<String>.from(json['tags']),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}