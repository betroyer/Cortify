class Song {
  final int? id;
  final String title;
  final String album;
  final String releaseYear;
  final String lyrics;
  final String lyricsTranslated;
  final String duration;
  final bool isFavorite;

  Song({
    this.id,
    required this.title,
    required this.album,
    required this.releaseYear,
    required this.lyrics,
    required this.lyricsTranslated,
    this.duration = '3:00',
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'album': album,
        'release_year': releaseYear,
        'lyrics': lyrics,
        'lyrics_translated': lyricsTranslated,
        'duration': duration,
        'is_favorite': isFavorite ? 1 : 0,
      };

  factory Song.fromMap(Map<String, dynamic> map) => Song(
        id: map['id'] as int?,
        title: map['title'] as String,
        album: map['album'] as String,
        releaseYear: map['release_year'] as String,
        lyrics: map['lyrics'] as String,
        lyricsTranslated: map['lyrics_translated'] as String,
        duration: map['duration'] as String? ?? '3:00',
        isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      );

  Song copyWith({
    int? id,
    String? title,
    String? album,
    String? releaseYear,
    String? lyrics,
    String? lyricsTranslated,
    String? duration,
    bool? isFavorite,
  }) =>
      Song(
        id: id ?? this.id,
        title: title ?? this.title,
        album: album ?? this.album,
        releaseYear: releaseYear ?? this.releaseYear,
        lyrics: lyrics ?? this.lyrics,
        lyricsTranslated: lyricsTranslated ?? this.lyricsTranslated,
        duration: duration ?? this.duration,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}
