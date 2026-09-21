import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/catalog.dart';
import 'tables/schema.dart';

/// Opens the local SQLite database and makes sure the rows every screen
/// expects exist. First launch = create schema + a local player profile.
class AppDatabase {
  AppDatabase._(this.db);

  final Database db;

  static const fileName = 'maze_adventure.db';

  static Future<AppDatabase> open({
    DatabaseFactory? factory,
    String? path,
  }) async {
    final f = factory ?? databaseFactory;
    final dbPath = path ?? '${await f.getDatabasesPath()}/$fileName';
    final db = await f.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: Schema.version,
        onCreate: (db, _) async {
          final batch = db.batch();
          for (final sql in Schema.create) {
            batch.execute(sql);
          }
          await batch.commit(noResult: true);
        },
      ),
    );
    final app = AppDatabase._(db);
    await app.ensureDefaults();
    return app;
  }

  /// Idempotent: inserts the local profile and a row for every catalog item.
  /// Runs on every launch so items added in an update appear automatically,
  /// and again after "Reset progress" wipes the tables.
  Future<void> ensureDefaults() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      final players = await txn.query(Schema.player, limit: 1);
      if (players.isEmpty) {
        await txn.insert(Schema.player, {
          // A random id that only ever lives on this device. Not an account.
          'id': const Uuid().v4(),
          'created_at': now,
          'selected_character': Catalog.characters.first.id,
          'selected_theme': Catalog.worlds.first.id,
          'selected_size': 'small',
        });
      }
      final batch = txn.batch();
      for (final c in Catalog.characters) {
        batch.insert(
          Schema.characters,
          {'character_id': c.id, 'unlocked': c.unlock.isFree ? 1 : 0, 'unlocked_at': c.unlock.isFree ? now : null},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      for (final w in Catalog.worlds) {
        batch.insert(
          Schema.themes,
          {'theme_id': w.id, 'unlocked': w.unlock.isFree ? 1 : 0, 'unlocked_at': w.unlock.isFree ? now : null},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      for (final e in Catalog.sizeUnlocks.entries) {
        batch.insert(
          Schema.sizes,
          {'size_id': e.key, 'unlocked': e.value.isFree ? 1 : 0, 'unlocked_at': e.value.isFree ? now : null},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      for (final a in Achievement.values) {
        batch.insert(
          Schema.achievements,
          {'achievement_id': a.name, 'unlocked': 0, 'unlocked_at': null},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  /// Deletes every row in every table, then recreates a fresh profile.
  Future<void> wipe() async {
    await db.transaction((txn) async {
      for (final t in Schema.backupTables) {
        await txn.delete(t);
      }
    });
    await ensureDefaults();
  }

  Future<void> close() => db.close();
}
