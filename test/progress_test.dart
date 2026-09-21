import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:maze_adventure/app/app_controller.dart';
import 'package:maze_adventure/core/constants/catalog.dart';
import 'package:maze_adventure/core/storage/backup_service.dart';
import 'package:maze_adventure/database/dao/models.dart';
import 'package:maze_adventure/database/database.dart';
import 'package:maze_adventure/features/achievements/progression.dart';
import 'package:maze_adventure/features/maze/engine/game_session.dart';
import 'package:maze_adventure/features/maze/generator/maze_generator.dart';
import 'package:maze_adventure/features/maze/models/maze.dart';
import 'package:maze_adventure/features/maze/models/maze_size.dart';
import 'package:maze_adventure/features/settings/game_settings.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

var _dbCounter = 0;

Future<AppController> freshController() async {
  final dir = await Directory.systemTemp.createTemp('maze_test');
  final db = await AppDatabase.open(
      factory: databaseFactoryFfi, path: '${dir.path}/db${_dbCounter++}.db');
  final c = AppController(db)..clock = () => DateTime(2026, 9, 21, 10);
  await c.load();
  return c;
}

GameSession solved(MazeSize size, {int seed = 5, int extraBumps = 0}) {
  final maze = const MazeGenerator().generate(seed: seed, size: size);
  final s = GameSession(maze: maze, size: size);
  final path = maze.shortestPath(maze.start, maze.goal);
  for (var i = 1; i < path.length; i++) {
    s.step(Direction.values.firstWhere((d) => path[i - 1].step(d) == path[i]));
  }
  s.bumps += extraBumps;
  s.elapsedMs = 20000;
  return s;
}

void main() {
  sqfliteFfiInit();

  test('first launch creates a local profile with only free content', () async {
    final c = await freshController();
    expect(c.player.id, isNotEmpty);
    expect(c.characters,
        {for (final ch in Catalog.characters) if (ch.unlock.isFree) ch.id});
    expect(c.characters.length, 5);
    expect(c.worlds, {'forest', 'candy', 'ocean'});
    expect(c.sizes.contains('extreme'), isFalse);
    expect(c.sizes.length, 5);
    expect(c.achievements, isEmpty);
    expect(c.stats.completed, 0);
  });

  test('finishing mazes saves history, unlocks content and achievements', () async {
    final c = await freshController();
    final first = await c.recordCompletion(
        session: solved(MazeSize.medium),
        themeId: 'forest',
        characterId: 'milo',
        mode: PlayMode.free);
    expect(first.newAchievements,
        containsAll([Achievement.firstMaze, Achievement.perfect, Achievement.speedRunner]));
    expect(c.stats.completed, 1);
    expect(c.player.totalGames, 1);
    expect(c.player.currentStreak, 1);

    for (var i = 0; i < 2; i++) {
      await c.recordCompletion(
          session: solved(MazeSize.tiny, seed: i + 10, extraBumps: 3),
          themeId: 'candy',
          characterId: 'milo',
          mode: PlayMode.free);
    }
    expect(c.characters.contains('buzz'), isTrue); // 3 completions

    final huge = await c.recordCompletion(
        session: solved(MazeSize.huge),
        themeId: 'ocean',
        characterId: 'milo',
        mode: PlayMode.free);
    expect(huge.newSizes, ['extreme']);
    expect(huge.newWorlds, ['road']); // 4 completions
    expect(c.stats.sizes['huge']!.completed, 1);
  });

  test('abandoned games count as tries, not completions', () async {
    final c = await freshController();
    final maze = const MazeGenerator().generate(seed: 1, size: MazeSize.small);
    final s = GameSession(maze: maze, size: MazeSize.small)
      ..step(maze.exits(maze.start).first)
      ..elapsedMs = 5000;
    await c.recordAbandon(
        session: s, themeId: 'forest', characterId: 'milo', mode: PlayMode.free);
    expect(c.player.totalGames, 1);
    expect(c.player.totalFailed, 1);
    expect(c.player.totalPlayTimeMs, 5000);
    expect(c.stats.completed, 0);
  });

  test('unfinished maze is saved as seed + position and restored', () async {
    final c = await freshController();
    await c.saveGame(const SavedGame(
      seed: 77,
      sizeId: 'large',
      themeId: 'ocean',
      characterId: 'pip',
      mode: PlayMode.free,
      dayKey: null,
      position: Pos(3, 4),
      moves: 12,
      bumps: 1,
      elapsedMs: 9000,
      trail: [Pos(0, 0), Pos(1, 0)],
    ));
    await c.load();
    expect(c.savedGame!.seed, 77);
    expect(c.savedGame!.position, const Pos(3, 4));
    expect(c.savedGame!.trail, [const Pos(0, 0), const Pos(1, 0)]);
  });

  test('daily maze is marked done and streaks follow calendar days', () async {
    final c = await freshController();
    expect(c.dailyDoneToday, isFalse);
    await c.recordCompletion(
        session: solved(AppController.dailySize, seed: c.dailySeed),
        themeId: c.dailyWorld,
        characterId: 'milo',
        mode: PlayMode.daily);
    expect(c.dailyDoneToday, isTrue);
    expect(c.achievements.containsKey(Achievement.dailyHero.name), isTrue);

    c.clock = () => DateTime(2026, 9, 22, 9);
    expect(c.currentStreak, 1);
    await c.recordCompletion(
        session: solved(MazeSize.tiny),
        themeId: 'forest',
        characterId: 'milo',
        mode: PlayMode.free);
    expect(c.player.currentStreak, 2);
    c.clock = () => DateTime(2026, 9, 25, 9);
    expect(c.currentStreak, 0);
  });

  test('streak rule', () {
    expect(Progression.nextStreak(lastDay: null, today: '2026-03-01', current: 0, longest: 0),
        (current: 1, longest: 1));
    expect(Progression.nextStreak(lastDay: '2026-02-28', today: '2026-03-01', current: 4, longest: 4),
        (current: 5, longest: 5));
    expect(Progression.nextStreak(lastDay: '2026-02-20', today: '2026-03-01', current: 4, longest: 6),
        (current: 1, longest: 6));
  });

  test('settings persist', () async {
    final c = await freshController();
    await c.updateSettings(c.settings.copyWith(
        controlMode: ControlMode.tilt, music: false, language: 'hi'));
    await c.load();
    expect(c.settings.controlMode, ControlMode.tilt);
    expect(c.settings.music, isFalse);
    expect(c.settings.language, 'hi');
  });

  test('full unlock opens everything', () async {
    final c = await freshController();
    await c.grantFullUnlock();
    expect(c.characters.length, Catalog.characters.length);
    expect(c.worlds.length, Catalog.worlds.length);
    expect(c.sizes.length, MazeSize.all.length);
    expect(c.achievements.containsKey(Achievement.collector.name), isTrue);
  });

  test('backup round-trips and reset wipes', () async {
    final c = await freshController();
    await c.recordCompletion(
        session: solved(MazeSize.small),
        themeId: 'forest',
        characterId: 'milo',
        mode: PlayMode.free);
    await c.selectCharacter('pip');
    await c.updateSettings(c.settings.copyWith(sound: false));
    final json = await c.exportBackup();
    final playerId = c.player.id;

    await c.resetProgress();
    expect(c.stats.completed, 0);
    expect(c.player.id, isNot(playerId));
    expect(c.settings.sound, isTrue);

    await c.importBackup(json);
    expect(c.stats.completed, 1);
    expect(c.player.id, playerId);
    expect(c.player.selectedCharacter, 'pip');
    expect(c.settings.sound, isFalse);

    await expectLater(c.importBackup('{"hello": 1}'),
        throwsA(isA<BackupException>()));
    await expectLater(c.importBackup('nope'), throwsA(isA<BackupException>()));
    expect(c.stats.completed, 1, reason: 'bad import must not touch data');
  });
}
