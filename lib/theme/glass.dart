import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Glass material for Cortify — frosted panels over an ambient mesh.
class Glass {
  static const radiusLg = 20.0;
  static const radiusMd = 16.0;
  static const radiusSm = 12.0;

  static BorderRadius get brLg => BorderRadius.circular(radiusLg);
  static BorderRadius get brMd => BorderRadius.circular(radiusMd);
  static BorderRadius get brSm => BorderRadius.circular(radiusSm);

  static const fillChrome = Color(0xA6FFFFFF);
  static const fillPanel = Color(0xC2FFFFFF);
  static const fillSoft = Color(0x99FFFFFF);
  static const stroke = Color(0xE6FFFFFF);
  static const strokeSoft = Color(0x66FFFFFF);

  static List<BoxShadow> get lift => [
        BoxShadow(
          color: CortifyColors.charcoal.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: CortifyColors.coral.withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get liftSm => [
        BoxShadow(
          color: CortifyColors.charcoal.withValues(alpha: 0.06),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ];
}

/// Soft coral / cream / sage mesh so frosted glass has something to blur.
class AmbientBackdrop extends StatelessWidget {
  const AmbientBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8F5),
              Color(0xFFFFE8E2),
              Color(0xFFF5F0EC),
              Color(0xFFE8F2EE),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _Blob(
              alignment: Alignment(-1.1, -0.85),
              size: 280,
              color: Color(0x55FF8A7A),
            ),
            _Blob(
              alignment: Alignment(1.15, -0.2),
              size: 220,
              color: Color(0x44D4A574),
            ),
            _Blob(
              alignment: Alignment(-0.8, 0.75),
              size: 260,
              color: Color(0x445B8A7A),
            ),
            _Blob(
              alignment: Alignment(0.9, 0.95),
              size: 200,
              color: Color(0x40E85D4C),
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
        imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
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
      GlassTone.chrome => 22.0,
      GlassTone.panel => 12.0,
      GlassTone.soft => 0.0,
    };
    final shadows = tone == GlassTone.chrome ? Glass.lift : Glass.liftSm;

    Widget frosted = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: Border.all(
          color: tone == GlassTone.soft ? Glass.strokeSoft : Glass.stroke,
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

    // Shadow outside clip so soft lift is visible.
    Widget panel = Container(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: shadows),
      child: frosted,
    );

    if (margin != null) {
      panel = Padding(padding: margin!, child: panel);
    }

    if (onTap != null) {
      panel = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: CortifyColors.coral.withValues(alpha: 0.12),
          highlightColor: CortifyColors.coral.withValues(alpha: 0.06),
          child: panel,
        ),
      );
    }

    return panel;
  }
}

class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
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

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.leading,
  });

  final Widget title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: leading,
      title: title,
      actions: actions,
      bottom: bottom,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: const BoxDecoration(
              color: Glass.fillChrome,
              border: Border(
                bottom: BorderSide(color: Glass.strokeSoft),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
