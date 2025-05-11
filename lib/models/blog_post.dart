class BlogPost {
  final int? id; // Make id nullable
  final String title; 
  final String content;
  final String author;
  final DateTime date;
  final String? imagePath;

  const BlogPost({
    this.id, // Allow id to be null
    required this.title,
    required this.content,
    required this.author,
    required this.date,
    this.imagePath,
  });

  /// This method is used to convert a BlogPost object to a map for DB storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id, // id can be null for new posts
      'title': title,
      'content': content,
      'author': author,
      'date': date.toIso8601String(),
      'imagePath': imagePath, // Ensure this matches the database column name
    };
  }

  /// This method is used to convert a map (in DB) to a BlogPost object.
  factory BlogPost.fromMap(Map<String, dynamic> map) {
    return BlogPost(
      id: map['id'], 
      title: map['title'],
      content: map['content'],
      author: map['author'],
      date: DateTime.parse(map['date']),  
      imagePath: map['imagePath'], // Ensure this matches the database column name
    );
  }
}