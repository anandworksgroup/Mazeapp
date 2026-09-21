import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/constants/catalog.dart';
import '../../core/localization/l10n.dart';
import '../../core/widgets/chunky.dart';
import '../character/animated_character.dart';
import '../character/character_painter.dart';
import '../maze/generator/maze_generator.dart';
import '../maze/models/maze_size.dart';
import '../maze/view/maze_painters.dart';
import '../themes/world_art.dart';

void showLockedHint(BuildContext context, String text) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.lock_rounded, color: Colors.white),
      const SizedBox(width: 10),
      Expanded(child: Text(text)),
    ]),
    duration: const Duration(seconds: 2),
  ));
}

// ---- characters ------------------------------------------------------------

/// Big swipeable carousel used in the Play flow.
class CharacterCarousel extends StatefulWidget {
  const CharacterCarousel({super.key, this.onFocusLocked});

  /// Tells the parent whether the character in the middle is still locked.
  final ValueChanged<bool>? onFocusLocked;

  @override
  State<CharacterCarousel> createState() => _CharacterCarouselState();
}

class _CharacterCarouselState extends State<CharacterCarousel> {
  late final PageController _pages;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    final selected = context.appRead.player.selectedCharacter;
    _index = Catalog.characters.indexWhere((c) => c.id == selected).clamp(0, 99);
    _pages = PageController(initialPage: _index, viewportFraction: 0.62);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final next = (_index + delta).clamp(0, Catalog.characters.length - 1);
    _pages.animateToPage(next, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final l10n = context.l10n;
    final p = context.palette;
    final current = Catalog.characters[_index];
    final unlocked = app.characters.contains(current.id);

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              RoundButton(icon: Icons.chevron_left_rounded, tooltip: MaterialLocalizations.of(context).previousPageTooltip, onTap: _index > 0 ? () => _go(-1) : null, size: 46),
              Expanded(
                child: PageView.builder(
                  controller: _pages,
                  itemCount: Catalog.characters.length,
                  onPageChanged: (i) {
                    setState(() => _index = i);
                    final c = Catalog.characters[i];
                    final open = app.characters.contains(c.id);
                    widget.onFocusLocked?.call(!open);
                    if (open) app.selectCharacter(c.id);
                  },
                  itemBuilder: (context, i) {
                    final c = Catalog.characters[i];
                    final open = app.characters.contains(c.id);
                    final focused = i == _index;
                    return AnimatedScale(
                      scale: focused ? 1 : 0.78,
                      duration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: () => i == _index
                            ? (open ? null : showLockedHint(context, l10n.unlockText(c.unlock)))
                            : _go(i - _index),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedCharacter(
                              def: c,
                              pose: focused && open ? CharacterPose.happy : CharacterPose.idle,
                              size: 220,
                              animate: focused && app.settings.animations,
                              greyed: !open,
                            ),
                            if (!open) const LockBadge(size: 56),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              RoundButton(
                  icon: Icons.chevron_right_rounded,
                  tooltip: MaterialLocalizations.of(context).nextPageTooltip,
                  onTap: _index < Catalog.characters.length - 1 ? () => _go(1) : null,
                  size: 46),
            ],
          ),
        ),
        OutlineText(current.name, size: 38, color: unlocked ? Colors.white : p.locked),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: unlocked
              ? const SizedBox.shrink()
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: p.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: p.outline, width: p.outlineWidth),
                  ),
                  child: Text('🔒 ${l10n.unlockText(current.unlock)}',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: p.ink)),
                ),
        ),
        const SizedBox(height: 8),
        // Dots.
        Wrap(
          spacing: 6,
          children: [
            for (var i = 0; i < Catalog.characters.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: i == _index ? 22 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: i == _index
                      ? p.orange
                      : (app.characters.contains(Catalog.characters[i].id) ? p.card : p.locked),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: p.outline, width: 1.5),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Grid of every character (Characters screen).
class CharacterGrid extends StatelessWidget {
  const CharacterGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final l10n = context.l10n;
    final p = context.palette;
    return LayoutBuilder(builder: (context, box) {
      final columns = (box.maxWidth / 170).floor().clamp(2, 5);
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        itemCount: Catalog.characters.length,
        itemBuilder: (context, i) {
          final c = Catalog.characters[i];
          final open = app.characters.contains(c.id);
          final selected = app.player.selectedCharacter == c.id;
          return CuteCard(
            selected: selected,
            padding: const EdgeInsets.all(8),
            onTap: () => open ? app.selectCharacter(c.id) : showLockedHint(context, l10n.unlockText(c.unlock)),
            child: Column(
              children: [
                Expanded(
                  child: Stack(alignment: Alignment.center, children: [
                    AnimatedCharacter(
                      def: c,
                      pose: selected ? CharacterPose.happy : CharacterPose.idle,
                      size: 110,
                      animate: selected && app.settings.animations,
                      greyed: !open,
                    ),
                    if (!open) const LockBadge(size: 40),
                  ]),
                ),
                Text(c.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: p.ink)),
                Text(
                  open ? (selected ? '✓ ${l10n.selected}' : ' ') : l10n.unlockText(c.unlock),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: selected ? p.playEdge : p.subInk),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

// ---- worlds ----------------------------------------------------------------

class WorldGrid extends StatelessWidget {
  const WorldGrid({super.key, this.shrinkWrap = false});

  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final l10n = context.l10n;
    final p = context.palette;
    return LayoutBuilder(builder: (context, box) {
      final columns = (box.maxWidth / 190).floor().clamp(2, 4);
      return GridView.builder(
        shrinkWrap: shrinkWrap,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.92,
        ),
        itemCount: Catalog.worlds.length,
        itemBuilder: (context, i) {
          final w = Catalog.worlds[i];
          final open = app.worlds.contains(w.id);
          final selected = app.player.selectedTheme == w.id;
          return CuteCard(
            selected: selected,
            padding: const EdgeInsets.all(6),
            onTap: () => open ? app.selectWorld(w.id) : showLockedHint(context, l10n.unlockText(w.unlock)),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(fit: StackFit.expand, children: [
                      CustomPaint(painter: ScenePainter(world: w, dim: !open)),
                      Center(
                        child: CustomPaint(
                          size: const Size.square(64),
                          painter: _GoalIcon(w.goal),
                        ),
                      ),
                      if (!open) const Center(child: LockBadge(size: 44)),
                    ]),
                  ),
                ),
                const SizedBox(height: 6),
                Text(l10n.worldName(w.id),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: p.ink)),
                Text(
                  open ? (selected ? '✓ ${l10n.selected}' : ' ') : l10n.unlockText(w.unlock),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: selected ? p.playEdge : p.subInk),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class _GoalIcon extends CustomPainter {
  _GoalIcon(this.kind);
  final GoalKind kind;

  @override
  void paint(Canvas canvas, Size size) =>
      WorldArt.goal(canvas, kind, size.center(Offset.zero), size.width);

  @override
  bool shouldRepaint(_GoalIcon old) => old.kind != kind;
}

// ---- sizes -----------------------------------------------------------------

class SizeList extends StatelessWidget {
  const SizeList({super.key});

  static final _previews = {
    for (final s in MazeSize.all)
      s.id: MazeGeometry(const MazeGenerator().generate(seed: 2026 + s.level, size: s)),
  };

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final l10n = context.l10n;
    final p = context.palette;
    final world = Catalog.world(app.player.selectedTheme);
    return LayoutBuilder(builder: (context, box) {
      final columns = box.maxWidth > 700 ? 3 : 2;
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.82,
        ),
        itemCount: MazeSize.all.length,
        itemBuilder: (context, i) {
          final s = MazeSize.all[i];
          final open = app.sizes.contains(s.id);
          final selected = app.player.selectedSize == s.id;
          final best = app.stats.sizes[s.id]?.bestTimeMs;
          return CuteCard(
            selected: selected,
            padding: const EdgeInsets.all(8),
            onTap: () => open
                ? app.selectSize(s.id)
                : showLockedHint(context, l10n.unlockText(Catalog.sizeUnlocks[s.id]!)),
            child: Column(
              children: [
                Expanded(
                  child: Stack(fit: StackFit.expand, children: [
                    Opacity(
                      opacity: open ? 1 : 0.35,
                      child: CustomPaint(
                        painter: _ThumbPainter(_previews[s.id]!, world),
                      ),
                    ),
                    if (!open) const Center(child: LockBadge(size: 44)),
                  ]),
                ),
                const SizedBox(height: 6),
                Text(l10n.sizeName(s.id),
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: p.ink)),
                Text(s.dimensions,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: p.orange)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var d = 1; d <= 6; d++)
                      Container(
                        margin: const EdgeInsets.all(1.5),
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: d <= s.level ? p.pink : p.locked.withValues(alpha: 0.4),
                        ),
                      ),
                  ],
                ),
                if (best != null)
                  Text('⏱ ${l10n.clock(best)}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: p.subInk))
                else if (!open)
                  Text(l10n.unlockText(Catalog.sizeUnlocks[s.id]!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: p.subInk)),
              ],
            ),
          );
        },
      );
    });
  }
}

class _ThumbPainter extends CustomPainter {
  _ThumbPainter(this.geometry, this.world);

  final MazeGeometry geometry;
  final WorldDef world;

  @override
  void paint(Canvas canvas, Size size) => paintMazeThumbnail(canvas, size, geometry, world);

  @override
  bool shouldRepaint(_ThumbPainter old) => old.geometry != geometry || old.world != world;
}
