import '../../features/maze/models/maze.dart';

enum PlayMode { free, daily }

class PlayerProfile {
  const PlayerProfile({
    required this.id,
    required this.createdAt,
    required this.selectedCharacter,
    required this.selectedTheme,
    required this.selectedSize,
    required this.totalGames,
    required this.totalFailed,
    required this.totalPlayTimeMs,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastPlayDay,
    required this.fullUnlock,
  });

  final String id;
  final int createdAt;
  final String selectedCharacter;
  final String selectedTheme;
  final String selectedSize;
  final int totalGames;
  final int totalFailed;
  final int totalPlayTimeMs;
  final int currentStreak;
  final int longestStreak;
  final String? lastPlayDay;
  final bool fullUnlock;

  factory PlayerProfile.fromRow(Map<String, Object?> r) => PlayerProfile(
        id: r['id'] as String,
        createdAt: r['created_at'] as int,
        selectedCharacter: r['selected_character'] as String,
        selectedTheme: r['selected_theme'] as String,
        selectedSize: r['selected_size'] as String,
        totalGames: r['total_games'] as int,
        totalFailed: r['total_failed'] as int,
        totalPlayTimeMs: r['total_play_time_ms'] as int,
        currentStreak: r['current_streak'] as int,
        longestStreak: r['longest_streak'] as int,
        lastPlayDay: r['last_play_day'] as String?,
        fullUnlock: (r['full_unlock'] as int) == 1,
      );
}

/// One finished (or abandoned) maze.
class HistoryEntry {
  const HistoryEntry({
    required this.seed,
    required this.sizeId,
    required this.themeId,
    required this.characterId,
    required this.mode,
    required this.dayKey,
    required this.completed,
    required this.timeMs,
    required this.moves,
    required this.bumps,
    required this.stars,
    required this.createdAt,
  });

  final int seed;
  final String sizeId;
  final String themeId;
  final String characterId;
  final PlayMode mode;
  final String? dayKey;
  final bool completed;
  final int timeMs;
  final int moves;
  final int bumps;
  final int stars;
  final int createdAt;

  Map<String, Object?> toRow() => {
        'seed': seed,
        'size': sizeId,
        'theme_id': themeId,
        'character_id': characterId,
        'mode': mode.name,
        'day_key': dayKey,
        'completed': completed ? 1 : 0,
        'time_ms': timeMs,
        'moves': moves,
        'bumps': bumps,
        'stars': stars,
        'created_at': createdAt,
      };
}

/// The unfinished maze: its seed and the player's place in it.
class SavedGame {
  const SavedGame({
    required this.seed,
    required this.sizeId,
    required this.themeId,
    required this.characterId,
    required this.mode,
    required this.dayKey,
    required this.position,
    required this.moves,
    required this.bumps,
    required this.elapsedMs,
    required this.trail,
  });

  final int seed;
  final String sizeId;
  final String themeId;
  final String characterId;
  final PlayMode mode;
  final String? dayKey;
  final Pos position;
  final int moves;
  final int bumps;
  final int elapsedMs;
  final List<Pos> trail;

  Map<String, Object?> toRow() => {
        'id': 1,
        'seed': seed,
        'size': sizeId,
        'theme_id': themeId,
        'character_id': characterId,
        'mode': mode.name,
        'day_key': dayKey,
        'pos_x': position.x,
        'pos_y': position.y,
        'moves': moves,
        'bumps': bumps,
        'elapsed_ms': elapsedMs,
        'trail': trail.map((p) => '${p.x},${p.y}').join(';'),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };

  factory SavedGame.fromRow(Map<String, Object?> r) {
    final trailText = r['trail'] as String;
    return SavedGame(
      seed: r['seed'] as int,
      sizeId: r['size'] as String,
      themeId: r['theme_id'] as String,
      characterId: r['character_id'] as String,
      mode: PlayMode.values.firstWhere((m) => m.name == r['mode'],
          orElse: () => PlayMode.free),
      dayKey: r['day_key'] as String?,
      position: Pos(r['pos_x'] as int, r['pos_y'] as int),
      moves: r['moves'] as int,
      bumps: r['bumps'] as int,
      elapsedMs: r['elapsed_ms'] as int,
      trail: trailText.isEmpty
          ? const []
          : [
              for (final part in trailText.split(';'))
                Pos(int.parse(part.split(',')[0]), int.parse(part.split(',')[1])),
            ],
    );
  }
}

class SizeRecord {
  const SizeRecord({required this.completed, this.bestTimeMs, this.bestMoves});

  final int completed;
  final int? bestTimeMs;
  final int? bestMoves;
}

/// Everything "My Journey" and the achievement checks need, aggregated from
/// `maze_history` in a few queries.
class JourneyStats {
  const JourneyStats({
    required this.completed,
    required this.totalStars,
    required this.perfectCount,
    required this.bestTimeMs,
    required this.largestSizeLevel,
    required this.worldsCompleted,
    required this.sizes,
    required this.dailyDays,
  });

  const JourneyStats.empty()
      : completed = 0,
        totalStars = 0,
        perfectCount = 0,
        bestTimeMs = null,
        largestSizeLevel = 0,
        worldsCompleted = const {},
        sizes = const {},
        dailyDays = const {};

  final int completed;
  final int totalStars;
  final int perfectCount;
  final int? bestTimeMs;

  /// `MazeSize.level` of the biggest maze ever finished (0 = none).
  final int largestSizeLevel;
  final Set<String> worldsCompleted;
  final Map<String, SizeRecord> sizes;
  final Set<String> dailyDays;
}
