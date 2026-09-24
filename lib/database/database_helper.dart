import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/announcement.dart';
import '../models/community_post.dart';
import '../models/fan_diary.dart';
import '../models/fan_project.dart';
import '../models/schedule_event.dart';
import '../models/song.dart';
import '../models/vote_guide.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;
  static const _dbName = 'cortify.db';
  static const _dbVersion = 1;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE schedule_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        member TEXT NOT NULL,
        event_type TEXT NOT NULL,
        start_at TEXT NOT NULL,
        reminder_on INTEGER NOT NULL DEFAULT 0,
        is_official INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE announcements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        category TEXT NOT NULL,
        posted_at TEXT NOT NULL,
        is_pinned INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE community_posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        author TEXT NOT NULL,
        content TEXT NOT NULL,
        language TEXT NOT NULL DEFAULT 'en',
        translated_content TEXT,
        created_at TEXT NOT NULL,
        hearts INTEGER NOT NULL DEFAULT 0,
        is_official INTEGER NOT NULL DEFAULT 0,
        board TEXT NOT NULL DEFAULT 'Feed'
      )
    ''');

    await db.execute('''
      CREATE TABLE songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        album TEXT NOT NULL,
        release_year TEXT NOT NULL,
        lyrics TEXT NOT NULL,
        lyrics_translated TEXT NOT NULL,
        duration TEXT NOT NULL DEFAULT '3:00',
        is_favorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE vote_guides (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        platform TEXT NOT NULL,
        instructions TEXT NOT NULL,
        link_hint TEXT NOT NULL,
        deadline TEXT NOT NULL,
        streams_logged INTEGER NOT NULL DEFAULT 0,
        badge_name TEXT NOT NULL DEFAULT '',
        badge_earned INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE fan_diary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        mood TEXT NOT NULL,
        bias_member TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_concert_memory INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE fan_projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        organizer TEXT NOT NULL,
        event_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'Open',
        supporters INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        display_name TEXT NOT NULL,
        bias_member TEXT NOT NULL,
        wallpaper TEXT NOT NULL DEFAULT 'coral_dawn'
      )
    ''');

    await _seed(db);
  }

  Future<void> _seed(Database db) async {
    final now = DateTime.now();

    final events = [
      ScheduleEvent(
        title: 'Cortis Music Bank Appearance',
        description: 'Live stage performance — stream & vote!',
        member: 'All',
        eventType: 'Appearance',
        startAt: now.add(const Duration(days: 2, hours: 6)),
        reminderOn: true,
      ),
      ScheduleEvent(
        title: 'Ren Birthday Live',
        description: 'Special Weverse birthday live with Ren.',
        member: 'Ren',
        eventType: 'Live',
        startAt: now.add(const Duration(days: 5, hours: 14)),
      ),
      ScheduleEvent(
        title: 'New Single Drop',
        description: 'Digital single release across all platforms.',
        member: 'All',
        eventType: 'Release',
        startAt: now.add(const Duration(days: 10)),
      ),
      ScheduleEvent(
        title: 'Manila Fansign',
        description: 'Offline fansign for Philippine Cortis.',
        member: 'All',
        eventType: 'Fanmeet',
        startAt: now.add(const Duration(days: 21, hours: 10)),
        reminderOn: true,
      ),
      ScheduleEvent(
        title: 'Kai Radio Guest',
        description: 'Idol Radio special episode.',
        member: 'Kai',
        eventType: 'Appearance',
        startAt: now.add(const Duration(days: 3, hours: 20)),
      ),
    ];
    for (final e in events) {
      await db.insert('schedule_events', e.toMap());
    }

    final announcements = [
      Announcement(
        title: 'Welcome to Cortify',
        body:
            'Your all-in-one home for Cortis. Official updates, schedules, community, and more — one space, one heart.',
        category: 'Official',
        postedAt: now.subtract(const Duration(hours: 2)),
        isPinned: true,
      ),
      Announcement(
        title: 'Streaming Party This Friday',
        body:
            'Join the global stream party for the title track. Goal: 1M streams in 24 hours. Guides in Support Hub.',
        category: 'Music',
        postedAt: now.subtract(const Duration(days: 1)),
      ),
      Announcement(
        title: 'SE Asia Tour Dates Coming Soon',
        body:
            'Official team confirms Manila, Jakarta, and Bangkok under discussion. Stay tuned.',
        category: 'Tour',
        postedAt: now.subtract(const Duration(days: 3)),
      ),
    ];
    for (final a in announcements) {
      await db.insert('announcements', a.toMap());
    }

    final posts = [
      CommunityPost(
        author: 'Cortis Official',
        content: 'Thank you Cortis for streaming all week. You make every stage brighter.',
        language: 'en',
        translatedContent: 'Salamat Cortis sa streaming buong linggo. Pinapaliwanag ninyo ang bawat stage.',
        createdAt: now.subtract(const Duration(hours: 5)),
        hearts: 1284,
        isOfficial: true,
        board: 'Announcements',
      ),
      CommunityPost(
        author: 'davao_cortis',
        content: 'Anyone else crying during the encore? Ren\'s high note destroyed me',
        language: 'en',
        translatedContent: 'May umiiyak pa ba during the encore? Ren\'s high note tinapos ako',
        createdAt: now.subtract(const Duration(hours: 8)),
        hearts: 96,
        board: 'Feed',
      ),
      CommunityPost(
        author: 'manila_lightstick',
        content: 'Organizing birthday cafe for Leo in Makati — drop your IG if you want to help!',
        language: 'en',
        createdAt: now.subtract(const Duration(days: 1)),
        hearts: 54,
        board: 'Projects',
      ),
      CommunityPost(
        author: 'cebu_stream_team',
        content: 'Streaming checklist pinned in Support Hub. Let\'s hit diamond!',
        language: 'en',
        createdAt: now.subtract(const Duration(days: 2)),
        hearts: 210,
        board: 'Feed',
      ),
    ];
    for (final p in posts) {
      await db.insert('community_posts', p.toMap());
    }

    final songs = [
      Song(
        title: 'Heartbeat',
        album: 'Cortis: First Light',
        releaseYear: '2024',
        duration: '3:24',
        lyrics:
            'In the quiet of the night\nI hear your heartbeat calling\nThrough the city lights\nWe keep on falling\n\nOne heart, one stage, one dream',
        lyricsTranslated:
            'Sa katahimikan ng gabi\nNaririnig ko ang tibok ng puso mo\nSa mga ilaw ng lungsod\nPatuloy tayong nahuhulog\n\nIsang puso, isang stage, isang pangarap',
        isFavorite: true,
      ),
      Song(
        title: 'Coral Skies',
        album: 'Cortis: First Light',
        releaseYear: '2024',
        duration: '3:11',
        lyrics:
            'Paint the sky in coral hue\nEvery color leads to you\nHold my hand across the sea\nCortis forever, you and me',
        lyricsTranslated:
            'Pintahan ang langit ng coral\nBawat kulay patungo sa\'yo\nHawakan ang kamay ko sa dagat\nCortis forever, ikaw at ako',
      ),
      Song(
        title: 'Midnight Signal',
        album: 'Signal EP',
        releaseYear: '2025',
        duration: '2:58',
        lyrics:
            'Send a signal in the dark\nI\'ll be waiting where we start\nNo more distant, no more late\nLove arrives on time, just wait',
        lyricsTranslated:
            'Magpadala ng signal sa dilim\nMaghihintay ako kung saan tayo nagsimula\nWala nang malayo, wala nang late\nDumating ang pag-ibig sa oras, maghintay ka lang',
        isFavorite: true,
      ),
      Song(
        title: 'Home With You',
        album: 'Signal EP',
        releaseYear: '2025',
        duration: '3:40',
        lyrics:
            'Wherever we go, you feel like home\nIn every crowd, I\'m never alone\nYour voice, my guide, my favorite song\nThis is where we both belong',
        lyricsTranslated:
            'Saan man tayo pumunta, parang bahay ka\nSa bawat crowd, hindi ako nag-iisa\nBoses mo, gabay ko, paborito kong kanta\nDito tayo parehong nabibilang',
      ),
    ];
    for (final s in songs) {
      await db.insert('songs', s.toMap());
    }

    final votes = [
      VoteGuide(
        title: 'Mnet Music Chart Vote',
        platform: 'Mnet Plus',
        instructions:
            '1. Open Mnet Plus\n2. Search Cortis\n3. Vote once per account daily\n4. Log your vote here for the team badge',
        linkHint: 'mnetplus.app / Cortis',
        deadline: now.add(const Duration(days: 7)),
        streamsLogged: 3,
        badgeName: 'Chart Guardian',
      ),
      VoteGuide(
        title: 'Spotify Title Track Stream',
        platform: 'Spotify',
        instructions:
            '1. Play Heartbeat on repeat\n2. Keep app open, volume audible\n3. Log every 10 full plays\n4. Share playlist with friends',
        linkHint: 'open.spotify.com / Cortis Heartbeat',
        deadline: now.add(const Duration(days: 14)),
        streamsLogged: 12,
        badgeName: 'Stream Ace',
        badgeEarned: true,
      ),
      VoteGuide(
        title: 'YouTube MV Marathon',
        platform: 'YouTube',
        instructions:
            '1. Watch official MV (no skip)\n2. Like + comment with #Cortify\n3. Log views in batches of 5',
        linkHint: 'youtube.com / Cortis Official',
        deadline: now.add(const Duration(days: 5)),
        streamsLogged: 0,
        badgeName: 'MV Marathon',
      ),
    ];
    for (final v in votes) {
      await db.insert('vote_guides', v.toMap());
    }

    final projects = [
      FanProject(
        title: 'Ren Birthday Cafe — Makati',
        description: 'Cafe takeover with freebies, photo zone, and streaming station.',
        organizer: 'manila_lightstick',
        eventDate: now.add(const Duration(days: 18)),
        status: 'Open',
        supporters: 87,
      ),
      FanProject(
        title: 'Airport Support — NAIA',
        description: 'Welcome banners and snacks for arrival day. Kindness first — no crowding.',
        organizer: 'ph_cortis_union',
        eventDate: now.add(const Duration(days: 9)),
        status: 'Ongoing',
        supporters: 142,
      ),
    ];
    for (final p in projects) {
      await db.insert('fan_projects', p.toMap());
    }

    await db.insert('fan_diary', FanDiary(
      title: 'First time hearing Heartbeat',
      body:
          'I still remember the goosebumps. Played it on loop walking home from school in Davao. Cortify feels like that moment — everything in one place.',
      mood: 'Nostalgia',
      biasMember: 'Ren',
      createdAt: now.subtract(const Duration(days: 4)),
    ).toMap());

    await db.insert('profile', {
      'id': 1,
      'display_name': 'Cortis Fan',
      'bias_member': 'Ren',
      'wallpaper': 'coral_dawn',
    });
  }

  // ——— Schedule ———
  Future<List<ScheduleEvent>> getScheduleEvents({String? member}) async {
    final db = await database;
    final maps = member == null || member == 'All'
        ? await db.query('schedule_events', orderBy: 'start_at ASC')
        : await db.query(
            'schedule_events',
            where: 'member = ? OR member = ?',
            whereArgs: [member, 'All'],
            orderBy: 'start_at ASC',
          );
    return maps.map(ScheduleEvent.fromMap).toList();
  }

  Future<void> toggleReminder(ScheduleEvent event) async {
    final db = await database;
    await db.update(
      'schedule_events',
      {'reminder_on': event.reminderOn ? 0 : 1},
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  // ——— Announcements ———
  Future<List<Announcement>> getAnnouncements() async {
    final db = await database;
    final maps = await db.query(
      'announcements',
      orderBy: 'is_pinned DESC, posted_at DESC',
    );
    return maps.map(Announcement.fromMap).toList();
  }

  // ——— Community ———
  Future<List<CommunityPost>> getPosts({String board = 'Feed'}) async {
    final db = await database;
    final maps = await db.query(
      'community_posts',
      where: 'board = ?',
      whereArgs: [board],
      orderBy: 'created_at DESC',
    );
    return maps.map(CommunityPost.fromMap).toList();
  }

  Future<int> insertPost(CommunityPost post) async {
    final db = await database;
    return db.insert('community_posts', post.toMap()..remove('id'));
  }

  Future<void> heartPost(CommunityPost post) async {
    final db = await database;
    await db.update(
      'community_posts',
      {'hearts': post.hearts + 1},
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }

  // ——— Songs ———
  Future<List<Song>> getSongs({bool favoritesOnly = false}) async {
    final db = await database;
    final maps = favoritesOnly
        ? await db.query(
            'songs',
            where: 'is_favorite = ?',
            whereArgs: [1],
            orderBy: 'title ASC',
          )
        : await db.query('songs', orderBy: 'album ASC, title ASC');
    return maps.map(Song.fromMap).toList();
  }

  Future<void> toggleFavorite(Song song) async {
    final db = await database;
    await db.update(
      'songs',
      {'is_favorite': song.isFavorite ? 0 : 1},
      where: 'id = ?',
      whereArgs: [song.id],
    );
  }

  // ——— Votes ———
  Future<List<VoteGuide>> getVoteGuides() async {
    final db = await database;
    final maps = await db.query('vote_guides', orderBy: 'deadline ASC');
    return maps.map(VoteGuide.fromMap).toList();
  }

  Future<void> logStream(VoteGuide guide) async {
    final db = await database;
    final next = guide.streamsLogged + 1;
    final earned = next >= 10 || guide.badgeEarned;
    await db.update(
      'vote_guides',
      {
        'streams_logged': next,
        'badge_earned': earned ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [guide.id],
    );
  }

  // ——— Fan projects ———
  Future<List<FanProject>> getFanProjects() async {
    final db = await database;
    final maps = await db.query('fan_projects', orderBy: 'event_date ASC');
    return maps.map(FanProject.fromMap).toList();
  }

  Future<void> supportProject(FanProject project) async {
    final db = await database;
    await db.update(
      'fan_projects',
      {'supporters': project.supporters + 1},
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  // ——— Diary ———
  Future<List<FanDiary>> getDiaryEntries() async {
    final db = await database;
    final maps = await db.query('fan_diary', orderBy: 'created_at DESC');
    return maps.map(FanDiary.fromMap).toList();
  }

  Future<int> insertDiary(FanDiary entry) async {
    final db = await database;
    return db.insert('fan_diary', entry.toMap()..remove('id'));
  }

  Future<void> updateDiary(FanDiary entry) async {
    final db = await database;
    await db.update(
      'fan_diary',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> deleteDiary(int id) async {
    final db = await database;
    await db.delete('fan_diary', where: 'id = ?', whereArgs: [id]);
  }

  // ——— Profile ———
  Future<Map<String, dynamic>> getProfile() async {
    final db = await database;
    final maps = await db.query('profile', where: 'id = ?', whereArgs: [1]);
    return maps.first;
  }

  Future<void> updateBias(String bias) async {
    final db = await database;
    await db.update('profile', {'bias_member': bias}, where: 'id = ?', whereArgs: [1]);
  }

  Future<void> updateDisplayName(String name) async {
    final db = await database;
    await db.update('profile', {'display_name': name}, where: 'id = ?', whereArgs: [1]);
  }
}
