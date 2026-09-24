class Announcement {
  final int? id;
  final String title;
  final String body;
  final String category; // Official, Music, Tour, Merch
  final DateTime postedAt;
  final bool isPinned;

  Announcement({
    this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.postedAt,
    this.isPinned = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'category': category,
        'posted_at': postedAt.toIso8601String(),
        'is_pinned': isPinned ? 1 : 0,
      };

  factory Announcement.fromMap(Map<String, dynamic> map) => Announcement(
        id: map['id'] as int?,
        title: map['title'] as String,
        body: map['body'] as String,
        category: map['category'] as String,
        postedAt: DateTime.parse(map['posted_at'] as String),
        isPinned: (map['is_pinned'] as int) == 1,
      );
}
