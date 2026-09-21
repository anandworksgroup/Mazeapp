import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../database/database.dart';
import '../../database/tables/schema.dart';

class BackupException implements Exception {
  BackupException(this.reason);
  final String reason;
  @override
  String toString() => 'BackupException: $reason';
}

/// Manual export/import of all game data as one JSON file.
///
/// There is no cloud sync, and the app does not pretend otherwise: moving
/// progress to a new phone means exporting here and importing there.
class BackupService {
  BackupService(this.appDb);

  final AppDatabase appDb;

  static const fileName = 'maze_adventure_backup.json';
  static const _format = 'maze_adventure_backup';
  static const _formatVersion = 1;

  Future<String> exportJson() async {
    final tables = <String, List<Map<String, Object?>>>{};
    for (final t in Schema.backupTables) {
      tables[t] = await appDb.db.query(t);
    }
    return const JsonEncoder.withIndent('  ').convert({
      'format': _format,
      'format_version': _formatVersion,
      'schema_version': Schema.version,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'tables': tables,
    });
  }

  /// Replaces all local data with the backup, atomically. Anything unexpected
  /// aborts before a single row changes.
  Future<void> importJson(String text) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw BackupException('not_json');
    }
    if (decoded is! Map ||
        decoded['format'] != _format ||
        decoded['tables'] is! Map) {
      throw BackupException('wrong_file');
    }
    if ((decoded['format_version'] as num? ?? 99) > _formatVersion) {
      throw BackupException('too_new');
    }
    final tables = decoded['tables'] as Map;
    if (tables[Schema.player] is! List || (tables[Schema.player] as List).isEmpty) {
      throw BackupException('wrong_file');
    }

    final db = appDb.db;
    final columns = <String, Set<String>>{};
    for (final t in Schema.backupTables) {
      final info = await db.rawQuery('PRAGMA table_info($t)');
      columns[t] = {for (final c in info) c['name'] as String};
    }

    final cleaned = <String, List<Map<String, Object?>>>{};
    for (final t in Schema.backupTables) {
      final rows = tables[t];
      if (rows == null) continue;
      if (rows is! List) throw BackupException('wrong_file');
      cleaned[t] = [
        for (final row in rows)
          if (row is Map)
            {
              for (final e in row.entries)
                if (columns[t]!.contains(e.key) &&
                    (e.value == null || e.value is num || e.value is String))
                  e.key as String: e.value,
            }
          else
            throw BackupException('wrong_file'),
      ];
    }

    try {
      await db.transaction((txn) async {
        for (final t in Schema.backupTables) {
          await txn.delete(t);
        }
        for (final t in Schema.backupTables) {
          for (final row in cleaned[t] ?? const <Map<String, Object?>>[]) {
            await txn.insert(t, row,
                conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      });
    } on DatabaseException {
      throw BackupException('wrong_file');
    }
    await appDb.ensureDefaults();
  }
}
