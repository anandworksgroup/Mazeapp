import 'dart:collection';

/// The four moves a character can make. Each owns one wall bit.
enum Direction {
  up(0, -1, 1),
  right(1, 0, 2),
  down(0, 1, 4),
  left(-1, 0, 8);

  const Direction(this.dx, this.dy, this.bit);

  final int dx;
  final int dy;
  final int bit;

  Direction get opposite => switch (this) {
        Direction.up => Direction.down,
        Direction.down => Direction.up,
        Direction.left => Direction.right,
        Direction.right => Direction.left,
      };

  bool get isHorizontal => dx != 0;
}

/// A cell coordinate: [x] is the column, [y] the row.
class Pos {
  const Pos(this.x, this.y);

  final int x;
  final int y;

  Pos step(Direction d) => Pos(x + d.dx, y + d.dy);

  int manhattan(Pos other) => (x - other.x).abs() + (y - other.y).abs();

  @override
  bool operator ==(Object other) => other is Pos && other.x == x && other.y == y;

  @override
  int get hashCode => x * 7919 + y;

  @override
  String toString() => '($x,$y)';
}

/// A perfect-or-braided grid maze.
///
/// Each cell stores a bitmask of *open* sides (see [Direction.bit]). Walls are
/// the absence of a bit, so a fresh grid is all walls and carving sets bits on
/// both neighbouring cells.
class Maze {
  Maze({
    required this.columns,
    required this.rows,
    required this.seed,
    required List<int> openings,
    required this.start,
    required this.goal,
  }) : _open = List.unmodifiable(openings);

  final int columns;
  final int rows;
  final int seed;
  final Pos start;
  final Pos goal;
  final List<int> _open;

  int get cellCount => columns * rows;

  bool contains(Pos p) => p.x >= 0 && p.y >= 0 && p.x < columns && p.y < rows;

  int openingsAt(Pos p) => _open[p.y * columns + p.x];

  /// True when the character can step from [p] towards [d].
  bool canMove(Pos p, Direction d) {
    if (!contains(p)) return false;
    return openingsAt(p) & d.bit != 0 && contains(p.step(d));
  }

  List<Direction> exits(Pos p) =>
      [for (final d in Direction.values) if (canMove(p, d)) d];

  /// Breadth-first distances from [from] to every cell (-1 = unreachable).
  List<int> distancesFrom(Pos from) {
    final dist = List<int>.filled(cellCount, -1);
    final queue = Queue<Pos>()..add(from);
    dist[from.y * columns + from.x] = 0;
    while (queue.isNotEmpty) {
      final p = queue.removeFirst();
      final base = dist[p.y * columns + p.x];
      for (final d in Direction.values) {
        if (!canMove(p, d)) continue;
        final n = p.step(d);
        final i = n.y * columns + n.x;
        if (dist[i] == -1) {
          dist[i] = base + 1;
          queue.add(n);
        }
      }
    }
    return dist;
  }

  /// Shortest path from [from] to [to], inclusive of both ends.
  List<Pos> shortestPath(Pos from, Pos to) {
    final dist = distancesFrom(to);
    if (dist[from.y * columns + from.x] < 0) return const [];
    final path = <Pos>[from];
    var p = from;
    while (p != to) {
      final here = dist[p.y * columns + p.x];
      p = exits(p)
          .map(p.step)
          .firstWhere((n) => dist[n.y * columns + n.x] == here - 1);
      path.add(p);
    }
    return path;
  }
}
