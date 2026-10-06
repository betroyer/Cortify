import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../database/database_helper.dart';
import '../../models/song.dart';
import '../../theme/app_theme.dart';
import '../../theme/glass.dart';

class SongDetailScreen extends StatefulWidget {
  const SongDetailScreen({super.key, required this.song});

  final Song song;

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  late Song _song;
  bool _showTranslated = false;

  @override
  void initState() {
    super.initState();
    _song = widget.song;
  }

  Future<void> _toggleFavorite() async {
    await DatabaseHelper.instance.toggleFavorite(_song);
    setState(() => _song = _song.copyWith(isFavorite: !_song.isFavorite));
  }

  @override
  Widget build(BuildContext context) {
    final lyrics = _showTranslated ? _song.lyricsTranslated : _song.lyrics;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackdrop(),
          Column(
            children: [
              GlassAppBar(
                title: Text(_song.title),
                actions: [
                  CupertinoButton(
                    padding: const EdgeInsets.only(right: 8),
                    onPressed: _toggleFavorite,
                    child: Icon(
                      _song.isFavorite
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      color: CortifyColors.coral,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: [
                    GlassPanel(
                      tone: GlassTone.chrome,
                      borderRadius: Glass.brLg,
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  CortifyColors.coral,
                                  CortifyColors.coralSoft,
                                ],
                              ),
                            ),
                            child: const Icon(
                              CupertinoIcons.music_albums_fill,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _song.album,
                            style: const TextStyle(
                              fontFamily: '.SF Pro Display',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_song.releaseYear} · ${_song.duration}',
                            style: const TextStyle(
                              fontFamily: '.SF Pro Text',
                              color: CortifyColors.muted,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text(
                          'Lyrics',
                          style: TextStyle(
                            fontFamily: '.SF Pro Display',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          color: Colors.white.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(20),
                          onPressed: () => setState(
                            () => _showTranslated = !_showTranslated,
                          ),
                          child: Text(
                            _showTranslated ? 'Translated' : 'Original',
                            style: const TextStyle(
                              fontFamily: '.SF Pro Text',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: CortifyColors.coral,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GlassPanel(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        lyrics,
                        style: const TextStyle(
                          fontFamily: '.SF Pro Text',
                          fontSize: 17,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
