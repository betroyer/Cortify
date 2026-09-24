class CommunityPost {
  final int? id;
  final String author;
  final String content;
  final String language; // en, fil, ko, etc.
  final String? translatedContent;
  final DateTime createdAt;
  final int hearts;
  final bool isOfficial;
  final String board; // Feed, Projects, Announcements

  CommunityPost({
    this.id,
    required this.author,
    required this.content,
    this.language = 'en',
    this.translatedContent,
    required this.createdAt,
    this.hearts = 0,
    this.isOfficial = false,
    this.board = 'Feed',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'author': author,
        'content': content,
        'language': language,
        'translated_content': translatedContent,
        'created_at': createdAt.toIso8601String(),
        'hearts': hearts,
        'is_official': isOfficial ? 1 : 0,
        'board': board,
      };

  factory CommunityPost.fromMap(Map<String, dynamic> map) => CommunityPost(
        id: map['id'] as int?,
        author: map['author'] as String,
        content: map['content'] as String,
        language: map['language'] as String? ?? 'en',
        translatedContent: map['translated_content'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
        hearts: map['hearts'] as int? ?? 0,
        isOfficial: (map['is_official'] as int? ?? 0) == 1,
        board: map['board'] as String? ?? 'Feed',
      );

  CommunityPost copyWith({
    int? id,
    String? author,
    String? content,
    String? language,
    String? translatedContent,
    DateTime? createdAt,
    int? hearts,
    bool? isOfficial,
    String? board,
  }) =>
      CommunityPost(
        id: id ?? this.id,
        author: author ?? this.author,
        content: content ?? this.content,
        language: language ?? this.language,
        translatedContent: translatedContent ?? this.translatedContent,
        createdAt: createdAt ?? this.createdAt,
        hearts: hearts ?? this.hearts,
        isOfficial: isOfficial ?? this.isOfficial,
        board: board ?? this.board,
      );
}
