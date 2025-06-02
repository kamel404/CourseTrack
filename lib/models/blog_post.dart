class BlogPost {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime date;
  final String imageUrl;

  BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.date,
    this.imageUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'date': date.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  factory BlogPost.fromMap(Map<String, dynamic> map) {
    return BlogPost(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      imageUrl: map['imageUrl'],
    );
  }
}
