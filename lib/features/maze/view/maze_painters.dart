import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/catalog.dart';
import '../../themes/world_art.dart';
import '../generator/seeded_random.dart';
import '../models/maze.dart';

const _ink = Color(0xFF3B2418);

/// Wall geometry merged into long straight runs, computed once per maze.
class MazeGeometry {
  MazeGeometry(this.maze) {
    final cols = maze.columns, rows = maze.rows;
    // Horizontal walls along row edge y (0..rows).
    for (var y = 0; y <= rows; y++) {
      int? runStart;
      for (var x = 0; x <= cols; x++) {
        final wall = x < cols &&
            (y == rows
                ? true
                : !maze.canMove(Pos(x, y), Direction.up));
        if (wall && runStart == null) runStart = x;
        if (!wall && runStart != null) {
          horizontal.add((y, runStart, x));
          runStart = null;
        }
      }
    }
    for (var x = 0; x <= cols; x++) {
      int? runStart;
      for (var y = 0; y <= rows; y++) {
        final wall = y < rows &&
            (x == cols ? true : !maze.canMove(Pos(x, y), Direction.left));
        if (wall && runStart == null) runStart = y;
        if (!wall && runStart != null) {
          vertical.add((x, runStart, y));
          runStart = null;
        }
      }
    }
    final rng = SeededRandom(maze.seed ^ 0x5bd1e995);
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        final p = Pos(x, y);
        if (p == maze.start || p == maze.goal) continue;
        final exits = maze.exits(p);
        if (exits.length == 1 && rng.nextBool(0.28)) {
          decorated.add((p, exits.single, rng.nextInt(1000)));
        }
      }
    }
  }

  final Maze maze;

  /// (row edge y, from column, to column)
  final List<(int, int, int)> horizontal = [];

  /// (column edge x, from row, to row)
  final List<(int, int, int)> vertical = [];

  /// Dead ends that get a small decoration: (cell, open side, variant).
  final List<(Pos, Direction, int)> decorated = [];

  Path wallPath(double cell, Offset origin) {
    final path = Path();
    for (final (y, x0, x1) in horizontal) {
      path
        ..moveTo(origin.dx + x0 * cell, origin.dy + y * cell)
        ..lineTo(origin.dx + x1 * cell, origin.dy + y * cell);
    }
    for (final (x, y0, y1) in vertical) {
      path
        ..moveTo(origin.dx + x * cell, origin.dy + y0 * cell)
        ..lineTo(origin.dx + x * cell, origin.dy + y1 * cell);
    }
    return path;
  }
}

/// The maze itself: board, floor, decorations and walls. Only repaints when
/// the maze, world or scale changes.
class MazeBoardPainter extends CustomPainter {
  MazeBoardPainter({
    required this.geometry,
    required this.world,
    required this.cell,
    required this.padding,
    required this.highContrast,
  });

  final MazeGeometry geometry;
  final WorldDef world;
  final double cell;
  final double padding;
  final bool highContrast;

  static double wallWidth(double cell) => (cell * 0.24).clamp(3.0, 20.0);

  @override
  void paint(Canvas canvas, Size size) {
    final maze = geometry.maze;
    final origin = Offset(padding, padding);
    final board = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(padding * 1.2));
    final floor = highContrast ? Colors.white : world.floor;
    final floorAlt = highContrast ? Colors.white : world.floorAlt;
    final wall = highContrast ? Colors.black : world.wall;
    final wallTop = highContrast ? Colors.black : world.wallTop;

    // Board with a chunky illustrated rim.
    canvas.drawRRect(board.shift(const Offset(0, 6)), Paint()..color = Colors.black.withValues(alpha: 0.2));
    canvas.drawRRect(board, Paint()..color = highContrast ? Colors.white : world.wallTop);
    canvas.drawRRect(
        board.deflate(padding * 0.35), Paint()..color = floor);
    canvas.drawRRect(
        board,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = _ink);

    // Checker floor tiles.
    if (!highContrast) {
      final alt = Paint()..color = floorAlt;
      for (var y = 0; y < maze.rows; y++) {
        for (var x = (y.isEven ? 1 : 0); x < maze.columns; x += 2) {
          canvas.drawRect(
              Rect.fromLTWH(origin.dx + x * cell, origin.dy + y * cell, cell, cell), alt);
        }
      }
    }

    // Start pad.
    final startC = origin + Offset((maze.start.x + 0.5) * cell, (maze.start.y + 0.5) * cell);
    canvas.drawCircle(startC, cell * 0.36, Paint()..color = (highContrast ? Colors.black : world.trail).withValues(alpha: 0.35));
    canvas.drawCircle(
        startC,
        cell * 0.36,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.5, cell * 0.05)
          ..color = (highContrast ? Colors.black : _ink).withValues(alpha: 0.5));

    // Small decorations tucked into dead ends, against the closed back wall.
    if (!highContrast && cell >= 18) {
      for (final (p, open, variant) in geometry.decorated) {
        final c = origin +
            Offset((p.x + 0.5) * cell, (p.y + 0.5) * cell) -
            Offset(open.dx.toDouble(), open.dy.toDouble()) * cell * 0.12;
        final d = world.decorations[variant % world.decorations.length];
        WorldArt.decoration(canvas, d, c, cell * 0.5);
      }
    }

    // Walls: shadow, ink outline, body, highlight.
    final ww = wallWidth(cell);
    final path = geometry.wallPath(cell, origin);
    Paint stroke(double w, Color c) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = c;
    canvas.drawPath(path.shift(Offset(0, ww * 0.45)), stroke(ww, Colors.black.withValues(alpha: 0.22)));
    canvas.drawPath(path, stroke(ww + (highContrast ? 0 : 3), _ink));
    canvas.drawPath(path, stroke(ww, wall));
    if (!highContrast) {
      canvas.drawPath(path.shift(Offset(0, -ww * 0.14)), stroke(ww * 0.38, wallTop));
    }
  }

  @override
  bool shouldRepaint(MazeBoardPainter old) =>
      old.geometry != geometry ||
      old.world != world ||
      old.cell != cell ||
      old.highContrast != highContrast;
}

/// Breadcrumb trail and the pulsing goal, repainted as the player moves.
class MazeOverlayPainter extends CustomPainter {
  MazeOverlayPainter({
    required this.maze,
    required this.world,
    required this.trail,
    required this.cell,
    required this.padding,
    required this.t,
    required this.highContrast,
    required this.showGoal,
  });

  final Maze maze;
  final WorldDef world;
  final List<Pos> trail;
  final double cell;
  final double padding;
  final double t;
  final bool highContrast;
  final bool showGoal;

  Offset _center(Pos p) =>
      Offset(padding + (p.x + 0.5) * cell, padding + (p.y + 0.5) * cell);

  @override
  void paint(Canvas canvas, Size size) {
    if (trail.length > 1) {
      final path = Path()..moveTo(_center(trail.first).dx, _center(trail.first).dy);
      for (final p in trail.skip(1)) {
        path.lineTo(_center(p).dx, _center(p).dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = cell * 0.18
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = (highContrast ? const Color(0xFF0066DD) : world.trail).withValues(alpha: 0.55),
      );
    }
    if (showGoal) {
      WorldArt.goal(canvas, world.goal, _center(maze.goal), cell * 0.95, t: t);
    }
  }

  @override
  bool shouldRepaint(MazeOverlayPainter old) =>
      old.trail.length != trail.length ||
      (trail.isNotEmpty && old.trail.last != trail.last) ||
      old.t != t ||
      old.cell != cell ||
      old.showGoal != showGoal;
}

/// Tiny whole-maze overview for big mazes, with the player and goal.
class MiniMapPainter extends CustomPainter {
  MiniMapPainter({
    required this.geometry,
    required this.world,
    required this.player,
    required this.viewport,
  });

  final MazeGeometry geometry;
  final WorldDef world;
  final Offset player;

  /// Visible region in cell units.
  final Rect viewport;

  @override
  void paint(Canvas canvas, Size size) {
    final maze = geometry.maze;
    final cell = size.width / maze.columns;
    canvas.drawRect(Offset.zero & size, Paint()..color = world.floor);
    canvas.drawPath(
      geometry.wallPath(cell, Offset.zero),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, cell * 0.3)
        ..strokeCap = StrokeCap.square
        ..color = world.wall,
    );
    canvas.drawRect(
      Rect.fromLTWH(viewport.left * cell, viewport.top * cell,
          viewport.width * cell, viewport.height * cell),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _ink.withValues(alpha: 0.6),
    );
    canvas.drawCircle(
        Offset((maze.goal.x + 0.5) * cell, (maze.goal.y + 0.5) * cell),
        math.max(2.5, cell * 0.6),
        Paint()..color = const Color(0xFFFFC53D));
    canvas.drawCircle(
        Offset((player.dx + 0.5) * cell, (player.dy + 0.5) * cell),
        math.max(3, cell * 0.7),
        Paint()..color = const Color(0xFFE63946));
  }

  @override
  bool shouldRepaint(MiniMapPainter old) =>
      old.player != player || old.viewport != viewport || old.geometry != geometry;
}

/// Confetti burst for a finished maze.
class ConfettiPainter extends CustomPainter {
  ConfettiPainter({required this.progress, required this.seed});

  final double progress;
  final int seed;

  static const _colors = [
    Color(0xFFFF6B6B),
    Color(0xFFFFD23F),
    Color(0xFF6BCB4B),
    Color(0xFF4DB6F0),
    Color(0xFFA880F0),
    Color(0xFFFF8FB1),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final rng = SeededRandom(seed);
    for (var i = 0; i < 90; i++) {
      final x0 = rng.nextDouble() * size.width;
      final speed = 0.6 + rng.nextDouble() * 0.8;
      final sway = (rng.nextDouble() - 0.5) * 80;
      final y = -20 + progress * speed * size.height * 1.3;
      final x = x0 + math.sin(progress * 10 + i) * sway * 0.3 + sway * progress;
      final rot = progress * 12 * (rng.nextDouble() - 0.5);
      final color = _colors[i % _colors.length];
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      final w = 6 + rng.nextDouble() * 6;
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w, height: w * 0.55),
              const Radius.circular(2)),
          Paint()..color = color.withValues(alpha: 1 - progress * 0.6));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter old) => old.progress != progress;
}

/// Renders a maze preview image for size cards (cheap, static).
void paintMazeThumbnail(Canvas canvas, Size size, MazeGeometry g, WorldDef world) {
  final maze = g.maze;
  final cell = math.min(size.width / maze.columns, size.height / maze.rows);
  final offset = Offset((size.width - cell * maze.columns) / 2, (size.height - cell * maze.rows) / 2);
  canvas.drawRRect(
      RRect.fromRectAndRadius(offset & Size(cell * maze.columns, cell * maze.rows), const Radius.circular(4)),
      Paint()..color = world.floor);
  canvas.drawPath(
    g.wallPath(cell, offset),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, cell * 0.28)
      ..strokeCap = StrokeCap.round
      ..color = world.wall,
  );
}
