import 'package:flutter/cupertino.dart';
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
                  SliverToBoxAdapter(
                    child: IosLargeTitle(
                      'Cortify',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: CortifyColors.coral.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Bias · $_bias',
                          style: const TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: CortifyColors.coral,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Text(
                        'One community, one space, one heart.',
                        style: TextStyle(
                          fontFamily: '.SF Pro Text',
                          fontSize: 15,
                          color: CortifyColors.muted,
                        ),
                      ),
                    ),
                  ),
                  if (_announcements.isNotEmpty) ...[
                    const SliverToBoxAdapter(
                      child: SectionHeader(
                        title: 'Official Updates',
                        subtitle: 'Verified · real-time',
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: GlassGroupedList(
                        children: _announcements
                            .take(3)
                            .map((a) => _AnnouncementRow(announcement: a))
                            .toList(),
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Smart Schedule',
                      subtitle: 'Local time · member filter',
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    ),
                  ),
                  const OmitSliver(height: 12),
                  if (_events.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        message: 'No upcoming events for this filter.',
                        icon: CupertinoIcons.calendar,
                      ),
                    )
                  else
                    ..._events.map(
                      (e) => OmitSliver(
                        child: _EventCard(
                          event: e,
                          onToggleReminder: () => _toggleReminder(e),
                        ),
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

/// Tiny helper so we can mix widgets into sliver lists cleanly.
class OmitSliver extends StatelessWidget {
  const OmitSliver({super.key, this.child, this.height});

  final Widget? child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (height != null) {
      return SliverToBoxAdapter(child: SizedBox(height: height));
    }
    return SliverToBoxAdapter(child: child);
  }
}

class _AnnouncementRow extends StatelessWidget {
  const _AnnouncementRow({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (announcement.isPinned)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(
                    CupertinoIcons.pin_fill,
                    size: 13,
                    color: CortifyColors.coral,
                  ),
                ),
              Expanded(
                child: Text(
                  announcement.title,
                  style: const TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
              ),
              Text(
                announcement.category,
                style: const TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 13,
                  color: CortifyColors.coral,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            announcement.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 15,
              color: CortifyColors.muted,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMM d · h:mm a')
                .format(announcement.postedAt.toLocal()),
            style: const TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 12,
              color: CortifyColors.tertiary,
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
        return CortifyColors.systemBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = event.startAt.toLocal();
    return GlassPanel(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: CortifyColors.coral.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('MMM').format(local).toUpperCase(),
                  style: const TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: CortifyColors.coral,
                  ),
                ),
                Text(
                  DateFormat('d').format(local),
                  style: const TextStyle(
                    fontFamily: '.SF Pro Display',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: CortifyColors.label,
                  ),
                ),
                Text(
                  DateFormat('h:mm').format(local),
                  style: const TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 10,
                    color: CortifyColors.muted,
                  ),
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
                    Text(
                      event.eventType,
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _typeColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      event.member,
                      style: const TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 12,
                        color: CortifyColors.muted,
                      ),
                    ),
                    if (event.isOfficial) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        size: 13,
                        color: CortifyColors.coral,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event.title,
                  style: const TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.description,
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
            onPressed: onToggleReminder,
            child: Icon(
              event.reminderOn
                  ? CupertinoIcons.bell_fill
                  : CupertinoIcons.bell,
              color: event.reminderOn
                  ? CortifyColors.coral
                  : CortifyColors.muted,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
