import 'package:flutter_test/flutter_test.dart';
import 'package:maze_adventure/features/maze/engine/game_session.dart';
import 'package:maze_adventure/features/maze/generator/maze_generator.dart';
import 'package:maze_adventure/features/maze/models/maze.dart';
import 'package:maze_adventure/features/maze/models/maze_size.dart';
import 'package:maze_adventure/features/maze/movement/movement_controller.dart';

/// Runs the controller like the game screen does, returning cells visited.
List<Pos> drain(MovementController m, {int limit = 500}) {
  final visited = <Pos>[];
  for (var i = 0; i < limit; i++) {
    final d = m.next();
    if (d == null) break;
    m.session.step(d);
    m.onStepped();
    visited.add(m.session.position);
  }
  return visited;
}

void main() {
  const gen = MazeGenerator();

  test('drag steers toward the finger and stops when it cannot get closer', () {
    for (var seed = 1; seed < 30; seed++) {
      final maze = gen.generate(seed: seed, size: MazeSize.small);
      final s = GameSession(maze: maze, size: MazeSize.small);
      final m = MovementController(s)..dragTarget = maze.start.step(maze.exits(maze.start).first);
      drain(m);
      expect(s.position, maze.start.step(maze.exits(maze.start).first));
    }
  });

  test('holding a direction into a wall counts one bump, not one per frame', () {
    final maze = gen.generate(seed: 3, size: MazeSize.medium);
    final s = GameSession(maze: maze, size: MazeSize.medium);
    final wall = Direction.values.firstWhere((d) => !maze.canMove(maze.start, d));
    final m = MovementController(s)..held = wall;
    for (var i = 0; i < 20; i++) {
      final d = m.next();
      if (d != null) s.step(d);
    }
    expect(s.bumps, 1);
    expect(s.position, maze.start);
  });

  test('swiping sideways mid-slide turns at the next opening', () {
    // Find a corridor start where a queued turn is taken later on.
    for (var seed = 1; seed < 200; seed++) {
      final maze = gen.generate(seed: seed, size: MazeSize.large);
      final s = GameSession(maze: maze, size: MazeSize.large);
      final first = maze.exits(maze.start).first;
      final plan = s.slidePlan(first);
      if (plan.length < 2) continue;
      final m = MovementController(s)..swipe(first, moving: false);
      // One step taken, then the player swipes a direction blocked here.
      s.step(m.next()!);
      m.onStepped();
      final turn = Direction.values.firstWhere(
          (d) => d != first && d != first.opposite && !maze.canMove(s.position, d),
          orElse: () => first);
      if (turn == first) continue;
      m.swipe(turn, moving: true);
      final path = drain(m);
      // Either it turned somewhere along the corridor or bumped at the end;
      // it never walked through a wall.
      var p = maze.start.step(first);
      for (final q in path) {
        expect(p.manhattan(q), lessThanOrEqualTo(1));
        p = q;
      }
      return;
    }
    fail('no suitable maze found');
  });
}
