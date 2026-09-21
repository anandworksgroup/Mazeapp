import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/constants/catalog.dart';
import '../../features/themes/world_art.dart';
import 'chunky.dart';

/// Standard menu screen: illustrated world backdrop, a round back button and
/// a big outlined title.
class ScreenFrame extends StatelessWidget {
  const ScreenFrame({
    super.key,
    required this.title,
    required this.child,
    this.worldId,
    this.trailing,
  });

  final String title;
  final Widget child;
  final String? worldId;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final world = Catalog.world(worldId ?? app.player.selectedTheme);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: world.skyBottom,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: ScenePainter(world: world, dim: dark)),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: Row(
                    children: [
                      RoundButton(
                        icon: Directionality.of(context) == TextDirection.rtl
                            ? Icons.arrow_forward_rounded
                            : Icons.arrow_back_rounded,
                        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: OutlineText(title, size: 30, maxLines: 1),
                        ),
                      ),
                      if (trailing != null) trailing!,
                    ],
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Keeps menus readable on tablets: a centred column of sensible width.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = 640});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      );
}
