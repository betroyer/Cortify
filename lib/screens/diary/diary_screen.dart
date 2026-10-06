import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    final changed = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(builder: (_) => DiaryFormScreen(entry: entry)),
    );
    if (changed == true) await _load();
  }

  Future<void> _changeBias() async {
    const members = ['Ren', 'Kai', 'Leo', 'Jun'];
    final current = _profile?['bias_member'] as String? ?? 'Ren';
    final picked = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Choose your bias'),
        actions: members
            .map(
              (m) => CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(ctx, m),
                isDefaultAction: m == current,
                child: Text(m),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
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
    final name = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Display name'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'Your fan name',
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
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
      extendBodyBehindAppBar: false,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: GlassFab(
          onPressed: () => _openForm(),
          icon: CupertinoIcons.add,
          tooltip: 'New memory',
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CupertinoActivityIndicator())
            : CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  CupertinoSliverRefreshControl(onRefresh: _load),
                  const SliverToBoxAdapter(child: IosLargeTitle('Diary')),
                  OmitSliver(
                    child: GestureDetector(
                      onTap: _cycleWallpaper,
                      child: GlassPanel(
                        tone: GlassTone.chrome,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        borderRadius: Glass.brLg,
                        padding: EdgeInsets.zero,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: Glass.brLg,
                            gradient: LinearGradient(
                              colors: [
                                colors[0].withValues(alpha: 0.88),
                                colors[1].withValues(alpha: 0.78),
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
                                          style: const TextStyle(
                                            fontFamily: '.SF Pro Display',
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Tap wallpaper · bias widget',
                                          style: TextStyle(
                                            fontFamily: '.SF Pro Text',
                                            color: Colors.white
                                                .withValues(alpha: 0.9),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  _GlassAction(
                                    label: 'Bias: $bias',
                                    onTap: _changeBias,
                                  ),
                                  const SizedBox(width: 8),
                                  _GlassAction(
                                    label: 'Rename',
                                    onTap: _rename,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Memory log',
                      subtitle: 'Private · just for you',
                    ),
                  ),
                  if (_entries.isEmpty)
                    const OmitSliver(
                      child: EmptyState(
                        message:
                            'Start your Cortis diary — concerts, first listens, feelings.',
                        icon: CupertinoIcons.book,
                      ),
                    )
                  else
                    ..._entries.map(
                      (e) => OmitSliver(
                        child: Dismissible(
                          key: ValueKey(e.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            decoration: BoxDecoration(
                              color: CortifyColors.coral,
                              borderRadius: Glass.brMd,
                            ),
                            child: const Icon(
                              CupertinoIcons.delete,
                              color: Colors.white,
                            ),
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
                    ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: glassNavClearance(context) + 24),
                  ),
                ],
              ),
      ),
    );
  }
}

class OmitSliver extends StatelessWidget {
  const OmitSliver({super.key, this.child, this.height});

  final Widget? child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (height != null) {
      return OmitSliverHeight(height!);
    }
    return SliverToBoxAdapter(child: child);
  }
}

class OmitSliverHeight extends StatelessWidget {
  const OmitSliverHeight(this.height, {super.key});
  final double height;

  @override
  Widget build(BuildContext context) =>
      SliverToBoxAdapter(child: SizedBox(height: height));
}

class _GlassAction extends StatelessWidget {
  const _GlassAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Colors.white.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(20),
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white,
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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
                    CupertinoIcons.star_fill,
                    size: 14,
                    color: CortifyColors.gold,
                  ),
                ),
              Expanded(
                child: Text(
                  entry.title,
                  style: const TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                entry.mood,
                style: const TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 13,
                  color: CortifyColors.coral,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            entry.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: '.SF Pro Text',
              color: CortifyColors.muted,
              height: 1.35,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              MemberAvatar(name: entry.biasMember, size: 22),
              const SizedBox(width: 6),
              Text(
                entry.biasMember,
                style: const TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 12,
                  color: CortifyColors.muted,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM d, y').format(entry.createdAt),
                style: const TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 12,
                  color: CortifyColors.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
