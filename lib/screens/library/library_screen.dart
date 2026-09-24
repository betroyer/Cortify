import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../database/database_helper.dart';
import '../../models/song.dart';
import '../../theme/app_theme.dart';
import '../../theme/glass.dart';
import '../../widgets/common_widgets.dart';
import 'song_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _db = DatabaseHelper.instance;
  List<Song> _songs = [];
  bool _favoritesOnly = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final songs = await _db.getSongs(favoritesOnly: _favoritesOnly);
    if (!mounted) return;
    setState(() {
      _songs = songs;
      _loading = false;
    });
  }

  Future<void> _toggleFavorite(Song song) async {
    await _db.toggleFavorite(song);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final albums = <String>{};
    for (final s in _songs) {
      albums.add(s.album);
    }

    return GlassScaffold(
      appBar: GlassAppBar(
        title: const Text('Library'),
        actions: [
          SoftChip(
            label: _favoritesOnly ? 'Favorites' : 'All',
            selected: _favoritesOnly,
            onTap: () {
              setState(() => _favoritesOnly = !_favoritesOnly);
              _load();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _songs.isEmpty
              ? EmptyState(
                  message: _favoritesOnly
                      ? 'No favorites yet. Heart a song to save it.'
                      : 'Discography is empty.',
                  icon: Icons.library_music_outlined,
                )
              : ListView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    glassNavClearance(context),
                  ),
                  children: [
                    SectionHeader(
                      title: 'Discography',
                      subtitle: 'Lyrics · translations · favorites',
                    ),
                    const SizedBox(height: 8),
                    const _GalleryStrip(),
                    const SizedBox(height: 20),
                    ...albums.map((album) {
                      final albumSongs =
                          _songs.where((s) => s.album == album).toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, top: 8),
                            child: Text(
                              album,
                              style: GoogleFonts.fraunces(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          ...albumSongs.map(
                            (song) => _SongTile(
                              song: song,
                              onFavorite: () => _toggleFavorite(song),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        SongDetailScreen(song: song),
                                  ),
                                );
                                _load();
                              },
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
    );
  }
}

class _GalleryStrip extends StatelessWidget {
  const _GalleryStrip();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('HD Gallery', Icons.photo_library_rounded, CortifyColors.coral),
      ('Fancams', Icons.videocam_rounded, CortifyColors.sage),
      ('Wallpapers', Icons.wallpaper_rounded, CortifyColors.gold),
    ];
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = items[i];
          return GlassPanel(
            width: 124,
            tone: GlassTone.soft,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.$2, color: item.$3),
                const SizedBox(height: 8),
                Text(
                  item.$1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: CortifyColors.charcoal,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SongTile extends StatelessWidget {
  const _SongTile({
    required this.song,
    required this.onFavorite,
    required this.onTap,
  });

  final Song song;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [CortifyColors.coral, CortifyColors.coralSoft],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
          ),
          child: const Icon(Icons.music_note, color: Colors.white, size: 22),
        ),
        title: Text(
          song.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${song.releaseYear} · ${song.duration}'),
        trailing: IconButton(
          onPressed: onFavorite,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: Icon(
            song.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: CortifyColors.coral,
          ),
        ),
      ),
    );
  }
}
