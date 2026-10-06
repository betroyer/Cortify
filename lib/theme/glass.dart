import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';

/// iPhone-style system materials for Cortify.
/// Ultra-thin blur chrome + inset grouped glass — coral stays the tint.
class Glass {
  static const radiusLg = 22.0;
  static const radiusMd = 14.0; // iOS grouped inset
  static const radiusSm = 10.0;
  static const radiusPill = 100.0;

  static BorderRadius get brLg => BorderRadius.circular(radiusLg);
  static BorderRadius get brMd => BorderRadius.circular(radiusMd);
  static BorderRadius get brSm => BorderRadius.circular(radiusSm);
  static BorderRadius get brPill => BorderRadius.circular(radiusPill);

  /// Ultra-thin material fills (iOS-like translucency).
  static const fillChrome = Color(0x8CFFFFFF); // ~55%
  static const fillPanel = Color(0xB8FFFFFF); // ~72% grouped cell
  static const fillSoft = Color(0x66FFFFFF);
  static const fillTab = Color(0x99F2F2F7);

  static const stroke = Color(0x59FFFFFF);
  static const strokeSoft = Color(0x33FFFFFF);
  static const separator = Color(0x33787880);

  static List<BoxShadow> get lift => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get liftSm => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}

/// Soft system wallpaper — light gray-pink wash so materials can frost.
class AmbientBackdrop extends StatelessWidget {
  const AmbientBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF2F2F7), // iOS systemGroupedBackground
              Color(0xFFFFF0ED),
              Color(0xFFE8F2EE),
              Color(0xFFF2F2F7),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _Blob(
              alignment: Alignment(-0.9, -0.7),
              size: 320,
              color: Color(0x40FF8A7A),
            ),
            _Blob(
              alignment: Alignment(1.0, -0.1),
              size: 260,
              color: Color(0x35D4A574),
            ),
            _Blob(
              alignment: Alignment(-0.7, 0.85),
              size: 280,
              color: Color(0x355B8A7A),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.alignment,
    required this.size,
    required this.color,
  });

  final Alignment alignment;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 56, sigmaY: 56),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}

enum GlassTone { chrome, panel, soft }

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.tone = GlassTone.panel,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final GlassTone tone;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? Glass.brMd;
    final fill = switch (tone) {
      GlassTone.chrome => Glass.fillChrome,
      GlassTone.panel => Glass.fillPanel,
      GlassTone.soft => Glass.fillSoft,
    };
    final blur = switch (tone) {
      GlassTone.chrome => 36.0,
      GlassTone.panel => 24.0,
      GlassTone.soft => 0.0,
    };

    Widget frosted = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: Border.all(
          color: tone == GlassTone.soft ? Glass.strokeSoft : Glass.stroke,
          width: 0.5,
        ),
      ),
      child: child,
    );

    if (blur > 0) {
      frosted = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: frosted,
        ),
      );
    } else {
      frosted = ClipRRect(borderRadius: radius, child: frosted);
    }

    Widget panel = Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: tone == GlassTone.soft ? null : Glass.liftSm,
      ),
      child: frosted,
    );

    if (margin != null) {
      panel = Padding(padding: margin!, child: panel);
    }

    if (onTap != null) {
      panel = CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: panel,
      );
    }

    return panel;
  }
}

/// iOS inset grouped list — one frosted container, hairline separators.
class GlassGroupedList extends StatelessWidget {
  const GlassGroupedList({
    super.key,
    required this.children,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i < children.length - 1) {
        rows.add(
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(height: 0.5, color: Glass.separator),
          ),
        );
      }
    }
    return GlassPanel(
      margin: margin,
      padding: EdgeInsets.zero,
      borderRadius: Glass.brMd,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: rows,
      ),
    );
  }
}

class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
}

/// Translucent nav bar — iOS large-title companion (inline title).
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.leading,
    this.large = false,
  });

  final Widget title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final bool large;

  @override
  Size get preferredSize {
    final h = large ? 96.0 : 44.0;
    return Size.fromHeight(h + (bottom?.preferredSize.height ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return PreferredSize(
      preferredSize: Size.fromHeight(preferredSize.height + top),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            decoration: const BoxDecoration(
              color: Glass.fillChrome,
              border: Border(
                bottom: BorderSide(color: Glass.strokeSoft, width: 0.5),
              ),
            ),
            padding: EdgeInsets.only(top: top),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: large ? 96 : 44,
                  child: NavigationToolbar(
                    leading: leading ??
                        (Navigator.canPop(context)
                            ? CupertinoNavigationBarBackButton(
                                color: CortifyColors.coral,
                                onPressed: () => Navigator.maybePop(context),
                              )
                            : null),
                    middle: DefaultTextStyle(
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: large ? 17 : 17,
                        fontWeight: FontWeight.w600,
                        color: CortifyColors.label,
                        letterSpacing: -0.4,
                      ),
                      child: title,
                    ),
                    trailing: actions == null
                        ? null
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: actions!,
                          ),
                    centerMiddle: !large,
                  ),
                ),
                ?bottom,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Scroll large title — iOS HIG pattern for root tabs.
class IosLargeTitle extends StatelessWidget {
  const IosLargeTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: '.SF Pro Display',
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.37,
                height: 1.1,
                color: CortifyColors.label,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// iOS-style circular glass FAB.
class GlassFab extends StatelessWidget {
  const GlassFab({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final btn = CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: GlassPanel(
        tone: GlassTone.chrome,
        borderRadius: Glass.brPill,
        width: 56,
        height: 56,
        child: Icon(icon, color: CortifyColors.coral, size: 26),
      ),
    );
    if (tooltip == null) return btn;
    return Tooltip(message: tooltip!, child: btn);
  }
}
