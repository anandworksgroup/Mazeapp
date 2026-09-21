import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/app_scope.dart';
import '../../../app/theme.dart';
import '../../../core/constants/catalog.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/widgets/chunky.dart';
import '../../character/animated_character.dart';
import '../../character/character_painter.dart';
import '../engine/game_session.dart';

/// Full-screen celebration after reaching the goal. Always encouraging:
/// finishing earns at least one star, and the next maze is one tap away.
class ResultPanel extends StatefulWidget {
  const ResultPanel({
    super.key,
    required this.result,
    required this.session,
    required this.world,
    required this.character,
    required this.daily,
    required this.onNext,
    required this.onChange,
    required this.onHome,
  });

  final CompletionResult result;
  final GameSession session;
  final WorldDef world;
  final CharacterDef character;
  final bool daily;
  final VoidCallback onNext;
  final VoidCallback onChange;
  final VoidCallback onHome;

  @override
  State<ResultPanel> createState() => _ResultPanelState();
}

class _ResultPanelState extends State<ResultPanel> with SingleTickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void initState() {
    super.initState();
    // Reduced motion: show the finished state straight away.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !context.appRead.settings.animations) _in.value = 1;
    });
  }

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final animate = context.app.settings.animations;
    final r = widget.result;
    final rating = switch (r.stars) {
      3 => l10n.ratingExcellent,
      2 => l10n.ratingGood,
      _ => l10n.ratingCompleted,
    };

    Widget stat(String label, String value) => Expanded(
          child: Column(children: [
            Text(label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: p.subInk)),
            const SizedBox(height: 2),
            FittedBox(
              child: Text(value,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: p.ink)),
            ),
          ]),
        );

    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.45),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: ScaleTransition(
                  scale: CurvedAnimation(
                      parent: _in, curve: const Interval(0, 0.35, curve: Curves.elasticOut)),
                  child: CuteCard(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedCharacter(
                          def: widget.character,
                          pose: CharacterPose.celebrate,
                          size: 110,
                          animate: animate,
                        ),
                        OutlineText(l10n.youDidIt, size: 34, color: p.yellow),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < 3; i++)
                              ScaleTransition(
                                scale: CurvedAnimation(
                                  parent: _in,
                                  curve: Interval(0.3 + i * 0.13, 0.55 + i * 0.13,
                                      curve: Curves.elasticOut),
                                ),
                                child: Icon(
                                  Icons.star_rounded,
                                  size: i == 1 ? 64 : 52,
                                  color: i < r.stars ? p.yellow : p.locked.withValues(alpha: 0.5),
                                  shadows: [
                                    Shadow(color: p.outline, offset: const Offset(0, 3)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        Text(rating,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: p.ink)),
                        if (r.isBestTime)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: _Tag(text: '🏅 ${l10n.newBest}', color: p.yellow),
                          ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                          decoration: BoxDecoration(
                            color: p.cardAlt,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(children: [
                            stat(l10n.time, l10n.clock(widget.session.elapsedMs)),
                            stat(l10n.moves, '${widget.session.moves}'),
                            stat(l10n.maze, widget.session.size.dimensions),
                          ]),
                        ),
                        if (r.hasUnlocks) ...[
                          const SizedBox(height: 12),
                          Text(l10n.newUnlocks,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: p.play)),
                          const SizedBox(height: 6),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final id in r.newCharacters)
                                Column(mainAxisSize: MainAxisSize.min, children: [
                                  AnimatedCharacter(
                                      def: Catalog.character(id),
                                      pose: CharacterPose.wave,
                                      size: 62,
                                      animate: animate),
                                  Text(Catalog.character(id).name,
                                      style: const TextStyle(fontWeight: FontWeight.w900)),
                                ]),
                              for (final id in r.newWorlds)
                                _Tag(text: '🗺️ ${l10n.worldName(id)}', color: p.blue),
                              for (final id in r.newSizes)
                                _Tag(text: '🧩 ${l10n.sizeName(id)}', color: p.purple),
                            ],
                          ),
                        ],
                        if (r.newAchievements.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(l10n.achievementUnlocked,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: p.orange)),
                          const SizedBox(height: 6),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final a in r.newAchievements)
                                _Tag(text: '${a.emoji} ${l10n.achievementTitle(a)}', color: p.orange),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        ChunkyButton(
                          onTap: widget.onNext,
                          label: widget.daily ? l10n.newMaze : l10n.nextMaze,
                          icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34),
                          color: p.play,
                          expand: true,
                          height: 66,
                          fontSize: 24,
                        ),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: ChunkyButton(
                              onTap: widget.onChange,
                              label: l10n.change,
                              icon: const Icon(Icons.tune_rounded, color: Colors.white),
                              color: p.blue,
                              height: 52,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ChunkyButton(
                              onTap: widget.onHome,
                              label: l10n.home,
                              icon: const Icon(Icons.home_rounded, color: Colors.white),
                              color: p.orange,
                              height: 52,
                              fontSize: 18,
                            ),
                          ),
                        ]),
                      ],
                    ),
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

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w900, color: p.ink)),
    );
  }
}
