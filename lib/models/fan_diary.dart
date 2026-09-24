class FanDiary {
  final int? id;
  final String title;
  final String body;
  final String mood; // Joy, Nostalgia, Excited, Grateful
  final String biasMember;
  final DateTime createdAt;
  final bool isConcertMemory;

  FanDiary({
    this.id,
    required this.title,
    required this.body,
    required this.mood,
    required this.biasMember,
    required this.createdAt,
    this.isConcertMemory = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'mood': mood,
        'bias_member': biasMember,
        'created_at': createdAt.toIso8601String(),
        'is_concert_memory': isConcertMemory ? 1 : 0,
      };

  factory FanDiary.fromMap(Map<String, dynamic> map) => FanDiary(
        id: map['id'] as int?,
        title: map['title'] as String,
        body: map['body'] as String,
        mood: map['mood'] as String,
        biasMember: map['bias_member'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        isConcertMemory: (map['is_concert_memory'] as int? ?? 0) == 1,
      );

  FanDiary copyWith({
    int? id,
    String? title,
    String? body,
    String? mood,
    String? biasMember,
    DateTime? createdAt,
    bool? isConcertMemory,
  }) =>
      FanDiary(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
        mood: mood ?? this.mood,
        biasMember: biasMember ?? this.biasMember,
        createdAt: createdAt ?? this.createdAt,
        isConcertMemory: isConcertMemory ?? this.isConcertMemory,
      );
}
