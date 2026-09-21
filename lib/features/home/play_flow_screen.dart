import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/localization/l10n.dart';
import '../../core/widgets/chunky.dart';
import '../../core/widgets/screen_frame.dart';
import '../maze/models/maze_size.dart';
import '../maze/view/game_launch.dart';
import 'pickers.dart';

/// PLAY → character → world → size → a freshly generated maze.
class PlayFlowScreen extends StatefulWidget {
  const PlayFlowScreen({super.key});

  @override
  State<PlayFlowScreen> createState() => _PlayFlowScreenState();
}

class _PlayFlowScreenState extends State<PlayFlowScreen> {
  int _step = 0;
  bool _carouselOnLocked = false;

  bool _currentUnlocked() {
    final app = context.appRead;
    return switch (_step) {
      0 => !_carouselOnLocked && app.characters.contains(app.player.selectedCharacter),
      1 => app.worlds.contains(app.player.selectedTheme),
      _ => app.sizes.contains(app.player.selectedSize),
    };
  }

  void _next() {
    if (!_currentUnlocked()) return;
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    final app = context.appRead;
    Navigator.of(context).pushReplacementNamed(
      Routes.game,
      arguments: GameLaunch.fresh(
        size: MazeSize.byId(app.player.selectedSize),
        worldId: app.player.selectedTheme,
        characterId: app.player.selectedCharacter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final l10n = context.l10n;
    final p = context.palette;
    final titles = [l10n.chooseCharacter, l10n.chooseWorld, l10n.chooseSize];
    final last = _step == 2;

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step--);
      },
      child: ScreenFrame(
        title: titles[_step],
        worldId: _step == 0 ? null : app.player.selectedTheme,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= _step ? p.yellow : p.card,
                  border: Border.all(color: p.outline, width: 2),
                ),
              ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: switch (_step) {
                    0 => CharacterCarousel(
                        onFocusLocked: (locked) => setState(() => _carouselOnLocked = locked)),
                    1 => const ContentWidth(maxWidth: 820, child: WorldGrid()),
                    _ => const ContentWidth(maxWidth: 820, child: SizeList()),
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: ContentWidth(
                maxWidth: 420,
                child: ChunkyButton(
                  onTap: _currentUnlocked() ? _next : null,
                  label: last ? l10n.go : l10n.next,
                  icon: Icon(last ? Icons.play_arrow_rounded : Icons.arrow_forward_rounded,
                      color: Colors.white, size: 34),
                  color: last ? p.play : p.orange,
                  height: 68,
                  fontSize: 28,
                  expand: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
