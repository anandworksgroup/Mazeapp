import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maze_adventure/app/app.dart';
import 'package:maze_adventure/app/app_controller.dart';
import 'package:maze_adventure/core/audio/audio_service.dart';
import 'package:maze_adventure/core/constants/game_config.dart';
import 'package:maze_adventure/core/utilities/purchase_service.dart';
import 'package:maze_adventure/core/widgets/screen_frame.dart';
import 'package:maze_adventure/database/database.dart';
import 'package:maze_adventure/features/maze/engine/game_session.dart';
import 'package:maze_adventure/features/maze/generator/maze_generator.dart';
import 'package:maze_adventure/features/maze/models/maze.dart';
import 'package:maze_adventure/features/maze/models/maze_size.dart';
import 'package:maze_adventure/features/maze/view/game_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

late AppController controller;

Future<AppServices> testBoot(AssetBundle bundle) async {
  final dir = await Directory.systemTemp.createTemp('maze_ui');
  final db = await AppDatabase.open(factory: databaseFactoryFfi, path: '${dir.path}/t.db');
  controller = AppController(db);
  await controller.load();
  final config = await GameConfig.load(bundle);
  return AppServices(
    controller: controller,
    audio: AudioService(enabled: false),
    config: config,
    purchases: PurchaseService(
        productId: config.fullUnlockProductId,
        onEntitled: controller.grantFullUnlock,
        enabled: false),
  );
}

Future<void> settle(WidgetTester tester, [int ms = 150]) async {
  await tester.runAsync(() => Future<void>.delayed(Duration(milliseconds: ms)));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  sqfliteFfiInit();

  testWidgets('play a whole maze from Home, offline', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.7;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MazeAdventureApp(boot: testBoot));
    for (var i = 0; i < 30 && find.text('PLAY').evaluate().isEmpty; i++) {
      await settle(tester, 100);
    }

    expect(find.text('Maze Adventure'), findsWidgets);
    expect(find.text('PLAY'), findsWidgets);

    await tester.tap(find.text('PLAY').last);
    await settle(tester);
    expect(find.text('Pick your buddy'), findsWidgets);
    expect(find.text('Milo'), findsWidgets);

    await tester.tap(find.text('Next').last);
    await settle(tester);
    expect(find.text('Choose a world'), findsWidgets);
    await tester.tap(find.text('Next').last);
    await settle(tester);
    expect(find.text('How big?'), findsWidgets);

    // Pick Tiny so the test maze is short.
    await tester.tap(find.text('Tiny'));
    await settle(tester);
    await tester.tap(find.text('GO!').last);
    await settle(tester);
    expect(find.byType(GameScreen), findsOneWidget);

    // Solve it with arrow keys along the shortest path (the keyboard slides
    // like a swipe, so press once per corridor segment and let it run).
    final state = tester.state(find.byType(GameScreen));
    final launchSeed = (state.widget as GameScreen).launch.seed;
    final maze = const MazeGenerator().generate(seed: launchSeed, size: MazeSize.tiny);
    final path = maze.shortestPath(maze.start, maze.goal);
    // Mirror the game's slide rule to know where each key press ends up.
    final sim = GameSession(maze: maze, size: MazeSize.tiny);
    var guard = 0;
    while (sim.position != maze.goal && guard++ < 50) {
      final next = path[path.indexOf(sim.position) + 1];
      final d = Direction.values.firstWhere((d) => sim.position.step(d) == next);
      final plan = sim.slidePlan(d);
      await tester.sendKeyEvent(switch (d) {
        Direction.up => LogicalKeyboardKey.arrowUp,
        Direction.down => LogicalKeyboardKey.arrowDown,
        Direction.left => LogicalKeyboardKey.arrowLeft,
        Direction.right => LogicalKeyboardKey.arrowRight,
      });
      for (final step in plan) {
        sim.step(step);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(sim.position, maze.goal);
    for (var i = 0; i < 8 && find.text('YOU DID IT!').evaluate().isEmpty; i++) {
      await settle(tester, 200);
    }
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('YOU DID IT!'), findsWidgets);
    expect(controller.stats.completed, 1);
    expect(controller.achievements.containsKey('firstMaze'), isTrue);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 900));
    // Next maze keeps playing without leaving the screen.
    await tester.tap(find.text('NEXT MAZE').last);
    await settle(tester);
    expect(find.text('YOU DID IT!'), findsNothing);
    expect(find.byType(GameScreen), findsOneWidget);

    // Pause → Home.
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await settle(tester);
    expect(find.text('Resume'), findsWidgets);
    await tester.tap(find.text('Home').last);
    await settle(tester);
    expect(find.text('PLAY'), findsWidgets);

    // Every menu screen opens.
    for (final label in ['Worlds', 'Characters', 'Achievements', 'My Journey', 'Settings']) {
      await tester.tap(find.text(label).first);
      await settle(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ScreenFrame), findsOneWidget, reason: label);
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      nav.popUntil((r) => r.isFirst);
      await settle(tester);
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text('PLAY'), findsWidgets);
  });
}
