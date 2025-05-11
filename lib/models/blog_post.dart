
class BlogPost {
  final int id;
  final String title; 
  final String content;
  final String author;
  final DateTime date;
  final String? imagePath;

  const BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.date,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'date': date.toIso8601String(),
      'imageUrl': imagePath,
    };
  }

  factory BlogPost.fromMap(Map<String, dynamic> map) {
    return BlogPost(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      author: map['author'],
      date: DateTime.parse(map['date']),  
      imagePath: map['imageUrl'],
    );
  }
}