import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../database/database_helper.dart';
import '../../models/fan_diary.dart';
import '../../theme/app_theme.dart';
import '../../theme/glass.dart';
import '../../widgets/common_widgets.dart';
import 'diary_form_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _db = DatabaseHelper.instance;
  List<FanDiary> _entries = [];
  Map<String, dynamic>? _profile;
  bool _loading = true;

  static const _wallpapers = {
    'coral_dawn': [CortifyColors.coral, Color(0xFFFFB4A8)],
    'sage_night': [CortifyColors.sage, Color(0xFF9BC4B5)],
    'gold_hour': [CortifyColors.gold, Color(0xFFE8C9A0)],
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final entries = await _db.getDiaryEntries();
    final profile = await _db.getProfile();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _profile = profile;
      _loading = false;
    });
  }

  Future<void> _openForm([FanDiary? entry]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DiaryFormScreen(entry: entry)),
    );
    if (changed == true) await _load();
  }

  Future<void> _changeBias() async {
    const members = ['Ren', 'Kai', 'Leo', 'Jun'];
    final current = _profile?['bias_member'] as String? ?? 'Ren';
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassPanel(
        tone: GlassTone.chrome,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Choose your bias',
                  style: GoogleFonts.fraunces(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...members.map(
                (m) => ListTile(
                  leading: MemberAvatar(name: m),
                  title: Text(m),
                  trailing: m == current
                      ? const Icon(Icons.check, color: CortifyColors.coral)
                      : null,
                  onTap: () => Navigator.pop(ctx, m),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null) return;
    await _db.updateBias(picked);
    await _load();
  }

  Future<void> _cycleWallpaper() async {
    final keys = _wallpapers.keys.toList();
    final current = _profile?['wallpaper'] as String? ?? 'coral_dawn';
    final next = keys[(keys.indexOf(current) + 1) % keys.length];
    final db = await _db.database;
    await db.update(
      'profile',
      {'wallpaper': next},
      where: 'id = ?',
      whereArgs: [1],
    );
    await _load();
  }

  Future<void> _rename() async {
    final controller = TextEditingController(
      text: _profile?['display_name'] as String? ?? '',
    );
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: Glass.brMd),
        title: const Text('Display name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Your fan name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await _db.updateDisplayName(name);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final wallpaperKey = _profile?['wallpaper'] as String? ?? 'coral_dawn';
    final colors = _wallpapers[wallpaperKey] ?? _wallpapers['coral_dawn']!;
    final bias = _profile?['bias_member'] as String? ?? 'Ren';
    final name = _profile?['display_name'] as String? ?? 'Cortis Fan';

    return GlassScaffold(
      appBar: const GlassAppBar(title: Text('Fan Diary')),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 64),
        child: FloatingActionButton(
          onPressed: () => _openForm(),
          tooltip: 'New memory',
          child: const Icon(Icons.add),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: CortifyColors.coral,
              onRefresh: _load,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  glassNavClearance(context) + 24,
                ),
                children: [
                  GestureDetector(
                    onTap: _cycleWallpaper,
                    child: GlassPanel(
                      tone: GlassTone.chrome,
                      borderRadius: Glass.brLg,
                      padding: EdgeInsets.zero,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: Glass.brLg,
                          gradient: LinearGradient(
                            colors: [
                              colors[0].withValues(alpha: 0.85),
                              colors[1].withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                MemberAvatar(name: bias, size: 52),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: GoogleFonts.fraunces(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Bias widget · tap to change wallpaper',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              children: [
                                ActionChip(
                                  label: Text('Bias: $bias'),
                                  onPressed: _changeBias,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.25),
                                  labelStyle:
                                      const TextStyle(color: Colors.white),
                                  side: BorderSide(
                                    color:
                                        Colors.white.withValues(alpha: 0.4),
                                  ),
                                ),
                                ActionChip(
                                  label: const Text('Rename'),
                                  onPressed: _rename,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.25),
                                  labelStyle:
                                      const TextStyle(color: Colors.white),
                                  side: BorderSide(
                                    color:
                                        Colors.white.withValues(alpha: 0.4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SectionHeader(
                    title: 'Memory log',
                    subtitle: 'Private · just for you',
                  ),
                  if (_entries.isEmpty)
                    const EmptyState(
                      message:
                          'Start your Cortis diary — concerts, first listens, feelings.',
                      icon: Icons.auto_stories_outlined,
                    )
                  else
                    ..._entries.map(
                      (e) => Dismissible(
                        key: ValueKey(e.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: CortifyColors.coral.withValues(alpha: 0.9),
                            borderRadius: Glass.brMd,
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) async {
                          await _db.deleteDiary(e.id!);
                          await _load();
                        },
                        child: _DiaryCard(
                          entry: e,
                          onTap: () => _openForm(e),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _DiaryCard extends StatelessWidget {
  const _DiaryCard({required this.entry, required this.onTap});

  final FanDiary entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (entry.isConcertMemory)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.stadium,
                    size: 16,
                    color: CortifyColors.gold,
                  ),
                ),
              Expanded(
                child: Text(
                  entry.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                entry.mood,
                style: const TextStyle(
                  fontSize: 12,
                  color: CortifyColors.coral,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            entry.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: CortifyColors.muted,
              height: 1.4,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              MemberAvatar(name: entry.biasMember, size: 22),
              const SizedBox(width: 6),
              Text(
                entry.biasMember,
                style: TextStyle(fontSize: 12, color: CortifyColors.muted),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM d, y').format(entry.createdAt),
                style: TextStyle(fontSize: 11, color: CortifyColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
