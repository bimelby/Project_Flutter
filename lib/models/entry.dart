class Entry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String mood;
  final String category;
  final DateTime date;
  final String? imageUrl;

  Entry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.mood,
    required this.category,
    required this.date,
    this.imageUrl,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      content: json['content'],
      mood: json['mood'],
      category: json['category'],
      date: DateTime.parse(json['date']),
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'mood': mood,
      'category': category,
      'date': date.toIso8601String(),
      'image_url': imageUrl,
    };
  }
}
