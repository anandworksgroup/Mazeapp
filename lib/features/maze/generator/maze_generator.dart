import '../models/maze.dart';
import '../models/maze_size.dart';
import 'seeded_random.dart';

/// Builds mazes from `(seed, size)`. Same inputs, same maze — always.
///
/// The core is the recursive backtracker (run iteratively so a 32×32 grid
/// cannot overflow the stack). Two knobs from the size's [GeneratorTuning]
/// shape the feel beyond raw grid size:
///
/// * `branchChance` — how often the carver resumes from a random earlier cell
///   instead of the newest one ("growing tree"). 0 is a pure backtracker with
///   long winding corridors; higher values add side branches and dead ends.
/// * `braidChance` — how many dead ends get knocked through afterwards,
///   creating loops. Small mazes use this to stay forgiving for young kids.
class MazeGenerator {
  const MazeGenerator();

  Maze generate({required int seed, required MazeSize size}) {
    final cols = size.columns;
    final rows = size.rows;
    final tuning = size.tuning;
    final rng = SeededRandom(seed ^ (cols * 73856093) ^ (rows * 19349663));
    final open = List<int>.filled(cols * rows, 0);
    final visited = List<bool>.filled(cols * rows, false);

    int index(Pos p) => p.y * cols + p.x;
    bool inside(Pos p) => p.x >= 0 && p.y >= 0 && p.x < cols && p.y < rows;

    void carve(Pos a, Direction d) {
      final b = a.step(d);
      open[index(a)] |= d.bit;
      open[index(b)] |= d.opposite.bit;
    }

    const start = Pos(0, 0);
    final active = <Pos>[start];
    visited[0] = true;

    while (active.isNotEmpty) {
      final pickIndex = rng.nextBool(tuning.branchChance)
          ? rng.nextInt(active.length)
          : active.length - 1;
      final current = active[pickIndex];

      final choices = <Direction>[
        for (final d in Direction.values)
          if (inside(current.step(d)) && !visited[index(current.step(d))]) d,
      ];
      if (choices.isEmpty) {
        active.removeAt(pickIndex);
        continue;
      }
      final d = choices[rng.nextInt(choices.length)];
      final next = current.step(d);
      carve(current, d);
      visited[index(next)] = true;
      active.add(next);
    }

    if (tuning.braidChance > 0) {
      for (var y = 0; y < rows; y++) {
        for (var x = 0; x < cols; x++) {
          final p = Pos(x, y);
          if (p == start) continue;
          final mask = open[index(p)];
          if (_bitCount(mask) != 1) continue;
          if (!rng.nextBool(tuning.braidChance)) continue;
          final walls = <Direction>[
            for (final d in Direction.values)
              if (mask & d.bit == 0 && inside(p.step(d))) d,
          ];
          if (walls.isEmpty) continue;
          carve(p, walls[rng.nextInt(walls.length)]);
        }
      }
    }

    final draft = Maze(
      columns: cols,
      rows: rows,
      seed: seed,
      openings: open,
      start: start,
      goal: start,
    );
    return Maze(
      columns: cols,
      rows: rows,
      seed: seed,
      openings: open,
      start: start,
      goal: _pickGoal(draft),
    );
  }

  /// The goal is the edge cell farthest (by walking distance) from the start,
  /// which gives the longest solution while keeping the goal easy to spot.
  static Pos _pickGoal(Maze maze) {
    final dist = maze.distancesFrom(maze.start);
    var best = Pos(maze.columns - 1, maze.rows - 1);
    var bestDist = -1;
    for (var y = 0; y < maze.rows; y++) {
      for (var x = 0; x < maze.columns; x++) {
        final onEdge =
            x == 0 || y == 0 || x == maze.columns - 1 || y == maze.rows - 1;
        if (!onEdge) continue;
        final d = dist[y * maze.columns + x];
        // Ties go to the cell nearer the bottom-right, the "natural" exit.
        if (d > bestDist || (d == bestDist && x + y > best.x + best.y)) {
          bestDist = d;
          best = Pos(x, y);
        }
      }
    }
    return best;
  }

  static int _bitCount(int v) {
    var c = 0;
    while (v != 0) {
      c += v & 1;
      v >>= 1;
    }
    return c;
  }
}
