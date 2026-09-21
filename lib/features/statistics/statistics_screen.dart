import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/constants/catalog.dart';
import '../../core/localization/l10n.dart';
import '../../core/widgets/chunky.dart';
import '../../core/widgets/screen_frame.dart';
import '../maze/models/maze_size.dart';

/// "My Journey": lifetime numbers, all computed from local history.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final l10n = context.l10n;
    final p = context.palette;
    final s = app.stats;
    final largest = s.largestSizeLevel == 0
        ? l10n.noneYet
        : MazeSize.all.firstWhere((m) => m.level == s.largestSizeLevel).dimensions;

    final tiles = <(IconData, Color, String, String)>[
      (Icons.flag_rounded, p.play, l10n.statMazesCompleted, '${s.completed}'),
      (Icons.timer_rounded, p.blue, l10n.statBestTime, s.bestTimeMs == null ? l10n.noneYet : l10n.clock(s.bestTimeMs!)),
      (Icons.hourglass_bottom_rounded, p.purple, l10n.statPlayTime, l10n.playTime(app.player.totalPlayTimeMs)),
      (Icons.grid_4x4_rounded, p.orange, l10n.statLargest, largest),
      (Icons.pets_rounded, p.pink, l10n.statCharacters, '${app.characters.length}/${Catalog.characters.length}'),
      (Icons.public_rounded, p.blue, l10n.statWorlds, '${app.worlds.length}/${Catalog.worlds.length}'),
      (Icons.diamond_rounded, p.purple, l10n.statPerfect, '${s.perfectCount}'),
      (Icons.star_rounded, p.yellow, l10n.statStars, '${s.totalStars}'),
      (Icons.local_fire_department_rounded, p.orange, l10n.statStreak, l10n.days(app.currentStreak)),
      (Icons.emoji_events_rounded, p.yellow, l10n.statLongestStreak, l10n.days(app.player.longestStreak)),
      (Icons.replay_rounded, p.play, l10n.statTried, '${app.player.totalGames}'),
    ];

    return ScreenFrame(
      title: l10n.myJourney,
      child: ContentWidth(
        maxWidth: 760,
        child: LayoutBuilder(builder: (context, box) {
          final columns = box.maxWidth > 560 ? 3 : 2;
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                sliver: SliverGrid.count(
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: [
                    for (final (icon, color, label, value) in tiles)
                      CuteCard(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, color: color, size: 30,
                                shadows: [Shadow(color: p.outline, offset: const Offset(0, 1.5))]),
                            const SizedBox(height: 4),
                            FittedBox(
                              child: Text(value,
                                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: p.ink)),
                            ),
                            Text(label,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: p.subInk)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: CuteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.bestBySize,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: p.ink)),
                        const SizedBox(height: 8),
                        for (final size in MazeSize.all)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text('${l10n.sizeName(size.id)}  ${size.dimensions}',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: p.ink)),
                                ),
                                _cell(context, Icons.timer_rounded,
                                    app.stats.sizes[size.id]?.bestTimeMs == null
                                        ? l10n.noneYet
                                        : l10n.clock(app.stats.sizes[size.id]!.bestTimeMs!)),
                                const SizedBox(width: 12),
                                _cell(context, Icons.directions_walk_rounded,
                                    '${app.stats.sizes[size.id]?.bestMoves ?? l10n.noneYet}'),
                                const SizedBox(width: 12),
                                _cell(context, Icons.flag_rounded,
                                    '${app.stats.sizes[size.id]?.completed ?? 0}'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _cell(BuildContext context, IconData icon, String text) {
    final p = context.palette;
    return SizedBox(
      width: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(icon, size: 16, color: p.subInk),
          const SizedBox(width: 3),
          Flexible(
            child: Text(text,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: p.ink)),
          ),
        ],
      ),
    );
  }
}
