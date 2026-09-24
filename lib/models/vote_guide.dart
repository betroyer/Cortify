class VoteGuide {
  final int? id;
  final String title;
  final String platform;
  final String instructions;
  final String linkHint;
  final DateTime deadline;
  final int streamsLogged;
  final String badgeName;
  final bool badgeEarned;

  VoteGuide({
    this.id,
    required this.title,
    required this.platform,
    required this.instructions,
    required this.linkHint,
    required this.deadline,
    this.streamsLogged = 0,
    this.badgeName = '',
    this.badgeEarned = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'platform': platform,
        'instructions': instructions,
        'link_hint': linkHint,
        'deadline': deadline.toIso8601String(),
        'streams_logged': streamsLogged,
        'badge_name': badgeName,
        'badge_earned': badgeEarned ? 1 : 0,
      };

  factory VoteGuide.fromMap(Map<String, dynamic> map) => VoteGuide(
        id: map['id'] as int?,
        title: map['title'] as String,
        platform: map['platform'] as String,
        instructions: map['instructions'] as String,
        linkHint: map['link_hint'] as String,
        deadline: DateTime.parse(map['deadline'] as String),
        streamsLogged: map['streams_logged'] as int? ?? 0,
        badgeName: map['badge_name'] as String? ?? '',
        badgeEarned: (map['badge_earned'] as int? ?? 0) == 1,
      );

  VoteGuide copyWith({
    int? id,
    String? title,
    String? platform,
    String? instructions,
    String? linkHint,
    DateTime? deadline,
    int? streamsLogged,
    String? badgeName,
    bool? badgeEarned,
  }) =>
      VoteGuide(
        id: id ?? this.id,
        title: title ?? this.title,
        platform: platform ?? this.platform,
        instructions: instructions ?? this.instructions,
        linkHint: linkHint ?? this.linkHint,
        deadline: deadline ?? this.deadline,
        streamsLogged: streamsLogged ?? this.streamsLogged,
        badgeName: badgeName ?? this.badgeName,
        badgeEarned: badgeEarned ?? this.badgeEarned,
      );
}
