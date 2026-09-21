import '../../../database/dao/models.dart';
import '../engine/seeds.dart';
import '../models/maze_size.dart';

/// Everything needed to (re)build a maze run. The maze itself is never
/// stored — [seed] + [size] regenerate it exactly.
class GameLaunch {
  const GameLaunch({
    required this.seed,
    required this.size,
    required this.worldId,
    required this.characterId,
    this.mode = PlayMode.free,
    this.resume,
  });

  factory GameLaunch.fresh({
    required MazeSize size,
    required String worldId,
    required String characterId,
  }) =>
      GameLaunch(
        seed: Seeds.random(),
        size: size,
        worldId: worldId,
        characterId: characterId,
      );

  factory GameLaunch.fromSaved(SavedGame g) => GameLaunch(
        seed: g.seed,
        size: MazeSize.byId(g.sizeId),
        worldId: g.themeId,
        characterId: g.characterId,
        mode: g.mode,
        resume: g,
      );

  final int seed;
  final MazeSize size;
  final String worldId;
  final String characterId;
  final PlayMode mode;
  final SavedGame? resume;
}
