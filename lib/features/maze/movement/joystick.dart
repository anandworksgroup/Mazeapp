import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// On-screen analogue stick. Reports a vector with length 0..1.
class Joystick extends StatefulWidget {
  const Joystick({super.key, required this.onChanged, this.size = 150});

  final ValueChanged<Offset> onChanged;
  final double size;

  @override
  State<Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  Offset _knob = Offset.zero;

  void _update(Offset local) {
    final r = widget.size / 2;
    var v = (local - Offset(r, r)) / r;
    if (v.distance > 1) v = v / v.distance;
    setState(() => _knob = v);
    widget.onChanged(v);
  }

  void _release() {
    setState(() => _knob = Offset.zero);
    widget.onChanged(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final r = widget.size / 2;
    final knobR = widget.size * 0.22;
    return Semantics(
      label: 'Joystick',
      child: GestureDetector(
        onPanStart: (d) => _update(d.localPosition),
        onPanUpdate: (d) => _update(d.localPosition),
        onPanEnd: (_) => _release(),
        onPanCancel: _release,
        child: SizedBox.square(
          dimension: widget.size,
          child: CustomPaint(
            painter: _StickPainter(
              knob: Offset(r, r) + _knob * (r - knobR),
              knobR: knobR,
              base: p.card.withValues(alpha: 0.85),
              outline: p.outline,
              knobColor: p.orange,
            ),
          ),
        ),
      ),
    );
  }
}

class _StickPainter extends CustomPainter {
  _StickPainter({
    required this.knob,
    required this.knobR,
    required this.base,
    required this.outline,
    required this.knobColor,
  });

  final Offset knob;
  final double knobR;
  final Color base;
  final Color outline;
  final Color knobColor;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 3;
    canvas.drawCircle(c, r, Paint()..color = base);
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = outline);
    // Direction chevrons.
    final chevron = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = outline.withValues(alpha: 0.35);
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      final tip = c + Offset(math.cos(a), math.sin(a)) * (r - 10);
      final back = c + Offset(math.cos(a), math.sin(a)) * (r - 22);
      final side = Offset(-math.sin(a), math.cos(a)) * 8;
      canvas.drawPath(
          Path()
            ..moveTo(back.dx + side.dx, back.dy + side.dy)
            ..lineTo(tip.dx, tip.dy)
            ..lineTo(back.dx - side.dx, back.dy - side.dy),
          chevron);
    }
    canvas.drawCircle(knob + const Offset(0, 4), knobR, Paint()..color = outline.withValues(alpha: 0.3));
    canvas.drawCircle(knob, knobR, Paint()..color = knobColor);
    canvas.drawCircle(
        knob,
        knobR,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = outline);
    canvas.drawCircle(knob + Offset(-knobR * 0.3, -knobR * 0.35), knobR * 0.28,
        Paint()..color = Colors.white.withValues(alpha: 0.4));
  }

  @override
  bool shouldRepaint(_StickPainter old) => old.knob != knob || old.base != base;
}
