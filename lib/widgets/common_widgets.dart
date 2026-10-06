import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/glass.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    // iOS section header style — uppercase footnote above grouped lists
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 20, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.08,
                    color: CortifyColors.muted,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 12,
                      color: CortifyColors.tertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? CupertinoIcons.heart,
              size: 48,
              color: CortifyColors.tertiary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: '.SF Pro Text',
                color: CortifyColors.muted,
                fontSize: 17,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// iOS segmented-style capsule chips.
class SoftChip extends StatelessWidget {
  const SoftChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(44, 32),
        onPressed: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? CortifyColors.coral
                : Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? CortifyColors.coral : Glass.stroke,
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : CortifyColors.label,
            ),
          ),
        ),
      ),
    );
  }
}

class MemberAvatar extends StatelessWidget {
  const MemberAvatar({super.key, required this.name, this.size = 40});

  final String name;
  final double size;

  static const _colors = {
    'Ren': Color(0xFFE85D4C),
    'Kai': Color(0xFF5B8A7A),
    'Leo': Color(0xFFD4A574),
    'Jun': Color(0xFF7A6B9A),
    'All': Color(0xFF8E8E93),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[name] ?? CortifyColors.coral;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 0.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: TextStyle(
          fontFamily: '.SF Pro Text',
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}

double glassNavClearance(BuildContext context) {
  return 96 + MediaQuery.paddingOf(context).bottom;
}
