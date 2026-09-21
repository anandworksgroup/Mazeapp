import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../app/app_scope.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/constants/catalog.dart';
import '../../core/localization/l10n.dart';
import '../../core/widgets/chunky.dart';
import '../../database/dao/models.dart';
import '../character/animated_character.dart';
import '../character/character_painter.dart';
import '../maze/models/maze_size.dart';
import '../maze/view/game_launch.dart';
import '../themes/world_art.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _sky =
      AnimationController(vsync: this, duration: const Duration(seconds: 40));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.app.settings.animations) {
      if (!_sky.isAnimating) _sky.repeat();
    } else {
      _sky.stop();
    }
  }

  @override
  void dispose() {
    _sky.dispose();
    super.dispose();
  }

  void _continue(AppController app) {
    final saved = app.savedGame;
    if (saved == null) return;
    Navigator.of(context).pushNamed(Routes.game, arguments: GameLaunch.fromSaved(saved));
  }

  void _daily(AppController app) {
    final saved = app.savedGame;
    // Resume today's daily run if it was left unfinished.
    if (saved != null && saved.mode == PlayMode.daily && saved.dayKey == app.todayKey) {
      _continue(app);
      return;
    }
    Navigator.of(context).pushNamed(
      Routes.game,
      arguments: GameLaunch(
        seed: app.dailySeed,
        size: AppController.dailySize,
        worldId: app.dailyWorld,
        characterId: app.player.selectedCharacter,
        mode: PlayMode.daily,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final l10n = context.l10n;
    final p = context.palette;
    final world = Catalog.world(app.player.selectedTheme);
    final character = Catalog.character(app.player.selectedCharacter);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final saved = app.savedGame;

    final title = OutlineText(l10n.appTitle, size: 46, color: p.yellow, strokeWidth: 9);

    final hero = AnimatedCharacter(
      def: character,
      pose: CharacterPose.wave,
      size: 150,
      animate: app.settings.animations,
    );

    final play = ChunkyButton(
      onTap: () => Navigator.of(context).pushNamed(Routes.play),
      label: l10n.play,
      icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 44),
      color: p.play,
      height: 84,
      fontSize: 36,
      expand: true,
      radius: 28,
    );

    final resume = saved == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(top: 12),
            child: ChunkyButton(
              onTap: () => _continue(app),
              color: p.orange,
              height: 58,
              expand: true,
              semanticLabel: l10n.continueGame,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restore_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  Flexible(
                    child: OutlineText(
                      '${l10n.continueGame} · ${MazeSize.byId(saved.sizeId).dimensions}',
                      size: 20,
                      strokeWidth: 4,
                      outline: darken(p.orange, 0.35),
                    ),
                  ),
                ],
              ),
            ),
          );

    final tiles = <_MenuTile>[
      _MenuTile(Icons.public_rounded, l10n.worlds, p.blue, () => Navigator.of(context).pushNamed(Routes.worlds)),
      _MenuTile(Icons.pets_rounded, l10n.characters, p.pink, () => Navigator.of(context).pushNamed(Routes.characters)),
      _MenuTile(
        app.dailyDoneToday ? Icons.event_available_rounded : Icons.today_rounded,
        l10n.dailyMaze,
        p.orange,
        () => _daily(app),
        badge: app.dailyDoneToday ? '✓' : null,
      ),
      _MenuTile(Icons.emoji_events_rounded, l10n.achievements, p.yellow,
          () => Navigator.of(context).pushNamed(Routes.achievements)),
      _MenuTile(Icons.insights_rounded, l10n.myJourney, p.play,
          () => Navigator.of(context).pushNamed(Routes.statistics)),
      _MenuTile(Icons.settings_rounded, l10n.settings, p.purple,
          () => Navigator.of(context).pushNamed(Routes.settings)),
    ];

    Widget grid(int columns) => GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
          children: tiles,
        );

    return Scaffold(
      backgroundColor: world.skyBottom,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _sky,
              builder: (_, __) => CustomPaint(
                painter: ScenePainter(world: world, t: _sky.value, dim: dark),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(builder: (context, box) {
              final wide = box.maxWidth > box.maxHeight * 1.15 && box.maxWidth > 600;
              if (wide) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            title,
                            hero,
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 380),
                              child: Column(children: [play, if (resume != null) resume]),
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 460),
                              child: grid(3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      children: [
                        title,
                        const SizedBox(height: 4),
                        hero,
                        const SizedBox(height: 8),
                        play,
                        if (resume != null) resume,
                        const SizedBox(height: 20),
                        grid(3),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile(this.icon, this.label, this.color, this.onTap, {this.badge});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: label,
      child: CuteCard(
        onTap: onTap,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: p.outline, width: p.outlineWidth),
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                if (badge != null)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: p.play,
                        shape: BoxShape.circle,
                        border: Border.all(color: p.outline, width: 2),
                      ),
                      child: Text(badge!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: p.ink, height: 1.1),
            ),
          ],
        ),
      ),
    );
  }
}
