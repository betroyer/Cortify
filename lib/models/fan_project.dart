class FanProject {
  final int? id;
  final String title;
  final String description;
  final String organizer;
  final DateTime eventDate;
  final String status; // Open, Ongoing, Done
  final int supporters;

  FanProject({
    this.id,
    required this.title,
    required this.description,
    required this.organizer,
    required this.eventDate,
    this.status = 'Open',
    this.supporters = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'organizer': organizer,
        'event_date': eventDate.toIso8601String(),
        'status': status,
        'supporters': supporters,
      };

  factory FanProject.fromMap(Map<String, dynamic> map) => FanProject(
        id: map['id'] as int?,
        title: map['title'] as String,
        description: map['description'] as String,
        organizer: map['organizer'] as String,
        eventDate: DateTime.parse(map['event_date'] as String),
        status: map['status'] as String? ?? 'Open',
        supporters: map['supporters'] as int? ?? 0,
      );

  FanProject copyWith({
    int? id,
    String? title,
    String? description,
    String? organizer,
    DateTime? eventDate,
    String? status,
    int? supporters,
  }) =>
      FanProject(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        organizer: organizer ?? this.organizer,
        eventDate: eventDate ?? this.eventDate,
        status: status ?? this.status,
        supporters: supporters ?? this.supporters,
      );
}
