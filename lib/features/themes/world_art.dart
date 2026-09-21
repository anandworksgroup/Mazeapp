import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/catalog.dart';
import '../maze/generator/seeded_random.dart';

const _ink = Color(0xFF3B2418);

Paint _fill(Color c) => Paint()..color = c;

Paint _line(double w, [Color c = _ink]) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeJoin = StrokeJoin.round
  ..strokeCap = StrokeCap.round
  ..color = c;

void _outlined(Canvas c, Path p, Color color, double w) {
  c.drawPath(p, _fill(color));
  c.drawPath(p, _line(w));
}

Path _circle(Offset c, double r) => Path()..addOval(Rect.fromCircle(center: c, radius: r));

/// Original vector illustrations for world decorations and goals.
class WorldArt {
  WorldArt._();

  /// Draws a decoration centred on [c] fitting in a box of side [s].
  static void decoration(Canvas canvas, Deco d, Offset c, double s, {double t = 0}) {
    final w = math.max(1.2, s * 0.05);
    switch (d) {
      case Deco.tree:
        canvas.drawRect(Rect.fromCenter(center: c + Offset(0, s * 0.28), width: s * 0.16, height: s * 0.3),
            _fill(const Color(0xFF8B5A2B)));
        canvas.drawRect(Rect.fromCenter(center: c + Offset(0, s * 0.28), width: s * 0.16, height: s * 0.3), _line(w));
        final crown = Path()
          ..addOval(Rect.fromCircle(center: c + Offset(0, -s * 0.12), radius: s * 0.28))
          ..addOval(Rect.fromCircle(center: c + Offset(-s * 0.18, s * 0.05), radius: s * 0.2))
          ..addOval(Rect.fromCircle(center: c + Offset(s * 0.18, s * 0.05), radius: s * 0.2));
        _outlined(canvas, crown, const Color(0xFF5DB047), w);
        canvas.drawCircle(c + Offset(-s * 0.08, -s * 0.2), s * 0.07, _fill(Colors.white.withValues(alpha: 0.3)));
      case Deco.pine:
        for (var i = 0; i < 3; i++) {
          final y = c.dy - s * 0.3 + i * s * 0.18;
          final half = s * (0.16 + i * 0.08);
          final tri = Path()
            ..moveTo(c.dx, y - s * 0.12)
            ..lineTo(c.dx + half, y + s * 0.14)
            ..lineTo(c.dx - half, y + s * 0.14)
            ..close();
          _outlined(canvas, tri, const Color(0xFF3F8F6B), w);
          canvas.drawLine(Offset(c.dx - half * 0.7, y + s * 0.12), Offset(c.dx + half * 0.7, y + s * 0.12),
              _line(w * 1.5, Colors.white));
        }
      case Deco.flower:
        final petal = const Color(0xFFFF8FB1);
        for (var i = 0; i < 5; i++) {
          final a = i / 5 * 2 * math.pi + t * 0.5;
          _outlined(canvas, _circle(c + Offset(math.cos(a), math.sin(a)) * s * 0.18, s * 0.14), petal, w);
        }
        _outlined(canvas, _circle(c, s * 0.12), const Color(0xFFFFD23F), w);
      case Deco.mushroom:
        final stem = Path()
          ..addRRect(RRect.fromRectAndRadius(
              Rect.fromCenter(center: c + Offset(0, s * 0.15), width: s * 0.24, height: s * 0.3),
              Radius.circular(s * 0.08)));
        _outlined(canvas, stem, const Color(0xFFFFF1DC), w);
        final cap = Path()
          ..addArc(Rect.fromCenter(center: c + Offset(0, s * 0.02), width: s * 0.7, height: s * 0.56), math.pi, math.pi)
          ..close();
        _outlined(canvas, cap, const Color(0xFFE63946), w);
        for (final o in [Offset(-s * 0.15, -s * 0.1), Offset(s * 0.12, -s * 0.14), Offset(0, -s * 0.04)]) {
          canvas.drawCircle(c + o, s * 0.05, _fill(Colors.white));
        }
      case Deco.car:
        final body = Path()
          ..addRRect(RRect.fromRectAndRadius(
              Rect.fromCenter(center: c + Offset(0, s * 0.05), width: s * 0.8, height: s * 0.3),
              Radius.circular(s * 0.1)))
          ..addRRect(RRect.fromRectAndRadius(
              Rect.fromCenter(center: c + Offset(-s * 0.04, -s * 0.12), width: s * 0.44, height: s * 0.24),
              Radius.circular(s * 0.1)));
        _outlined(canvas, body, const Color(0xFFFF6B6B), w);
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(center: c + Offset(-s * 0.04, -s * 0.12), width: s * 0.3, height: s * 0.13),
                Radius.circular(s * 0.04)),
            _fill(const Color(0xFFBDE7FF)));
        for (final dx in [-0.22, 0.22]) {
          _outlined(canvas, _circle(c + Offset(s * dx, s * 0.22), s * 0.1), const Color(0xFF3D3B45), w);
        }
      case Deco.sign:
        canvas.drawLine(c + Offset(0, s * 0.1), c + Offset(0, s * 0.42), _line(s * 0.08, const Color(0xFF7D7A8C)));
        final octagon = Path();
        for (var i = 0; i < 8; i++) {
          final a = i / 8 * 2 * math.pi + math.pi / 8;
          final p = c + Offset(math.cos(a), math.sin(a)) * s * 0.26 + Offset(0, -s * 0.1);
          i == 0 ? octagon.moveTo(p.dx, p.dy) : octagon.lineTo(p.dx, p.dy);
        }
        octagon.close();
        _outlined(canvas, octagon, const Color(0xFFFFC53D), w);
        canvas.drawLine(c + Offset(-s * 0.1, -s * 0.1), c + Offset(s * 0.1, -s * 0.1), _line(w * 1.4));
      case Deco.tower:
        final tower = Path()
          ..addRect(Rect.fromCenter(center: c + Offset(0, s * 0.1), width: s * 0.44, height: s * 0.6));
        for (final dx in [-0.16, 0.0, 0.16]) {
          tower.addRect(Rect.fromCenter(center: c + Offset(s * dx, -s * 0.24), width: s * 0.11, height: s * 0.12));
        }
        _outlined(canvas, tower, const Color(0xFFB9B4C7), w);
        final door = Path()
          ..addRRect(RRect.fromRectAndCorners(
              Rect.fromCenter(center: c + Offset(0, s * 0.28), width: s * 0.16, height: s * 0.22),
              topLeft: Radius.circular(s * 0.08), topRight: Radius.circular(s * 0.08)));
        _outlined(canvas, door, const Color(0xFF7A4E2D), w);
        canvas.drawLine(c + Offset(0, -s * 0.3), c + Offset(0, -s * 0.48), _line(w));
        final flag = Path()
          ..moveTo(c.dx, c.dy - s * 0.48)
          ..lineTo(c.dx + s * 0.18, c.dy - s * 0.42 + math.sin(t * 6) * s * 0.02)
          ..lineTo(c.dx, c.dy - s * 0.36)
          ..close();
        _outlined(canvas, flag, const Color(0xFFE63946), w * 0.8);
      case Deco.torch:
        canvas.drawLine(c + Offset(0, -s * 0.02), c + Offset(0, s * 0.4), _line(s * 0.1, const Color(0xFF7A4E2D)));
        final flicker = 1 + math.sin(t * 9) * 0.08;
        final flame = Path()
          ..moveTo(c.dx, c.dy - s * 0.4 * flicker)
          ..quadraticBezierTo(c.dx + s * 0.2, c.dy - s * 0.08, c.dx, c.dy)
          ..quadraticBezierTo(c.dx - s * 0.2, c.dy - s * 0.08, c.dx, c.dy - s * 0.4 * flicker);
        _outlined(canvas, flame, const Color(0xFFFF9F1C), w);
        canvas.drawCircle(c + Offset(0, -s * 0.1), s * 0.06, _fill(const Color(0xFFFFE066)));
      case Deco.shell:
        final shell = Path()
          ..moveTo(c.dx, c.dy + s * 0.3)
          ..lineTo(c.dx - s * 0.32, c.dy - s * 0.05)
          ..arcToPoint(c + Offset(s * 0.32, -s * 0.05), radius: Radius.circular(s * 0.32))
          ..close();
        _outlined(canvas, shell, const Color(0xFFFFB5A7), w);
        for (final dx in [-0.16, 0.0, 0.16]) {
          canvas.drawLine(c + Offset(0, s * 0.28), c + Offset(s * dx, -s * 0.22), _line(w * 0.7));
        }
      case Deco.coral:
        final coral = _line(s * 0.12, const Color(0xFFFF6F91));
        final path = Path()
          ..moveTo(c.dx, c.dy + s * 0.4)
          ..lineTo(c.dx, c.dy - s * 0.05)
          ..moveTo(c.dx, c.dy + s * 0.1)
          ..quadraticBezierTo(c.dx - s * 0.25, c.dy, c.dx - s * 0.22, c.dy - s * 0.3)
          ..moveTo(c.dx, c.dy + s * 0.02)
          ..quadraticBezierTo(c.dx + s * 0.25, c.dy - s * 0.05, c.dx + s * 0.2, c.dy - s * 0.38);
        canvas.drawPath(path, _line(s * 0.12 + w * 2));
        canvas.drawPath(path, coral);
      case Deco.fish:
        final bob = math.sin(t * 3) * s * 0.04;
        final fish = Path()
          ..addOval(Rect.fromCenter(center: c + Offset(-s * 0.05, bob), width: s * 0.5, height: s * 0.32))
          ..moveTo(c.dx + s * 0.15, c.dy + bob)
          ..lineTo(c.dx + s * 0.38, c.dy - s * 0.15 + bob)
          ..lineTo(c.dx + s * 0.38, c.dy + s * 0.15 + bob)
          ..close();
        _outlined(canvas, fish, const Color(0xFFFFB347), w);
        canvas.drawCircle(c + Offset(-s * 0.17, -s * 0.03 + bob), s * 0.04, _fill(_ink));
      case Deco.snowman:
        _outlined(canvas, _circle(c + Offset(0, s * 0.18), s * 0.24), Colors.white, w);
        _outlined(canvas, _circle(c + Offset(0, -s * 0.17), s * 0.17), Colors.white, w);
        canvas.drawCircle(c + Offset(-s * 0.06, -s * 0.2), s * 0.03, _fill(_ink));
        canvas.drawCircle(c + Offset(s * 0.06, -s * 0.2), s * 0.03, _fill(_ink));
        final nose = Path()
          ..moveTo(c.dx, c.dy - s * 0.15)
          ..lineTo(c.dx + s * 0.14, c.dy - s * 0.12)
          ..lineTo(c.dx, c.dy - s * 0.1)
          ..close();
        canvas.drawPath(nose, _fill(const Color(0xFFFF8C42)));
        canvas.drawRect(Rect.fromCenter(center: c + Offset(0, -s * 0.03), width: s * 0.3, height: s * 0.06),
            _fill(const Color(0xFFE63946)));
      case Deco.rock:
        final rock = Path()
          ..moveTo(c.dx - s * 0.35, c.dy + s * 0.25)
          ..lineTo(c.dx - s * 0.25, c.dy - s * 0.1)
          ..lineTo(c.dx - s * 0.02, c.dy - s * 0.25)
          ..lineTo(c.dx + s * 0.28, c.dy - s * 0.08)
          ..lineTo(c.dx + s * 0.35, c.dy + s * 0.25)
          ..close();
        _outlined(canvas, rock, const Color(0xFF6D5D5A), w);
        canvas.drawLine(c + Offset(-s * 0.05, -s * 0.1), c + Offset(s * 0.05, s * 0.1),
            _line(w * 1.2, const Color(0xFFFF7B39)));
      case Deco.ember:
        final r = s * (0.12 + 0.03 * math.sin(t * 5));
        canvas.drawCircle(c, r * 2, _fill(const Color(0xFFFF7B39).withValues(alpha: 0.25)));
        _outlined(canvas, _circle(c, r), const Color(0xFFFFB627), w);
      case Deco.star:
        final r = s * 0.3 * (0.9 + 0.1 * math.sin(t * 4));
        final star = Path();
        for (var i = 0; i < 10; i++) {
          final a = -math.pi / 2 + i * math.pi / 5;
          final rr = i.isEven ? r : r * 0.45;
          final p = c + Offset(math.cos(a), math.sin(a)) * rr;
          i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
        }
        star.close();
        _outlined(canvas, star, const Color(0xFFFFE066), w);
      case Deco.planet:
        _outlined(canvas, _circle(c, s * 0.22), const Color(0xFF7CC6FE), w);
        canvas.drawOval(Rect.fromCenter(center: c, width: s * 0.72, height: s * 0.16), _line(w * 1.6, const Color(0xFFFFD166)));
      case Deco.lollipop:
        canvas.drawLine(c + Offset(0, s * 0.05), c + Offset(0, s * 0.44), _line(s * 0.07, Colors.white));
        _outlined(canvas, _circle(c + Offset(0, -s * 0.1), s * 0.25), const Color(0xFFFF7EB6), w);
        final swirl = Path();
        for (var i = 0; i < 40; i++) {
          final a = i / 40 * 4 * math.pi;
          final p = c + Offset(0, -s * 0.1) + Offset(math.cos(a), math.sin(a)) * (s * 0.2 * i / 40);
          i == 0 ? swirl.moveTo(p.dx, p.dy) : swirl.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(swirl, _line(w, Colors.white));
      case Deco.candyCane:
        final cane = Path()
          ..moveTo(c.dx + s * 0.05, c.dy + s * 0.42)
          ..lineTo(c.dx + s * 0.05, c.dy - s * 0.15)
          ..arcToPoint(c + Offset(-s * 0.25, -s * 0.15), radius: Radius.circular(s * 0.15), clockwise: false);
        canvas.drawPath(cane, _line(s * 0.14 + w * 2));
        canvas.drawPath(cane, _line(s * 0.14, Colors.white));
        // Red stripes: dash the same path.
        final stripe = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.14
          ..color = const Color(0xFFE63946);
        for (final metric in cane.computeMetrics()) {
          for (var d = 0.0; d < metric.length; d += s * 0.16) {
            canvas.drawPath(metric.extractPath(d, d + s * 0.08), stripe);
          }
        }
    }
  }

  /// The goal marker for a world, with a gentle pulse from [t].
  static void goal(Canvas canvas, GoalKind kind, Offset c, double s, {double t = 0}) {
    final pulse = 1 + 0.06 * math.sin(t * 2 * math.pi);
    canvas.drawCircle(c, s * 0.46 * pulse, _fill(Colors.white.withValues(alpha: 0.45)));
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(pulse);
    canvas.translate(-c.dx, -c.dy);
    final w = math.max(1.4, s * 0.05);
    switch (kind) {
      case GoalKind.flower:
        canvas.drawLine(c + Offset(0, s * 0.05), c + Offset(0, s * 0.4), _line(s * 0.08, const Color(0xFF3E8E41)));
        for (var i = 0; i < 6; i++) {
          final a = i / 6 * 2 * math.pi;
          _outlined(canvas, _circle(c + Offset(math.cos(a), math.sin(a)) * s * 0.17 + Offset(0, -s * 0.08), s * 0.13),
              const Color(0xFFFF6FA5), w);
        }
        _outlined(canvas, _circle(c + Offset(0, -s * 0.08), s * 0.12), const Color(0xFFFFD23F), w);
      case GoalKind.cake:
        final base = Path()
          ..addRRect(RRect.fromRectAndRadius(
              Rect.fromCenter(center: c + Offset(0, s * 0.14), width: s * 0.66, height: s * 0.34), Radius.circular(s * 0.08)));
        _outlined(canvas, base, const Color(0xFFFFD8A8), w);
        final icing = Path()
          ..moveTo(c.dx - s * 0.33, c.dy + s * 0.02)
          ..quadraticBezierTo(c.dx - s * 0.22, c.dy + s * 0.14, c.dx - s * 0.11, c.dy + s * 0.02)
          ..quadraticBezierTo(c.dx, c.dy + s * 0.14, c.dx + s * 0.11, c.dy + s * 0.02)
          ..quadraticBezierTo(c.dx + s * 0.22, c.dy + s * 0.14, c.dx + s * 0.33, c.dy + s * 0.02)
          ..lineTo(c.dx + s * 0.33, c.dy - s * 0.04)
          ..lineTo(c.dx - s * 0.33, c.dy - s * 0.04)
          ..close();
        _outlined(canvas, icing, const Color(0xFFFF8FB1), w);
        canvas.drawLine(c + Offset(0, -s * 0.05), c + Offset(0, -s * 0.24), _line(s * 0.06, const Color(0xFF7CC6FE)));
        _outlined(canvas, _circle(c + Offset(0, -s * 0.3), s * 0.06), const Color(0xFFFFC53D), w * 0.7);
      case GoalKind.treasure:
        final chest = Path()
          ..addRRect(RRect.fromRectAndRadius(
              Rect.fromCenter(center: c + Offset(0, s * 0.1), width: s * 0.7, height: s * 0.4), Radius.circular(s * 0.06)));
        _outlined(canvas, chest, const Color(0xFFB5733A), w);
        final lid = Path()
          ..addArc(Rect.fromCenter(center: c + Offset(0, -s * 0.08), width: s * 0.7, height: s * 0.36), math.pi, math.pi)
          ..close();
        _outlined(canvas, lid, const Color(0xFFD08C4B), w);
        canvas.drawRect(Rect.fromCenter(center: c + Offset(0, s * 0.04), width: s * 0.12, height: s * 0.16),
            _fill(const Color(0xFFFFD23F)));
        canvas.drawRect(Rect.fromCenter(center: c + Offset(0, s * 0.04), width: s * 0.12, height: s * 0.16), _line(w * 0.7));
      case GoalKind.house:
        final walls = Path()..addRect(Rect.fromCenter(center: c + Offset(0, s * 0.12), width: s * 0.56, height: s * 0.4));
        _outlined(canvas, walls, const Color(0xFFFFF1DC), w);
        final roof = Path()
          ..moveTo(c.dx - s * 0.38, c.dy - s * 0.06)
          ..lineTo(c.dx, c.dy - s * 0.38)
          ..lineTo(c.dx + s * 0.38, c.dy - s * 0.06)
          ..close();
        _outlined(canvas, roof, const Color(0xFFE63946), w);
        _outlined(canvas,
            Path()..addRect(Rect.fromCenter(center: c + Offset(0, s * 0.2), width: s * 0.14, height: s * 0.24)),
            const Color(0xFF7A4E2D), w * 0.8);
      case GoalKind.gift:
        final box = Path()..addRect(Rect.fromCenter(center: c + Offset(0, s * 0.1), width: s * 0.6, height: s * 0.44));
        _outlined(canvas, box, const Color(0xFFE63946), w);
        canvas.drawRect(Rect.fromCenter(center: c + Offset(0, s * 0.1), width: s * 0.12, height: s * 0.44),
            _fill(const Color(0xFFFFD23F)));
        for (final dir in [-1.0, 1.0]) {
          _outlined(canvas, _circle(c + Offset(dir * s * 0.1, -s * 0.18), s * 0.09), const Color(0xFFFFD23F), w * 0.8);
        }
      case GoalKind.crown:
        final crown = Path()
          ..moveTo(c.dx - s * 0.34, c.dy + s * 0.22)
          ..lineTo(c.dx - s * 0.36, c.dy - s * 0.18)
          ..lineTo(c.dx - s * 0.16, c.dy)
          ..lineTo(c.dx, c.dy - s * 0.28)
          ..lineTo(c.dx + s * 0.16, c.dy)
          ..lineTo(c.dx + s * 0.36, c.dy - s * 0.18)
          ..lineTo(c.dx + s * 0.34, c.dy + s * 0.22)
          ..close();
        _outlined(canvas, crown, const Color(0xFFFFC53D), w);
        for (final dx in [-0.18, 0.0, 0.18]) {
          canvas.drawCircle(c + Offset(s * dx, s * 0.12), s * 0.05, _fill(const Color(0xFFE63946)));
        }
      case GoalKind.gem:
        final gem = Path()
          ..moveTo(c.dx - s * 0.3, c.dy - s * 0.1)
          ..lineTo(c.dx - s * 0.16, c.dy - s * 0.28)
          ..lineTo(c.dx + s * 0.16, c.dy - s * 0.28)
          ..lineTo(c.dx + s * 0.3, c.dy - s * 0.1)
          ..lineTo(c.dx, c.dy + s * 0.32)
          ..close();
        _outlined(canvas, gem, const Color(0xFF5CE1E6), w);
        canvas.drawLine(c + Offset(-s * 0.3, -s * 0.1), c + Offset(s * 0.3, -s * 0.1), _line(w * 0.7));
        canvas.drawLine(c + Offset(-s * 0.08, -s * 0.1), c + Offset(0, s * 0.3), _line(w * 0.7));
        canvas.drawLine(c + Offset(s * 0.08, -s * 0.1), c + Offset(0, s * 0.3), _line(w * 0.7));
      case GoalKind.planet:
        _outlined(canvas, _circle(c, s * 0.26), const Color(0xFFFF9F68), w);
        canvas.drawCircle(c + Offset(-s * 0.08, -s * 0.06), s * 0.06, _fill(const Color(0xFFE07A4B)));
        canvas.drawCircle(c + Offset(s * 0.1, s * 0.08), s * 0.04, _fill(const Color(0xFFE07A4B)));
        canvas.drawArc(Rect.fromCenter(center: c, width: s * 0.84, height: s * 0.22), 0.1, math.pi - 0.2, false,
            _line(w * 1.8, const Color(0xFFFFE066)));
    }
    canvas.restore();
  }
}

/// Scenic world background for menus: sky, clouds or stars, rolling hills and
/// a few decorations. Deterministic per world so it never jumps around.
class ScenePainter extends CustomPainter {
  ScenePainter({required this.world, this.t = 0, this.dim = false});

  final WorldDef world;
  final double t;
  final bool dim;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [world.sky, world.skyBottom],
        ).createShader(rect),
    );
    final rng = SeededRandom(fnv1a32(world.id));
    final night = world.id == 'space';

    if (night) {
      for (var i = 0; i < 60; i++) {
        final p = Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height * 0.8);
        final tw = 0.5 + 0.5 * math.sin(t * 2 * math.pi + i);
        canvas.drawCircle(p, 1 + rng.nextDouble() * 2, _fill(Colors.white.withValues(alpha: 0.35 + 0.5 * tw)));
      }
    } else {
      for (var i = 0; i < 4; i++) {
        final baseX = rng.nextDouble() * size.width;
        final y = size.height * (0.08 + rng.nextDouble() * 0.3);
        final x = (baseX + t * size.width * 0.15 * (i.isEven ? 1 : 0.6)) % (size.width + 160) - 80;
        final r = 22 + rng.nextDouble() * 16;
        final cloud = Path()
          ..addOval(Rect.fromCircle(center: Offset(x, y), radius: r))
          ..addOval(Rect.fromCircle(center: Offset(x + r, y + r * 0.2), radius: r * 0.8))
          ..addOval(Rect.fromCircle(center: Offset(x - r, y + r * 0.25), radius: r * 0.7));
        canvas.drawPath(cloud, _fill(Colors.white.withValues(alpha: world.id == 'volcano' ? 0.35 : 0.8)));
      }
    }

    // Two layers of rolling hills.
    for (var layer = 0; layer < 2; layer++) {
      final baseY = size.height * (layer == 0 ? 0.72 : 0.82);
      final color = layer == 0 ? world.wallTop : world.wall;
      final path = Path()..moveTo(0, size.height);
      path.lineTo(0, baseY);
      const bumps = 4;
      for (var i = 0; i < bumps; i++) {
        final x0 = size.width * i / bumps;
        final x1 = size.width * (i + 1) / bumps;
        final h = size.height * (0.04 + rng.nextDouble() * 0.05);
        path.quadraticBezierTo((x0 + x1) / 2, baseY - h * 2, x1, baseY);
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(path, _fill(color));
      canvas.drawPath(path, _line(3, _ink.withValues(alpha: 0.5)));
    }

    final decoSize = math.min(size.width, size.height) * 0.14;
    for (var i = 0; i < 5; i++) {
      final d = world.decorations[i % world.decorations.length];
      final x = size.width * (0.08 + i * 0.21) + (rng.nextDouble() - 0.5) * 20;
      final y = size.height * (0.76 + (i.isEven ? 0.0 : 0.08));
      WorldArt.decoration(canvas, d, Offset(x, y), decoSize, t: t * 2 * math.pi);
    }

    if (dim) {
      canvas.drawRect(rect, _fill(Colors.black.withValues(alpha: 0.35)));
    }
  }

  @override
  bool shouldRepaint(ScenePainter old) =>
      old.t != t || old.world != world || old.dim != dim;
}
