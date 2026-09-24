class ScheduleEvent {
  final int? id;
  final String title;
  final String description;
  final String member; // All, or specific member
  final String eventType; // Live, Release, Appearance, Fanmeet
  final DateTime startAt;
  final bool reminderOn;
  final bool isOfficial;

  ScheduleEvent({
    this.id,
    required this.title,
    required this.description,
    required this.member,
    required this.eventType,
    required this.startAt,
    this.reminderOn = false,
    this.isOfficial = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'member': member,
        'event_type': eventType,
        'start_at': startAt.toIso8601String(),
        'reminder_on': reminderOn ? 1 : 0,
        'is_official': isOfficial ? 1 : 0,
      };

  factory ScheduleEvent.fromMap(Map<String, dynamic> map) => ScheduleEvent(
        id: map['id'] as int?,
        title: map['title'] as String,
        description: map['description'] as String,
        member: map['member'] as String,
        eventType: map['event_type'] as String,
        startAt: DateTime.parse(map['start_at'] as String),
        reminderOn: (map['reminder_on'] as int) == 1,
        isOfficial: (map['is_official'] as int) == 1,
      );

  ScheduleEvent copyWith({
    int? id,
    String? title,
    String? description,
    String? member,
    String? eventType,
    DateTime? startAt,
    bool? reminderOn,
    bool? isOfficial,
  }) =>
      ScheduleEvent(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        member: member ?? this.member,
        eventType: eventType ?? this.eventType,
        startAt: startAt ?? this.startAt,
        reminderOn: reminderOn ?? this.reminderOn,
        isOfficial: isOfficial ?? this.isOfficial,
      );
}
