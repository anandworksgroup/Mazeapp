import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/catalog.dart';
import '../maze/models/maze.dart';

enum CharacterPose { idle, walk, celebrate, happy, sad, sleep, wave }

/// Draws one of the original Maze Adventure animals as vector art.
///
/// Every character shares one rig — a round body with feet, arms and a face —
/// and gets its personality from colours, ears and a signature feature. [t]
/// is a looping 0..1 phase that drives bounce, walk cycle and waving.
class CharacterPainter extends CustomPainter {
  CharacterPainter({
    required this.def,
    this.pose = CharacterPose.idle,
    this.facing = Direction.down,
    this.t = 0,
    this.blink = false,
    this.outline = const Color(0xFF3B2418),
  });

  final CharacterDef def;
  final CharacterPose pose;
  final Direction facing;
  final double t;
  final bool blink;
  final Color outline;

  late double _u;
  late Paint _stroke;

  Offset _p(double x, double y) => Offset(x * _u, y * _u);
  double _s(double v) => v * _u;

  @override
  void paint(Canvas canvas, Size size) {
    _u = size.shortestSide / 100;
    _stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _s(2.6)
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = outline;

    final wave = math.sin(t * 2 * math.pi);
    double bounce;
    double squash;
    switch (pose) {
      case CharacterPose.walk:
        bounce = -_s(3) * wave.abs();
        squash = 0.04 * wave;
      case CharacterPose.celebrate:
        bounce = -_s(10) * wave.abs();
        squash = 0.08 * math.cos(t * 4 * math.pi);
      case CharacterPose.happy:
        bounce = -_s(5) * wave.abs();
        squash = 0.05 * wave;
      case CharacterPose.sleep:
        bounce = 0;
        squash = 0.03 * wave;
      case CharacterPose.sad:
        bounce = _s(1.5);
        squash = -0.03;
      case CharacterPose.idle:
      case CharacterPose.wave:
        bounce = -_s(1.8) * (0.5 + 0.5 * wave);
        squash = 0.025 * wave;
    }

    // Ground shadow shrinks as the character hops.
    final lift = (-bounce / _s(10)).clamp(0.0, 1.0);
    canvas.drawOval(
      Rect.fromCenter(
          center: _p(50, 92), width: _s(52 - 14 * lift), height: _s(9 - 3 * lift)),
      Paint()..color = Colors.black.withValues(alpha: 0.16),
    );

    canvas.save();
    canvas.translate(0, bounce);
    // Squash & stretch around the feet.
    canvas.translate(_s(50), _s(88));
    canvas.scale(1 + squash, 1 - squash);
    canvas.translate(-_s(50), -_s(88));

    final back = facing == Direction.up;
    final side = facing == Direction.left
        ? -1.0
        : facing == Direction.right
            ? 1.0
            : 0.0;

    _behind(canvas, side, back);
    _feet(canvas, wave);
    _body(canvas, back);
    _arms(canvas, wave);
    if (!back) {
      _front(canvas, side);
      _face(canvas, side);
    } else {
      _backDetails(canvas);
    }
    if (pose == CharacterPose.celebrate) _sparkles(canvas);
    if (pose == CharacterPose.sleep) _zzz(canvas);
    canvas.restore();
  }

  Paint _fill(Color c) => Paint()..color = c;

  Color get _dark => Color.lerp(def.body, Colors.black, 0.25)!;

  void _outlined(Canvas canvas, Path path, Color color) {
    canvas.drawPath(path, _fill(color));
    canvas.drawPath(path, _stroke);
  }

  Path _oval(double cx, double cy, double w, double h) =>
      Path()..addOval(Rect.fromCenter(center: _p(cx, cy), width: _s(w), height: _s(h)));

  // ---- parts ---------------------------------------------------------------

  void _behind(Canvas canvas, double side, bool back) {
    switch (def.feature) {
      case Feature.spikes:
        final path = Path();
        for (var i = 0; i <= 10; i++) {
          final a = math.pi + i / 10 * math.pi;
          final inner = _p(50 + 30 * math.cos(a), 58 + 30 * math.sin(a));
          final tip = _p(50 + 42 * math.cos(a + 0.1), 58 + 42 * math.sin(a + 0.1));
          final next = _p(50 + 30 * math.cos(a + 0.3), 58 + 30 * math.sin(a + 0.3));
          path
            ..moveTo(inner.dx, inner.dy)
            ..lineTo(tip.dx, tip.dy)
            ..lineTo(next.dx, next.dy)
            ..close();
        }
        _outlined(canvas, path, def.accent);
      case Feature.backSpikes:
        for (final (x, y, h) in [(34.0, 34.0, 12.0), (50.0, 27.0, 15.0), (66.0, 34.0, 12.0)]) {
          final path = Path()
            ..moveTo(_s(x - 7), _s(y + 4))
            ..lineTo(_s(x), _s(y - h))
            ..lineTo(_s(x + 7), _s(y + 4))
            ..close();
          _outlined(canvas, path, def.accent);
        }
      case Feature.wings:
        final flap = pose == CharacterPose.idle ? 0.0 : math.sin(t * 8 * math.pi) * 4;
        for (final dir in [-1.0, 1.0]) {
          final path = _oval(50 + dir * 30, 38 - flap, 26, 20);
          canvas.drawPath(path, _fill(Colors.white.withValues(alpha: 0.8)));
          canvas.drawPath(path, _stroke);
        }
      case Feature.tail:
        final dir = side == 0 ? 1.0 : -side;
        final isMonkey = def.id == 'momo';
        final tail = Path()
          ..moveTo(_s(50 + dir * 22), _s(76))
          ..cubicTo(_s(50 + dir * 44), _s(80), _s(50 + dir * 46), _s(52),
              _s(50 + dir * 36), _s(isMonkey ? 50 : 58));
        if (isMonkey) {
          tail.cubicTo(_s(50 + dir * 30), _s(46), _s(50 + dir * 30), _s(56),
              _s(50 + dir * 35), _s(56));
        }
        canvas.drawPath(
            tail,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = _s(isMonkey ? 8 : 6.5)
              ..strokeCap = StrokeCap.round
              ..color = outline);
        canvas.drawPath(
            tail,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = _s(isMonkey ? 3.5 : 2.2)
              ..strokeCap = StrokeCap.round
              ..color = isMonkey ? def.body : def.accent);
      case Feature.segments:
        final dir = side == 0 ? 1.0 : -side;
        final wiggle = math.sin(t * 2 * math.pi) * 2;
        _outlined(canvas, _oval(50 + dir * 38, 80 + wiggle, 20, 18), _dark);
        _outlined(canvas, _oval(50 + dir * 26, 78 - wiggle, 26, 24), def.body);
      default:
        break;
    }

    switch (def.ears) {
      case EarStyle.round:
        for (final dir in [-1.0, 1.0]) {
          _outlined(canvas, _oval(50 + dir * 24, 30, 26, 26), def.body);
          canvas.drawPath(_oval(50 + dir * 24, 31, 14, 14), _fill(def.accent));
        }
      case EarStyle.pointy:
        for (final dir in [-1.0, 1.0]) {
          final path = Path()
            ..moveTo(_s(50 + dir * 8), _s(32))
            ..lineTo(_s(50 + dir * 26), _s(12))
            ..lineTo(_s(50 + dir * 30), _s(42))
            ..close();
          _outlined(canvas, path, def.body);
          final inner = Path()
            ..moveTo(_s(50 + dir * 14), _s(32))
            ..lineTo(_s(50 + dir * 25), _s(19))
            ..lineTo(_s(50 + dir * 27), _s(38))
            ..close();
          canvas.drawPath(inner, _fill(def.accent));
        }
      case EarStyle.long:
        final droop = pose == CharacterPose.sad ? 14.0 : 0.0;
        for (final dir in [-1.0, 1.0]) {
          canvas.save();
          canvas.translate(_s(50 + dir * 12), _s(34));
          canvas.rotate(dir * (0.15 + droop / 40));
          final ear = Path()
            ..addRRect(RRect.fromRectAndRadius(
                Rect.fromCenter(center: Offset(0, -_s(18)), width: _s(15), height: _s(40)),
                Radius.circular(_s(8))));
          _outlined(canvas, ear, def.body);
          canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromCenter(center: Offset(0, -_s(17)), width: _s(7), height: _s(30)),
                  Radius.circular(_s(4))),
              _fill(def.accent));
          canvas.restore();
        }
      case EarStyle.antlers:
        final antler = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = const Color(0xFF7A4E2D)
          ..strokeWidth = _s(5);
        final outlinePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = outline
          ..strokeWidth = _s(9);
        for (final dir in [-1.0, 1.0]) {
          final path = Path()
            ..moveTo(_s(50 + dir * 14), _s(34))
            ..lineTo(_s(50 + dir * 22), _s(10))
            ..moveTo(_s(50 + dir * 18), _s(22))
            ..lineTo(_s(50 + dir * 32), _s(16))
            ..moveTo(_s(50 + dir * 21), _s(14))
            ..lineTo(_s(50 + dir * 14), _s(6));
          canvas.drawPath(path, outlinePaint);
          canvas.drawPath(path, antler);
          _outlined(canvas, _oval(50 + dir * 29, 38, 16, 11), def.body);
        }
      case EarStyle.tufts:
        for (final dir in [-1.0, 1.0]) {
          final path = Path()
            ..moveTo(_s(50 + dir * 10), _s(33))
            ..lineTo(_s(50 + dir * 28), _s(18))
            ..lineTo(_s(50 + dir * 27), _s(38))
            ..close();
          _outlined(canvas, path, _dark);
        }
      case EarStyle.floppy:
      case EarStyle.none:
        break;
    }

    if (def.feature == Feature.bigEyes && def.ears == EarStyle.none && !back) {
      // Frog: eyes sit on bumps above the head.
      for (final dir in [-1.0, 1.0]) {
        _outlined(canvas, _oval(50 + dir * 15, 32, 24, 22), def.body);
      }
    }
  }

  void _feet(Canvas canvas, double wave) {
    final walking = pose == CharacterPose.walk;
    for (final dir in [-1.0, 1.0]) {
      final lift = walking ? (dir * wave).clamp(0.0, 1.0) * 5 : 0.0;
      _outlined(canvas, _oval(50 + dir * 13, 87 - lift, 20, 11),
          def.id == 'buzz' ? def.accent : _dark);
    }
  }

  void _body(Canvas canvas, bool back) {
    final body = _oval(50, 60, 64, 60);
    _outlined(canvas, body, def.body);
    canvas.save();
    canvas.clipPath(body);
    if (def.feature == Feature.wings) {
      // Bee stripes.
      for (final y in [62.0, 76.0]) {
        canvas.drawRect(
            Rect.fromLTWH(0, _s(y), _s(100), _s(7)), _fill(def.accent));
      }
    }
    if (!back) {
      canvas.drawOval(Rect.fromCenter(center: _p(50, 74), width: _s(40), height: _s(26)),
          _fill(def.belly));
    }
    // Soft top highlight.
    canvas.drawOval(Rect.fromCenter(center: _p(40, 40), width: _s(22), height: _s(12)),
        _fill(Colors.white.withValues(alpha: 0.28)));
    canvas.restore();
    canvas.drawPath(body, _stroke);
  }

  void _arms(Canvas canvas, double wave) {
    for (final dir in [-1.0, 1.0]) {
      final raised = pose == CharacterPose.celebrate ||
          (pose == CharacterPose.wave && dir > 0);
      canvas.save();
      if (raised) {
        final swing = pose == CharacterPose.wave ? wave * 0.35 : wave * 0.2;
        // Shoulder sits on the body's side; the arm swings up and out.
        canvas.translate(_s(50 + dir * 30), _s(58));
        canvas.rotate(dir * (0.75 + swing));
        _outlined(canvas,
            Path()..addOval(Rect.fromCenter(center: Offset(0, -_s(9)), width: _s(12), height: _s(20))),
            def.body);
      } else {
        final droop = pose == CharacterPose.sad ? 4.0 : 0.0;
        _outlined(canvas, _oval(50 + dir * 30, 66 + droop, 12, 17), def.body);
      }
      canvas.restore();
    }
  }

  void _front(Canvas canvas, double side) {
    final fx = side * 6;
    if (def.ears == EarStyle.floppy) {
      final flop = pose == CharacterPose.walk ? math.sin(t * 2 * math.pi) * 3 : 0.0;
      for (final dir in [-1.0, 1.0]) {
        canvas.save();
        canvas.translate(_s(50 + dir * 27), _s(40));
        canvas.rotate(dir * (0.35 + flop / 30));
        _outlined(
            canvas,
            Path()..addOval(Rect.fromCenter(center: Offset(0, _s(10)), width: _s(16), height: _s(30))),
            def.accent);
        canvas.restore();
      }
    }
    if (def.feature == Feature.stripes) {
      final paint = Paint()
        ..color = _dark
        ..strokeWidth = _s(3.2)
        ..strokeCap = StrokeCap.round;
      for (final dx in [-6.0, 0.0, 6.0]) {
        canvas.drawLine(_p(50 + dx + fx, 32), _p(50 + dx * 0.8 + fx, 39), paint);
      }
    }
    if (def.id == 'momo') {
      // Monkey face mask.
      final mask = Path()
        ..addOval(Rect.fromCenter(center: _p(43 + fx, 50), width: _s(22), height: _s(22)))
        ..addOval(Rect.fromCenter(center: _p(57 + fx, 50), width: _s(22), height: _s(22)))
        ..addOval(Rect.fromCenter(center: _p(50 + fx, 61), width: _s(34), height: _s(22)));
      canvas.drawPath(mask, _fill(def.belly));
    }
    if (def.id == 'buddy') {
      canvas.drawOval(Rect.fromCenter(center: _p(50 + fx, 60), width: _s(26), height: _s(18)),
          _fill(def.belly));
    }
    if (def.id == 'buzz') {
      final ant = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _s(2.6)
        ..strokeCap = StrokeCap.round
        ..color = outline;
      for (final dir in [-1.0, 1.0]) {
        final path = Path()
          ..moveTo(_s(50 + dir * 8), _s(32))
          ..quadraticBezierTo(_s(50 + dir * 12), _s(18), _s(50 + dir * 18), _s(16));
        canvas.drawPath(path, ant);
        canvas.drawCircle(_p(50 + dir * 18, 16), _s(3.5), _fill(outline));
      }
    }
  }

  void _face(Canvas canvas, double side) {
    final fx = side * 6;
    final isFrog = def.feature == Feature.bigEyes && def.ears == EarStyle.none;
    final isOwl = def.feature == Feature.bigEyes && def.ears == EarStyle.tufts;
    final eyeY = isFrog ? 31.0 : 50.0;
    final eyeDx = isFrog ? 15.0 : (isOwl ? 12.0 : 11.0);
    final eyeR = isFrog ? 6.0 : (isOwl ? 5.0 : 4.3);

    final happyEyes = pose == CharacterPose.celebrate || pose == CharacterPose.happy;
    final closed = blink || pose == CharacterPose.sleep;

    for (final dir in [-1.0, 1.0]) {
      final c = _p(50 + dir * eyeDx + fx, eyeY);
      if (isFrog || isOwl) {
        canvas.drawCircle(c, _s(eyeR + 5), _fill(Colors.white));
        canvas.drawCircle(c, _s(eyeR + 5), _stroke);
        if (isOwl) {
          canvas.drawCircle(c, _s(eyeR + 5), Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = _s(2)
            ..color = def.accent);
        }
      }
      final lineEye = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _s(3)
        ..strokeCap = StrokeCap.round
        ..color = outline;
      if (closed) {
        final path = Path()
          ..moveTo(c.dx - _s(eyeR), c.dy)
          ..quadraticBezierTo(c.dx, c.dy + _s(eyeR), c.dx + _s(eyeR), c.dy);
        canvas.drawPath(path, lineEye);
      } else if (happyEyes) {
        final path = Path()
          ..moveTo(c.dx - _s(eyeR), c.dy + _s(1.5))
          ..quadraticBezierTo(c.dx, c.dy - _s(eyeR * 1.3), c.dx + _s(eyeR), c.dy + _s(1.5));
        canvas.drawPath(path, lineEye);
      } else {
        final look = Offset(side * _s(1.5), 0);
        canvas.drawOval(
            Rect.fromCenter(center: c + look, width: _s(eyeR * 2), height: _s(eyeR * 2.3)),
            _fill(outline));
        canvas.drawCircle(c + look + Offset(-_s(1.3), -_s(1.6)), _s(eyeR * 0.38),
            _fill(Colors.white));
        if (pose == CharacterPose.sad) {
          canvas.drawLine(
              c + Offset(-_s(eyeR + 1) * dir, -_s(eyeR + 5)),
              c + Offset(_s(eyeR) * dir, -_s(eyeR + 2)),
              lineEye);
        }
      }
    }

    // Cheeks.
    for (final dir in [-1.0, 1.0]) {
      canvas.drawOval(
          Rect.fromCenter(center: _p(50 + dir * 20 + fx, 60), width: _s(10), height: _s(6)),
          _fill(const Color(0xFFFF7F9E).withValues(alpha: 0.45)));
    }

    final mouthY = isFrog ? 58.0 : 62.0;
    if (isOwl) {
      final beak = Path()
        ..moveTo(_s(46 + fx), _s(56))
        ..lineTo(_s(54 + fx), _s(56))
        ..lineTo(_s(50 + fx), _s(63))
        ..close();
      _outlined(canvas, beak, def.accent);
      return;
    }

    final hasNose = !isFrog && def.id != 'buzz' && def.id != 'wiggles' && def.id != 'rex';
    if (hasNose) {
      final big = def.id == 'rudy';
      canvas.drawOval(
          Rect.fromCenter(center: _p(50 + fx, 56.5), width: _s(big ? 10 : 6), height: _s(big ? 8 : 4.5)),
          _fill(big ? def.accent : outline));
      if (big) {
        canvas.drawCircle(_p(48.5 + fx, 55.5), _s(1.4), _fill(Colors.white.withValues(alpha: 0.8)));
      }
    }
    if (def.id == 'rex') {
      for (final dir in [-1.0, 1.0]) {
        canvas.drawCircle(_p(50 + dir * 4 + fx, 57), _s(1.3), _fill(outline));
      }
    }

    final mouth = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _s(2.6)
      ..strokeCap = StrokeCap.round
      ..color = outline;
    if (happyEyes) {
      final path = Path()
        ..moveTo(_s(43 + fx), _s(mouthY))
        ..quadraticBezierTo(_s(50 + fx), _s(mouthY + 12), _s(57 + fx), _s(mouthY))
        ..close();
      canvas.drawPath(path, _fill(const Color(0xFF8C2F39)));
      canvas.save();
      canvas.clipPath(path);
      canvas.drawCircle(_p(50 + fx, mouthY + 9), _s(5), _fill(const Color(0xFFFF7F9E)));
      canvas.restore();
      canvas.drawPath(path, mouth);
    } else if (pose == CharacterPose.sad) {
      final path = Path()
        ..moveTo(_s(45 + fx), _s(mouthY + 4))
        ..quadraticBezierTo(_s(50 + fx), _s(mouthY - 1), _s(55 + fx), _s(mouthY + 4));
      canvas.drawPath(path, mouth);
    } else if (pose == CharacterPose.sleep) {
      canvas.drawCircle(_p(50 + fx, mouthY + 2), _s(2), mouth);
    } else if (hasNose && def.ears != EarStyle.floppy && def.id != 'momo' && def.id != 'rudy') {
      // Little "w" mouth for whiskery faces.
      final path = Path()
        ..moveTo(_s(45 + fx), _s(mouthY - 1))
        ..quadraticBezierTo(_s(47.5 + fx), _s(mouthY + 3), _s(50 + fx), _s(mouthY - 1))
        ..quadraticBezierTo(_s(52.5 + fx), _s(mouthY + 3), _s(55 + fx), _s(mouthY - 1));
      canvas.drawPath(path, mouth);
    } else {
      final w = isFrog ? 10.0 : 6.0;
      final path = Path()
        ..moveTo(_s(50 - w + fx), _s(mouthY))
        ..quadraticBezierTo(_s(50 + fx), _s(mouthY + 6), _s(50 + w + fx), _s(mouthY));
      canvas.drawPath(path, mouth);
    }
  }

  void _backDetails(Canvas canvas) {
    // Seen from behind: a little tuft so it doesn't look like a plain ball.
    final tuft = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _s(2.6)
      ..strokeCap = StrokeCap.round
      ..color = _dark;
    canvas.drawArc(Rect.fromCenter(center: _p(50, 70), width: _s(14), height: _s(10)),
        0.2, math.pi - 0.4, false, tuft);
  }

  void _sparkles(Canvas canvas) {
    final paint = _fill(const Color(0xFFFFD23F));
    for (var i = 0; i < 4; i++) {
      final a = t * 2 * math.pi + i * math.pi / 2;
      final c = _p(50 + 44 * math.cos(a), 45 + 36 * math.sin(a));
      final r = _s(4 + 1.5 * math.sin(t * 6 * math.pi + i));
      final star = Path()
        ..moveTo(c.dx, c.dy - r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r);
      canvas.drawPath(star, paint);
    }
  }

  void _zzz(Canvas canvas) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'z',
        style: TextStyle(
            fontSize: _s(14 + 4 * t), fontWeight: FontWeight.w900, color: outline),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, _p(72 + 6 * t, 20 - 10 * t));
  }

  @override
  bool shouldRepaint(CharacterPainter old) =>
      old.t != t ||
      old.pose != pose ||
      old.facing != facing ||
      old.blink != blink ||
      old.def != def;
}
