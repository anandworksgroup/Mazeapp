import '../models/maze.dart';
import '../models/maze_size.dart';

enum StepOutcome { moved, blocked, reachedGoal }

/// Rules and bookkeeping for one maze run. Pure Dart: no timers, no widgets.
/// The UI feeds it moves and elapsed time; persistence snapshots it.
class GameSession {
  GameSession({
    required this.maze,
    required this.size,
    Pos? position,
    this.moves = 0,
    this.bumps = 0,
    this.elapsedMs = 0,
    Iterable<Pos>? trail,
  })  : position = position ?? maze.start,
        optimalSteps = maze.shortestPath(maze.start, maze.goal).length - 1 {
    _trail.addAll(trail ?? [this.position]);
  }

  final Maze maze;
  final MazeSize size;
  final int optimalSteps;

  Pos position;
  int moves;

  /// Attempts to walk into a wall. Zero bumps = a "perfect" maze.
  int bumps;
  int elapsedMs;
  final List<Pos> _trail = [];

  bool get isComplete => position == maze.goal;
  List<Pos> get trail => List.unmodifiable(_trail);

  /// Collision check then move — the only way the position changes.
  StepOutcome step(Direction d) {
    if (isComplete) return StepOutcome.reachedGoal;
    if (!maze.canMove(position, d)) {
      bumps++;
      return StepOutcome.blocked;
    }
    position = position.step(d);
    moves++;
    // Walking back over your own trail rewinds it, so the breadcrumb line
    // always shows the route from the start rather than every wander.
    final existing = _trail.lastIndexOf(position);
    if (existing >= 0) {
      _trail.removeRange(existing + 1, _trail.length);
    } else {
      _trail.add(position);
    }
    return isComplete ? StepOutcome.reachedGoal : StepOutcome.moved;
  }

  /// The cells a swipe travels through: keep going in [d] until a wall, a
  /// side opening (a choice the player should make) or the goal.
  List<Direction> slidePlan(Direction d) {
    final plan = <Direction>[];
    var p = position;
    while (maze.canMove(p, d)) {
      p = p.step(d);
      plan.add(d);
      if (p == maze.goal) break;
      final sideExits = maze
          .exits(p)
          .where((e) => e != d && e != d.opposite)
          .length;
      if (sideExits > 0) break;
    }
    return plan;
  }

  /// Stars are generous by design: finishing always earns one.
  int get stars {
    if (!isComplete) return 0;
    final efficiency = optimalSteps / moves.clamp(1, 1 << 30);
    final parMs = (optimalSteps * size.parSecondsPerStep + 4) * 1000;
    var points = 0;
    if (efficiency >= 0.8) {
      points += 2;
    } else if (efficiency >= 0.5) {
      points += 1;
    }
    if (elapsedMs <= parMs) {
      points += 2;
    } else if (elapsedMs <= parMs * 2) {
      points += 1;
    }
    if (bumps <= 2) points += 1;
    if (points >= 4) return 3;
    if (points >= 2) return 2;
    return 1;
  }

  bool get isPerfect => isComplete && bumps == 0;
}
