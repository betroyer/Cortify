import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      appBar: const GlassAppBar(title: Text('Support Hub')),
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
                  glassNavClearance(context),
                ),
                children: [
                  GlassPanel(
                    tone: GlassTone.chrome,
                    borderRadius: Glass.brLg,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vote & Stream',
                          style: GoogleFonts.fraunces(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Unified guides · trackers · milestone badges',
                          style: TextStyle(
                            color: CortifyColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SectionHeader(
                    title: 'Your badges',
                    subtitle: badges.isEmpty
                        ? 'Log 10 actions to unlock'
                        : '${badges.length} earned',
                  ),
                  SizedBox(
                    height: 88,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _guides.map((g) {
                        final earned = g.badgeEarned;
                        return GlassPanel(
                          width: 104,
                          tone: GlassTone.soft,
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                earned
                                    ? Icons.military_tech
                                    : Icons.lock_outline,
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
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: earned
                                      ? CortifyColors.charcoal
                                      : CortifyColors.muted,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionHeader(
                    title: 'Active campaigns',
                    subtitle: 'Tap Log after each vote or stream batch',
                  ),
                  ..._guides.map(
                    (g) => _GuideCard(guide: g, onLog: () => _log(g)),
                  ),
                ],
              ),
            ),
    );
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
      margin: const EdgeInsets.only(bottom: 12),
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
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: CortifyColors.sage.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  guide.platform,
                  style: const TextStyle(
                    fontSize: 11,
                    color: CortifyColors.sage,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            guide.instructions,
            style: TextStyle(
              fontSize: 13,
              color: CortifyColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            guide.linkHint,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: CortifyColors.sage,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              color: CortifyColors.coral,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${guide.streamsLogged}/10 logged',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                daysLeft < 0 ? 'Ended' : '$daysLeft days left',
                style: TextStyle(fontSize: 12, color: CortifyColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Deadline ${DateFormat('MMM d, y').format(guide.deadline)}',
            style: TextStyle(fontSize: 11, color: CortifyColors.muted),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onLog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Log activity'),
            ),
          ),
        ],
      ),
    );
  }
}
