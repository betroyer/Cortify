import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../database/database_helper.dart';
import '../../models/community_post.dart';
import '../../models/fan_project.dart';
import '../../theme/app_theme.dart';
import '../../theme/glass.dart';
import '../../widgets/common_widgets.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseHelper.instance;
  late TabController _tabs;
  List<CommunityPost> _posts = [];
  List<FanProject> _projects = [];
  bool _loading = true;
  bool _showTranslation = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) _load();
    });
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  String get _board {
    switch (_tabs.index) {
      case 1:
        return 'Announcements';
      case 2:
        return 'Projects';
      default:
        return 'Feed';
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final posts = await _db.getPosts(board: _board);
    final projects = await _db.getFanProjects();
    if (!mounted) return;
    setState(() {
      _posts = posts;
      _projects = projects;
      _loading = false;
    });
  }

  Future<void> _heart(CommunityPost post) async {
    await _db.heartPost(post);
    await _load();
  }

  Future<void> _support(FanProject project) async {
    await _db.supportProject(project);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You\'re supporting "${project.title}"')),
    );
  }

  Future<void> _compose() async {
    final controller = TextEditingController();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: GlassPanel(
            tone: GlassTone.chrome,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: CortifyColors.sand,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Share with Cortis',
                  style: GoogleFonts.fraunces(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Be kind. Toxicity isn\'t welcome here.',
                  style: TextStyle(color: CortifyColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'What\'s on your Cortis heart?',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                  child: const Text('Post'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == null || result.isEmpty) return;
    final profile = await _db.getProfile();
    await _db.insertPost(
      CommunityPost(
        author: profile['display_name'] as String,
        content: result,
        createdAt: DateTime.now(),
        board: 'Feed',
        language: 'en',
      ),
    );
    _tabs.animateTo(0);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            tooltip: _showTranslation ? 'Hide translations' : 'Show translations',
            onPressed: () =>
                setState(() => _showTranslation = !_showTranslation),
            icon: Icon(
              _showTranslation ? Icons.translate : Icons.translate_outlined,
              color: CortifyColors.coral,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: CortifyColors.coral,
          unselectedLabelColor: CortifyColors.muted,
          indicatorColor: CortifyColors.coral,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'Official'),
            Tab(text: 'Projects'),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 64),
        child: FloatingActionButton(
          onPressed: _compose,
          tooltip: 'New post',
          child: const Icon(Icons.edit),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _PostList(
                  posts: _posts,
                  showTranslation: _showTranslation,
                  onHeart: _heart,
                ),
                _PostList(
                  posts: _posts,
                  showTranslation: _showTranslation,
                  onHeart: _heart,
                ),
                _ProjectList(projects: _projects, onSupport: _support),
              ],
            ),
    );
  }
}

class _PostList extends StatelessWidget {
  const _PostList({
    required this.posts,
    required this.showTranslation,
    required this.onHeart,
  });

  final List<CommunityPost> posts;
  final bool showTranslation;
  final void Function(CommunityPost) onHeart;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const EmptyState(
        message: 'No posts yet. Be the first to share the love.',
        icon: Icons.forum_outlined,
      );
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 12, 16, glassNavClearance(context)),
      itemCount: posts.length,
      itemBuilder: (context, i) {
        final p = posts[i];
        return GlassPanel(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MemberAvatar(name: p.author),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              p.author,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            if (p.isOfficial) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 14,
                                color: CortifyColors.coral,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          DateFormat('MMM d · h:mm a')
                              .format(p.createdAt.toLocal()),
                          style: TextStyle(
                            fontSize: 11,
                            color: CortifyColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(p.content, style: const TextStyle(height: 1.4, fontSize: 14)),
              if (showTranslation &&
                  p.translatedContent != null &&
                  p.translatedContent!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: CortifyColors.coral.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Translation',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: CortifyColors.coral,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.translatedContent!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: CortifyColors.charcoal,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              InkWell(
                onTap: () => onHeart(p),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite,
                        size: 18,
                        color: CortifyColors.coral,
                      ),
                      const SizedBox(width: 6),
                      Text('${p.hearts}', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProjectList extends StatelessWidget {
  const _ProjectList({required this.projects, required this.onSupport});

  final List<FanProject> projects;
  final void Function(FanProject) onSupport;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const EmptyState(
        message: 'No fan projects yet.',
        icon: Icons.celebration_outlined,
      );
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 12, 16, glassNavClearance(context)),
      itemCount: projects.length,
      itemBuilder: (context, i) {
        final p = projects[i];
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
                      p.title,
                      style: GoogleFonts.fraunces(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: CortifyColors.coral.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      p.status,
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
                p.description,
                style: TextStyle(color: CortifyColors.muted, height: 1.4),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: CortifyColors.muted),
                  const SizedBox(width: 4),
                  Text(
                    p.organizer,
                    style: TextStyle(fontSize: 12, color: CortifyColors.muted),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('MMM d').format(p.eventDate),
                    style: TextStyle(fontSize: 12, color: CortifyColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '${p.supporters} supporters',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => onSupport(p),
                    child: const Text('I\'ll join'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
