import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class _CommunityScreenState extends State<CommunityScreen> {
  final _db = DatabaseHelper.instance;
  int _segment = 0;
  List<CommunityPost> _posts = [];
  List<FanProject> _projects = [];
  bool _loading = true;
  bool _showTranslation = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String get _board {
    switch (_segment) {
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
    final result = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) {
        return Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.only(
              top: MediaQuery.paddingOf(ctx).top + 40,
            ),
            child: GlassPanel(
              tone: GlassTone.chrome,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                20 + MediaQuery.viewInsetsOf(ctx).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      const Spacer(),
                      const Text(
                        'New Post',
                        style: TextStyle(
                          fontFamily: '.SF Pro Text',
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                      const Spacer(),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () =>
                            Navigator.pop(ctx, controller.text.trim()),
                        child: const Text(
                          'Post',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be kind. Toxicity isn\'t welcome here.',
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      color: CortifyColors.muted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CupertinoTextField(
                    controller: controller,
                    maxLines: 5,
                    placeholder: 'What\'s on your Cortis heart?',
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
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
    setState(() => _segment = 0);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      extendBodyBehindAppBar: false,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: GlassFab(
          onPressed: _compose,
          icon: CupertinoIcons.pencil,
          tooltip: 'New post',
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            IosLargeTitle(
              'Community',
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () =>
                    setState(() => _showTranslation = !_showTranslation),
                child: Icon(
                  CupertinoIcons.textformat,
                  color: _showTranslation
                      ? CortifyColors.coral
                      : CortifyColors.muted,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _segment,
                backgroundColor: Colors.black.withValues(alpha: 0.06),
                thumbColor: Colors.white.withValues(alpha: 0.92),
                children: const {
                  0: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Feed'),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Official'),
                  ),
                  2: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Projects'),
                  ),
                },
                onValueChanged: (v) {
                  if (v == null) return;
                  setState(() => _segment = v);
                  _load();
                },
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _segment == 2
                      ? _ProjectList(
                          projects: _projects,
                          onSupport: _support,
                        )
                      : _PostList(
                          posts: _posts,
                          showTranslation: _showTranslation,
                          onHeart: _heart,
                        ),
            ),
          ],
        ),
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
        icon: CupertinoIcons.chat_bubble_2,
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(0, 0, 0, glassNavClearance(context)),
      itemCount: posts.length,
      itemBuilder: (context, i) {
        final p = posts[i];
        return GlassPanel(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
                              style: const TextStyle(
                                fontFamily: '.SF Pro Text',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            if (p.isOfficial) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                CupertinoIcons.checkmark_seal_fill,
                                size: 13,
                                color: CortifyColors.coral,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          DateFormat('MMM d · h:mm a')
                              .format(p.createdAt.toLocal()),
                          style: const TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 12,
                            color: CortifyColors.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                p.content,
                style: const TextStyle(
                  fontFamily: '.SF Pro Text',
                  height: 1.35,
                  fontSize: 16,
                ),
              ),
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
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Translation',
                        style: TextStyle(
                          fontFamily: '.SF Pro Text',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: CortifyColors.coral,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.translatedContent!,
                        style: const TextStyle(
                          fontFamily: '.SF Pro Text',
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              CupertinoButton(
                padding: const EdgeInsets.only(top: 8),
                minimumSize: Size.zero,
                onPressed: () => onHeart(p),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.heart_fill,
                      size: 18,
                      color: CortifyColors.coral,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${p.hearts}',
                      style: const TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 14,
                        color: CortifyColors.label,
                      ),
                    ),
                  ],
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
        icon: CupertinoIcons.star,
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(0, 0, 0, glassNavClearance(context)),
      itemCount: projects.length,
      itemBuilder: (context, i) {
        final p = projects[i];
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
                      p.title,
                      style: const TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    p.status,
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
                p.description,
                style: const TextStyle(
                  fontFamily: '.SF Pro Text',
                  color: CortifyColors.muted,
                  height: 1.35,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '${p.supporters} supporters',
                    style: const TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
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
