class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory Post.fromMap(Map<dynamic, dynamic> map) => Post(
        id: map['id'] as int,
        userId: (map['userId'] ?? 0) as int,
        title: (map['title'] ?? '') as String,
        body: (map['body'] ?? '') as String,
      );

  /// Plain map so it can be stored directly in a Hive box.
  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
      };

  /// "sunt aut facere" -> "Sunt aut facere"
  String get prettyTitle =>
      title.isEmpty ? title : title[0].toUpperCase() + title.substring(1);

  String get prettyBody =>
      body.isEmpty ? body : body[0].toUpperCase() + body.substring(1);
}
