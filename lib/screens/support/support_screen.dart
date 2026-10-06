import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/database_helper.dart';
import '../../models/vote_guide.dart';
import '../../theme/app_theme.dart';
import '../../theme/glass.dart';
import '../../widgets/common_widgets.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _db = DatabaseHelper.instance;
  List<VoteGuide> _guides = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final guides = await _db.getVoteGuides();
    if (!mounted) return;
    setState(() {
      _guides = guides;
      _loading = false;
    });
  }

  Future<void> _log(VoteGuide guide) async {
    await _db.logStream(guide);
    await _load();
    if (!mounted) return;
    final updated = _guides.firstWhere((g) => g.id == guide.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updated.badgeEarned
              ? 'Badge unlocked: ${updated.badgeName}!'
              : 'Logged · ${updated.streamsLogged} so far',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final badges = _guides.where((g) => g.badgeEarned).toList();

    return GlassScaffold(
      extendBodyBehindAppBar: false,
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
                  const OmitTitle('Support'),
                  SliverToBoxAdapter(
                    child: GlassPanel(
                      tone: GlassTone.chrome,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      borderRadius: Glass.brLg,
                      padding: const EdgeInsets.all(18),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vote & Stream',
                            style: TextStyle(
                              fontFamily: '.SF Pro Display',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Unified guides · trackers · milestone badges',
                            style: TextStyle(
                              fontFamily: '.SF Pro Text',
                              color: CortifyColors.muted,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Your badges',
                      subtitle: badges.isEmpty
                          ? 'Log 10 actions to unlock'
                          : '${badges.length} earned',
                    ),
                  ),
                  OmitTitle(
                    '',
                    child: SizedBox(
                      height: 88,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: _guides.map((g) {
                          final earned = g.badgeEarned;
                          return GlassPanel(
                            width: 100,
                            tone: GlassTone.soft,
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  earned
                                      ? CupertinoIcons.rosette
                                      : CupertinoIcons.lock,
                                  color: earned
                                      ? CortifyColors.gold
                                      : CortifyColors.muted,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  g.badgeName.isEmpty ? 'Badge' : g.badgeName,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: '.SF Pro Text',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: earned
                                        ? CortifyColors.label
                                        : CortifyColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Active campaigns',
                      subtitle: 'Tap Log after each vote or stream batch',
                    ),
                  ),
                  ..._guides.map(
                    (g) => SliverToBoxAdapter(
                      child: _GuideCard(guide: g, onLog: () => _log(g)),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: glassNavClearance(context)),
                  ),
                ],
              ),
      ),
    );
  }
}

class OmitTitle extends StatelessWidget {
  const OmitTitle(this.text, {super.key, this.child});

  final String text;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (child != null) return SliverToBoxAdapter(child: child);
    return SliverToBoxAdapter(child: IosLargeTitle(text));
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.guide, required this.onLog});

  final VoteGuide guide;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final progress = (guide.streamsLogged / 10).clamp(0.0, 1.0);
    final daysLeft = guide.deadline.difference(DateTime.now()).inDays;

    return GlassPanel(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  guide.title,
                  style: const TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                guide.platform,
                style: const TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 13,
                  color: CortifyColors.sage,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            guide.instructions,
            style: const TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 14,
              color: CortifyColors.muted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.black.withValues(alpha: 0.06),
              color: CortifyColors.coral,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${guide.streamsLogged}/10 logged',
                style: const TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                daysLeft < 0 ? 'Ended' : '$daysLeft days left',
                style: const TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 12,
                  color: CortifyColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Deadline ${DateFormat('MMM d, y').format(guide.deadline)}',
            style: const TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 11,
              color: CortifyColors.tertiary,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              borderRadius: BorderRadius.circular(12),
              onPressed: onLog,
              child: const Text('Log activity'),
            ),
          ),
        ],
      ),
    );
  }
}
