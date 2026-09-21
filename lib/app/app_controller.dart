import 'package:flutter/foundation.dart';

import '../core/constants/catalog.dart';
import '../core/storage/backup_service.dart';
import '../database/dao/game_dao.dart';
import '../database/dao/models.dart';
import '../database/database.dart';
import '../database/tables/schema.dart';
import '../features/achievements/progression.dart';
import '../features/maze/engine/game_session.dart';
import '../features/maze/engine/seeds.dart';
import '../features/maze/models/maze_size.dart';
import '../features/settings/game_settings.dart';

/// What changed because a maze was finished; drives the result screen.
class CompletionResult {
  const CompletionResult({
    required this.stars,
    required this.isBestTime,
    required this.newAchievements,
    required this.newCharacters,
    required this.newWorlds,
    required this.newSizes,
  });

  final int stars;
  final bool isBestTime;
  final List<Achievement> newAchievements;
  final List<String> newCharacters;
  final List<String> newWorlds;
  final List<String> newSizes;

  bool get hasUnlocks =>
      newCharacters.isNotEmpty || newWorlds.isNotEmpty || newSizes.isNotEmpty;
}

/// The single source of app state: profile, settings, unlocks, stats.
/// Backed entirely by the local database.
class AppController extends ChangeNotifier {
  AppController(this._appDb) : _dao = GameDao(_appDb.db);

  final AppDatabase _appDb;
  final GameDao _dao;
  late final BackupService backup = BackupService(_appDb);

  late PlayerProfile player;
  GameSettings settings = const GameSettings();
  Set<String> characters = {};
  Set<String> worlds = {};
  Set<String> sizes = {};
  Map<String, int> achievements = {};
  JourneyStats stats = const JourneyStats.empty();
  SavedGame? savedGame;

  /// Overridable so tests can pin "today".
  DateTime Function() clock = DateTime.now;

  Future<void> load() async {
    player = await _dao.player();
    settings = await _dao.settings();
    stats = await _dao.journey();
    savedGame = await _dao.savedGame();
    await _syncUnlocks();
    await _reloadUnlocks();
    notifyListeners();
  }

  Future<void> _reloadUnlocks() async {
    characters = await _dao.unlockedCharacters();
    worlds = await _dao.unlockedThemes();
    sizes = await _dao.unlockedSizes();
    achievements = await _dao.unlockedAchievements();
  }

  /// Grants anything the totals already qualify for. Returns what was new.
  Future<({List<String> chars, List<String> worlds, List<String> sizes, List<Achievement> achievements})>
      _syncUnlocks({int? runTimeMs, MazeSize? runSize}) async {
    final full = player.fullUnlock;
    final beforeChars = await _dao.unlockedCharacters();
    final beforeWorlds = await _dao.unlockedThemes();
    final beforeSizes = await _dao.unlockedSizes();
    final beforeAch = (await _dao.unlockedAchievements()).keys.toSet();

    final newChars = Progression.earnedCharacters(stats, fullUnlock: full)
        .difference(beforeChars);
    final newWorlds =
        Progression.earnedWorlds(stats, fullUnlock: full).difference(beforeWorlds);
    final newSizes =
        Progression.earnedSizes(stats, fullUnlock: full).difference(beforeSizes);

    await _dao.unlock(Schema.characters, 'character_id', newChars);
    await _dao.unlock(Schema.themes, 'theme_id', newWorlds);
    await _dao.unlock(Schema.sizes, 'size_id', newSizes);

    final earned = Progression.earnedAchievements(
      stats: stats,
      unlockedCharacterCount: beforeChars.length + newChars.length,
      longestStreak: player.longestStreak,
      runTimeMs: runTimeMs,
      runSize: runSize,
    );
    final newAch = [
      for (final a in Achievement.values)
        if (earned.contains(a) && !beforeAch.contains(a.name)) a,
    ];
    await _dao.unlock(
        Schema.achievements, 'achievement_id', newAch.map((a) => a.name));

    // Keep catalog order so the reveal reads naturally.
    return (
      chars: [for (final c in Catalog.characters) if (newChars.contains(c.id)) c.id],
      worlds: [for (final w in Catalog.worlds) if (newWorlds.contains(w.id)) w.id],
      sizes: [for (final s in MazeSize.all) if (newSizes.contains(s.id)) s.id],
      achievements: newAch,
    );
  }

  // ---- selections ---------------------------------------------------------

  Future<void> selectCharacter(String id) =>
      _updatePlayer({'selected_character': id});
  Future<void> selectWorld(String id) => _updatePlayer({'selected_theme': id});
  Future<void> selectSize(String id) => _updatePlayer({'selected_size': id});

  Future<void> _updatePlayer(Map<String, Object?> values) async {
    await _dao.updatePlayer(values);
    player = await _dao.player();
    notifyListeners();
  }

  Future<void> updateSettings(GameSettings next) async {
    settings = next;
    notifyListeners();
    await _dao.saveSettings(next);
  }

  // ---- daily maze ---------------------------------------------------------

  String get todayKey => Seeds.dayKey(clock());
  int get dailySeed => Seeds.daily(clock());
  bool get dailyDoneToday => stats.dailyDays.contains(todayKey);

  /// The daily maze rotates through the worlds the player has unlocked.
  String get dailyWorld {
    final unlocked = [for (final w in Catalog.worlds) if (worlds.contains(w.id)) w.id];
    if (unlocked.isEmpty) return Catalog.worlds.first.id;
    return unlocked[dailySeed % unlocked.length];
  }

  static const dailySize = MazeSize.medium;

  /// Shown streak: a streak whose last day is before yesterday has lapsed.
  int get currentStreak {
    final last = player.lastPlayDay;
    final now = clock();
    final yesterday = Seeds.dayKey(DateTime(now.year, now.month, now.day - 1));
    return last == todayKey || last == yesterday ? player.currentStreak : 0;
  }

  // ---- game results -------------------------------------------------------

  Future<CompletionResult> recordCompletion({
    required GameSession session,
    required String themeId,
    required String characterId,
    required PlayMode mode,
  }) async {
    final today = todayKey;
    final previousBest = stats.sizes[session.size.id]?.bestTimeMs;
    final stars = session.stars;
    final streak = Progression.nextStreak(
      lastDay: player.lastPlayDay,
      today: today,
      current: player.currentStreak,
      longest: player.longestStreak,
    );

    await _dao.db.transaction((txn) async {
      await _dao.addHistory(
        HistoryEntry(
          seed: session.maze.seed,
          sizeId: session.size.id,
          themeId: themeId,
          characterId: characterId,
          mode: mode,
          dayKey: mode == PlayMode.daily ? today : null,
          completed: true,
          timeMs: session.elapsedMs,
          moves: session.moves,
          bumps: session.bumps,
          stars: stars,
          createdAt: clock().millisecondsSinceEpoch,
        ),
        txn: txn,
      );
      await _dao.clearSavedGame(txn: txn);
      await txn.rawUpdate('''
        UPDATE ${Schema.player} SET
          total_games = total_games + 1,
          total_play_time_ms = total_play_time_ms + ?,
          current_streak = ?, longest_streak = ?, last_play_day = ?''',
          [session.elapsedMs, streak.current, streak.longest, today]);
    });

    player = await _dao.player();
    stats = await _dao.journey();
    savedGame = null;
    final fresh =
        await _syncUnlocks(runTimeMs: session.elapsedMs, runSize: session.size);
    await _reloadUnlocks();
    notifyListeners();

    return CompletionResult(
      stars: stars,
      isBestTime: previousBest != null && session.elapsedMs < previousBest,
      newAchievements: fresh.achievements,
      newCharacters: fresh.chars,
      newWorlds: fresh.worlds,
      newSizes: fresh.sizes,
    );
  }

  /// Restarting or replacing a maze that was actually played.
  Future<void> recordAbandon({
    required GameSession session,
    required String themeId,
    required String characterId,
    required PlayMode mode,
  }) async {
    if (session.moves == 0 || session.isComplete) {
      await clearSavedGame();
      return;
    }
    await _dao.db.transaction((txn) async {
      await _dao.addHistory(
        HistoryEntry(
          seed: session.maze.seed,
          sizeId: session.size.id,
          themeId: themeId,
          characterId: characterId,
          mode: mode,
          dayKey: mode == PlayMode.daily ? todayKey : null,
          completed: false,
          timeMs: session.elapsedMs,
          moves: session.moves,
          bumps: session.bumps,
          stars: 0,
          createdAt: clock().millisecondsSinceEpoch,
        ),
        txn: txn,
      );
      await _dao.clearSavedGame(txn: txn);
      await txn.rawUpdate('''
        UPDATE ${Schema.player} SET
          total_games = total_games + 1,
          total_failed = total_failed + 1,
          total_play_time_ms = total_play_time_ms + ?''', [session.elapsedMs]);
    });
    player = await _dao.player();
    savedGame = null;
    notifyListeners();
  }

  Future<void> saveGame(SavedGame game) async {
    savedGame = game;
    await _dao.saveGame(game);
  }

  Future<void> clearSavedGame() async {
    savedGame = null;
    await _dao.clearSavedGame();
    notifyListeners();
  }

  // ---- full unlock, reset, backup ----------------------------------------

  Future<void> grantFullUnlock() async {
    if (player.fullUnlock) return;
    await _dao.updatePlayer({'full_unlock': 1});
    player = await _dao.player();
    await _syncUnlocks();
    await _reloadUnlocks();
    notifyListeners();
  }

  /// Deletes all progress, statistics and settings. A purchase is tied to the
  /// store account, not to this data, so Restore Purchases brings it back.
  Future<void> resetProgress() async {
    await _appDb.wipe();
    await load();
  }

  Future<String> exportBackup() => backup.exportJson();

  Future<void> importBackup(String json) async {
    await backup.importJson(json);
    await load();
  }
}
