import '../models/maze.dart';

/// Measured difficulty of one generated maze.
///
/// Grid size alone is a poor proxy — a 12×12 maze can be a single obvious
/// corridor or a thicket of forks — so the score combines the factors that
/// actually make a maze hard to read.
class DifficultyReport {
  const DifficultyReport({
    required this.cells,
    required this.pathLength,
    required this.deadEnds,
    required this.junctions,
    required this.decisionsOnPath,
    required this.turnsOnPath,
    required this.score,
  });

  final int cells;

  /// Steps on the shortest route from start to goal.
  final int pathLength;
  final int deadEnds;

  /// Cells with three or more exits.
  final int junctions;

  /// Junctions the player passes through on the correct route, i.e. places
  /// where they must choose.
  final int decisionsOnPath;

  /// Direction changes on the correct route (visual complexity).
  final int turnsOnPath;

  /// 0..100.
  final double score;

  double get branchingFactor => cells == 0 ? 0 : junctions / cells;
  double get deadEndRatio => cells == 0 ? 0 : deadEnds / cells;

  /// 1..6, aligned with the six maze sizes.
  int get stars6 => (score / 100 * 6).ceil().clamp(1, 6);
}

class DifficultyAnalyzer {
  const DifficultyAnalyzer();

  DifficultyReport analyze(Maze maze) {
    var deadEnds = 0;
    var junctions = 0;
    for (var y = 0; y < maze.rows; y++) {
      for (var x = 0; x < maze.columns; x++) {
        final exits = maze.exits(Pos(x, y)).length;
        if (exits == 1) deadEnds++;
        if (exits >= 3) junctions++;
      }
    }

    final path = maze.shortestPath(maze.start, maze.goal);
    var decisions = 0;
    var turns = 0;
    for (var i = 1; i < path.length - 1; i++) {
      if (maze.exits(path[i]).length >= 3) decisions++;
      final a = path[i - 1], b = path[i], c = path[i + 1];
      final straight = (a.x == b.x && b.x == c.x) || (a.y == b.y && b.y == c.y);
      if (!straight) turns++;
    }

    final cells = maze.cellCount;
    final pathLength = path.isEmpty ? 0 : path.length - 1;

    // Each term is normalised to roughly 0..1 across the Tiny..Extreme range.
    double norm(num v, num max) => (v / max).clamp(0, 1).toDouble();
    final sizeTerm = norm(cells, 1024);
    final pathTerm = norm(pathLength, 400);
    final branchTerm = norm(decisions, 40);
    final deadEndTerm = norm(deadEnds, 250);
    final visualTerm = norm(turns, 200);

    final score = 100 *
        (0.30 * sizeTerm +
            0.25 * pathTerm +
            0.20 * branchTerm +
            0.15 * deadEndTerm +
            0.10 * visualTerm);

    return DifficultyReport(
      cells: cells,
      pathLength: pathLength,
      deadEnds: deadEnds,
      junctions: junctions,
      decisionsOnPath: decisions,
      turnsOnPath: turns,
      score: score,
    );
  }
}
