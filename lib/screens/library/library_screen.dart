import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      extendBodyBehindAppBar: false,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CupertinoActivityIndicator())
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: IosLargeTitle(
                      'Library',
                      trailing: SoftChip(
                        label: _favoritesOnly ? 'Favorites' : 'All',
                        selected: _favoritesOnly,
                        onTap: () {
                          setState(() => _favoritesOnly = !_favoritesOnly);
                          _load();
                        },
                      ),
                    ),
                  ),
                  if (_songs.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        message: 'No songs yet.',
                        icon: CupertinoIcons.music_note_list,
                      ),
                    )
                  else ...[
                    const SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Collections',
                        subtitle: 'Gallery · fancams · wallpapers',
                      ),
                    ),
                    const SliverToBoxAdapter(child: _GalleryStrip()),
                    ...albums.map((album) {
                      final albumSongs =
                          _songs.where((s) => s.album == album).toList();
                      return SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(title: album),
                            GlassGroupedList(
                              children: albumSongs
                                  .map(
                                    (song) => _SongRow(
                                      song: song,
                                      onFavorite: () => _toggleFavorite(song),
                                      onTap: () async {
                                        await Navigator.of(context).push(
                                          CupertinoPageRoute(
                                            builder: (_) =>
                                                SongDetailScreen(song: song),
                                          ),
                                        );
                                        _load();
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      );
                    }),
                    SliverToBoxAdapter(
                      child: SizedBox(height: glassNavClearance(context)),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _GalleryStrip extends StatelessWidget {
  const _GalleryStrip();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('HD Gallery', CupertinoIcons.photo_on_rectangle, CortifyColors.coral),
      ('Fancams', CupertinoIcons.videocam_fill, CortifyColors.sage),
      ('Wallpapers', CupertinoIcons.device_phone_portrait, CortifyColors.gold),
    ];
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = items[i];
          return GlassPanel(
            width: 120,
            tone: GlassTone.soft,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.$2, color: item.$3, size: 22),
                const SizedBox(height: 8),
                Text(
                  item.$1,
                  style: const TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
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

class _SongRow extends StatelessWidget {
  const _SongRow({
    required this.song,
    required this.onFavorite,
    required this.onTap,
  });

  final Song song;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [CortifyColors.coral, CortifyColors.coralSoft],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                CupertinoIcons.music_note,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: CortifyColors.label,
                    ),
                  ),
                  Text(
                    '${song.releaseYear} · ${song.duration}',
                    style: const TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 13,
                      color: CortifyColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.all(8),
              onPressed: onFavorite,
              child: Icon(
                song.isFavorite
                    ? CupertinoIcons.heart_fill
                    : CupertinoIcons.heart,
                color: CortifyColors.coral,
                size: 22,
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: CortifyColors.tertiary,
            ),
          ],
        ),
      ),
    );
  }
}
