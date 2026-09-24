import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../database/database_helper.dart';
import '../../models/announcement.dart';
import '../../models/schedule_event.dart';
import '../../theme/app_theme.dart';
import '../../theme/glass.dart';
import '../../widgets/common_widgets.dart';

class HubScreen extends StatefulWidget {
  const HubScreen({super.key});

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> {
  final _db = DatabaseHelper.instance;
  List<Announcement> _announcements = [];
  List<ScheduleEvent> _events = [];
  String _memberFilter = 'All';
  bool _loading = true;
  String _bias = 'Ren';

  static const _members = ['All', 'Ren', 'Kai', 'Leo', 'Jun'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final profile = await _db.getProfile();
    final announcements = await _db.getAnnouncements();
    final events = await _db.getScheduleEvents(member: _memberFilter);
    if (!mounted) return;
    setState(() {
      _bias = profile['bias_member'] as String;
      _announcements = announcements;
      _events = events;
      _loading = false;
    });
  }

  Future<void> _toggleReminder(ScheduleEvent e) async {
    await _db.toggleReminder(e);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                color: CortifyColors.coral,
                onRefresh: _load,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverToBoxAdapter(child: _buildPinned()),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: SectionHeader(
                          title: 'Smart Schedule',
                          subtitle: 'Auto-adjusted to your local time',
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: _buildMemberFilter()),
                    if (_events.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          message: 'No upcoming events for this filter.',
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          glassNavClearance(context),
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => _EventCard(
                              event: _events[i],
                              onToggleReminder: () =>
                                  _toggleReminder(_events[i]),
                            ),
                            childCount: _events.length,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: GlassPanel(
        tone: GlassTone.chrome,
        borderRadius: Glass.brLg,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Cortify',
                  style: GoogleFonts.fraunces(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: CortifyColors.charcoal,
                    letterSpacing: -0.4,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: CortifyColors.coral.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: CortifyColors.coral.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    'Bias: $_bias',
                    style: const TextStyle(
                      color: CortifyColors.coral,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'One community, one space, one heart.',
              style: TextStyle(
                color: CortifyColors.muted,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinned() {
    if (_announcements.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Official Updates',
            subtitle: 'Verified · real-time',
          ),
          ..._announcements.take(3).map(
                (a) => _AnnouncementTile(announcement: a),
              ),
        ],
      ),
    );
  }

  Widget _buildMemberFilter() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: _members
            .map(
              (m) => SoftChip(
                label: m,
                selected: _memberFilter == m,
                onTap: () {
                  setState(() => _memberFilter = m);
                  _load();
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  const _AnnouncementTile({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (announcement.isPinned)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.push_pin,
                    size: 14,
                    color: CortifyColors.coral,
                  ),
                ),
              Expanded(
                child: Text(
                  announcement.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: CortifyColors.coral.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  announcement.category,
                  style: const TextStyle(
                    fontSize: 11,
                    color: CortifyColors.coral,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            announcement.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: CortifyColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('MMM d · h:mm a')
                .format(announcement.postedAt.toLocal()),
            style: TextStyle(
              fontSize: 11,
              color: CortifyColors.muted.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.onToggleReminder});

  final ScheduleEvent event;
  final VoidCallback onToggleReminder;

  Color get _typeColor {
    switch (event.eventType) {
      case 'Live':
        return CortifyColors.coral;
      case 'Release':
        return CortifyColors.gold;
      case 'Fanmeet':
        return CortifyColors.sage;
      default:
        return const Color(0xFF7A6B9A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = event.startAt.toLocal();
    return GlassPanel(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: CortifyColors.coral.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('MMM').format(local).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: CortifyColors.coral,
                  ),
                ),
                Text(
                  DateFormat('d').format(local),
                  style: GoogleFonts.fraunces(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: CortifyColors.charcoal,
                  ),
                ),
                Text(
                  DateFormat('h:mm').format(local),
                  style: TextStyle(fontSize: 10, color: CortifyColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _typeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event.eventType,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _typeColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      event.member,
                      style: TextStyle(
                        fontSize: 11,
                        color: CortifyColors.muted,
                      ),
                    ),
                    if (event.isOfficial) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        size: 14,
                        color: CortifyColors.coral,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: CortifyColors.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggleReminder,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: Icon(
              event.reminderOn
                  ? Icons.notifications_active
                  : Icons.notifications_none,
              color: event.reminderOn
                  ? CortifyColors.coral
                  : CortifyColors.muted,
            ),
            tooltip: event.reminderOn ? 'Reminder on' : 'Set reminder',
          ),
        ],
      ),
    );
  }
}
