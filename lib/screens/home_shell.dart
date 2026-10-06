import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/glass.dart';
import 'community/community_screen.dart';
import 'diary/diary_screen.dart';
import 'hub/hub_screen.dart';
import 'library/library_screen.dart';
import 'support/support_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _pages = const [
    HubScreen(),
    CommunityScreen(),
    LibraryScreen(),
    SupportScreen(),
    DiaryScreen(),
  ];

  static const _tabs = [
    (CupertinoIcons.house_fill, CupertinoIcons.house, 'Hub'),
    (CupertinoIcons.chat_bubble_2_fill, CupertinoIcons.chat_bubble_2, 'Community'),
    (CupertinoIcons.music_note_list, CupertinoIcons.music_note_list, 'Library'),
    (CupertinoIcons.hand_raised_fill, CupertinoIcons.hand_raised, 'Support'),
    (CupertinoIcons.book_fill, CupertinoIcons.book, 'Diary'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackdrop(),
          IndexedStack(index: _index, children: _pages),
        ],
      ),
      // iOS 18-style floating glass capsule tab bar
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 8 + (bottomPad > 0 ? 0 : 8)),
        child: ClipRRect(
          borderRadius: Glass.brPill,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
            child: Container(
              decoration: BoxDecoration(
                color: Glass.fillTab,
                borderRadius: Glass.brPill,
                border: Border.all(color: Glass.stroke, width: 0.5),
                boxShadow: Glass.lift,
              ),
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 4),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Row(
                    children: List.generate(_tabs.length, (i) {
                      final tab = _tabs[i];
                      return Expanded(
                        child: _IosTabItem(
                          selectedIcon: tab.$1,
                          icon: tab.$2,
                          label: tab.$3,
                          selected: _index == i,
                          onTap: () => setState(() => _index = i),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IosTabItem extends StatelessWidget {
  const _IosTabItem({
    required this.selectedIcon,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData selectedIcon;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? CortifyColors.coral : CortifyColors.muted;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: SizedBox(
          height: 48,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  selected ? selectedIcon : icon,
                  key: ValueKey(selected),
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
