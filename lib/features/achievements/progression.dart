import '../../core/constants/catalog.dart';
import '../../database/dao/models.dart';
import '../maze/engine/seeds.dart';
import '../maze/models/maze_size.dart';

/// Pure rules for unlocks, achievements and streaks. Every check is derived
/// from totals, so re-running it (after an import, after an update that adds
/// content) is always safe.
class Progression {
  Progression._();

  static bool meets(UnlockRule rule, JourneyStats stats, {required bool fullUnlock}) {
    if (fullUnlock || rule.isFree) return true;
    if (rule.completions > 0 && stats.completed < rule.completions) return false;
    if (rule.stars > 0 && stats.totalStars < rule.stars) return false;
    final size = rule.completedSizeId;
    if (size != null && (stats.sizes[size]?.completed ?? 0) == 0) return false;
    return true;
  }

  static Set<String> earnedCharacters(JourneyStats s, {required bool fullUnlock}) => {
        for (final c in Catalog.characters)
          if (meets(c.unlock, s, fullUnlock: fullUnlock)) c.id,
      };

  static Set<String> earnedWorlds(JourneyStats s, {required bool fullUnlock}) => {
        for (final w in Catalog.worlds)
          if (meets(w.unlock, s, fullUnlock: fullUnlock)) w.id,
      };

  static Set<String> earnedSizes(JourneyStats s, {required bool fullUnlock}) => {
        for (final e in Catalog.sizeUnlocks.entries)
          if (meets(e.value, s, fullUnlock: fullUnlock)) e.key,
      };

  /// Achievements earned given lifetime totals plus (optionally) the run that
  /// just finished, which is the only way to earn the per-run ones.
  static Set<Achievement> earnedAchievements({
    required JourneyStats stats,
    required int unlockedCharacterCount,
    required int longestStreak,
    int? runTimeMs,
    MazeSize? runSize,
  }) {
    final out = <Achievement>{};
    if (stats.completed >= 1) out.add(Achievement.firstMaze);
    if (stats.completed >= 10) out.add(Achievement.explorer);
    if (stats.completed >= 100) out.add(Achievement.mazeMaster);
    if (runTimeMs != null &&
        runSize != null &&
        runSize.level >= MazeSize.medium.level &&
        runTimeMs < 30000) {
      out.add(Achievement.speedRunner);
    }
    if (stats.largestSizeLevel >= MazeSize.extreme.level) out.add(Achievement.giant);
    if (unlockedCharacterCount >= Catalog.characters.length) {
      out.add(Achievement.collector);
    }
    if (Catalog.worlds.every((w) => stats.worldsCompleted.contains(w.id))) {
      out.add(Achievement.worldTraveler);
    }
    if (stats.perfectCount >= 1) out.add(Achievement.perfect);
    if (stats.dailyDays.isNotEmpty) out.add(Achievement.dailyHero);
    if (stats.totalStars >= 100) out.add(Achievement.starCollector);
    if (longestStreak >= 3) out.add(Achievement.streak3);
    return out;
  }

  /// A streak counts consecutive local days with at least one finished maze.
  static ({int current, int longest}) nextStreak({
    required String? lastDay,
    required String today,
    required int current,
    required int longest,
  }) {
    if (lastDay == today) return (current: current, longest: longest);
    final t = DateTime.parse(today);
    final yesterday = Seeds.dayKey(DateTime(t.year, t.month, t.day - 1));
    final wasYesterday = lastDay == yesterday;
    final next = wasYesterday ? current + 1 : 1;
    return (current: next, longest: next > longest ? next : longest);
  }
}
