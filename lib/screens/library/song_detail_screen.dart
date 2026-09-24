import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      extendBodyBehindAppBar: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackdrop(),
          Column(
            children: [
              GlassAppBar(
                title: Text(_song.title),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      _song.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: CortifyColors.coral,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    GlassPanel(
                      tone: GlassTone.chrome,
                      borderRadius: Glass.brLg,
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  CortifyColors.coral,
                                  CortifyColors.coralSoft,
                                ],
                              ),
                              boxShadow: Glass.liftSm,
                            ),
                            child: const Icon(
                              Icons.album,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _song.album,
                            style: GoogleFonts.fraunces(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_song.releaseYear} · ${_song.duration}',
                            style: TextStyle(color: CortifyColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'Lyrics',
                          style: GoogleFonts.fraunces(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        SoftToggle(
                          label: _showTranslated ? 'Translated' : 'Original',
                          onTap: () => setState(
                            () => _showTranslated = !_showTranslated,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GlassPanel(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        lyrics,
                        style: const TextStyle(fontSize: 16, height: 1.7),
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

class SoftToggle extends StatelessWidget {
  const SoftToggle({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate, size: 16, color: CortifyColors.coral),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: CortifyColors.coral,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
