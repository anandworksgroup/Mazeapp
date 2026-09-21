import 'package:sqflite/sqflite.dart';

import '../../features/maze/models/maze_size.dart';
import '../../features/settings/game_settings.dart';
import '../tables/schema.dart';
import 'models.dart';

/// All reads and writes of game data. Screens never touch SQL directly.
class GameDao {
  GameDao(this.db);

  final Database db;

  // ---- player -------------------------------------------------------------

  Future<PlayerProfile> player() async =>
      PlayerProfile.fromRow((await db.query(Schema.player, limit: 1)).single);

  Future<void> updatePlayer(Map<String, Object?> values) =>
      db.update(Schema.player, values);

  // ---- unlocks ------------------------------------------------------------

  Future<Set<String>> unlockedCharacters() =>
      _unlocked(Schema.characters, 'character_id');
  Future<Set<String>> unlockedThemes() => _unlocked(Schema.themes, 'theme_id');
  Future<Set<String>> unlockedSizes() => _unlocked(Schema.sizes, 'size_id');

  Future<Set<String>> _unlocked(String table, String idColumn) async {
    final rows = await db.query(table,
        columns: [idColumn], where: 'unlocked = 1');
    return {for (final r in rows) r[idColumn] as String};
  }

  Future<void> unlock(String table, String idColumn, Iterable<String> ids,
      {DatabaseExecutor? txn}) async {
    final exec = txn ?? db;
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final id in ids) {
      await exec.update(table, {'unlocked': 1, 'unlocked_at': now},
          where: '$idColumn = ? AND unlocked = 0', whereArgs: [id]);
    }
  }

  Future<Map<String, int>> unlockedAchievements() async {
    final rows = await db.query(Schema.achievements, where: 'unlocked = 1');
    return {
      for (final r in rows)
        r['achievement_id'] as String: (r['unlocked_at'] as int?) ?? 0,
    };
  }

  // ---- history ------------------------------------------------------------

  Future<void> addHistory(HistoryEntry e, {DatabaseExecutor? txn}) =>
      (txn ?? db).insert(Schema.mazeHistory, e.toRow());

  Future<JourneyStats> journey() async {
    final totals = (await db.rawQuery('''
      SELECT COUNT(*) AS completed,
             COALESCE(SUM(stars), 0) AS stars,
             COALESCE(SUM(CASE WHEN bumps = 0 THEN 1 ELSE 0 END), 0) AS perfect,
             MIN(time_ms) AS best_time
      FROM ${Schema.mazeHistory} WHERE completed = 1''')).single;

    final perSize = await db.rawQuery('''
      SELECT size, COUNT(*) AS n, MIN(time_ms) AS best_time, MIN(moves) AS best_moves
      FROM ${Schema.mazeHistory} WHERE completed = 1 GROUP BY size''');
    final sizes = <String, SizeRecord>{
      for (final r in perSize)
        r['size'] as String: SizeRecord(
          completed: r['n'] as int,
          bestTimeMs: r['best_time'] as int?,
          bestMoves: r['best_moves'] as int?,
        ),
    };
    final largest = sizes.keys.fold<int>(
        0, (m, id) => MazeSize.byId(id).level > m ? MazeSize.byId(id).level : m);

    final worlds = await db.rawQuery('''
      SELECT DISTINCT theme_id FROM ${Schema.mazeHistory} WHERE completed = 1''');
    final daily = await db.rawQuery('''
      SELECT DISTINCT day_key FROM ${Schema.mazeHistory}
      WHERE completed = 1 AND mode = 'daily' AND day_key IS NOT NULL''');

    return JourneyStats(
      completed: totals['completed'] as int,
      totalStars: totals['stars'] as int,
      perfectCount: totals['perfect'] as int,
      bestTimeMs: totals['best_time'] as int?,
      largestSizeLevel: largest,
      worldsCompleted: {for (final r in worlds) r['theme_id'] as String},
      sizes: sizes,
      dailyDays: {for (final r in daily) r['day_key'] as String},
    );
  }

  // ---- settings -----------------------------------------------------------

  Future<GameSettings> settings() async {
    final rows = await db.query(Schema.settings);
    return GameSettings.fromMap(
        {for (final r in rows) r['key'] as String: r['value'] as String});
  }

  Future<void> saveSettings(GameSettings s) async {
    final batch = db.batch();
    for (final e in s.toMap().entries) {
      batch.insert(Schema.settings, {'key': e.key, 'value': e.value},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // ---- unfinished maze ----------------------------------------------------

  Future<SavedGame?> savedGame() async {
    final rows = await db.query(Schema.currentGame, limit: 1);
    return rows.isEmpty ? null : SavedGame.fromRow(rows.single);
  }

  Future<void> saveGame(SavedGame g) => db.insert(Schema.currentGame, g.toRow(),
      conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> clearSavedGame({DatabaseExecutor? txn}) =>
      (txn ?? db).delete(Schema.currentGame);
}
