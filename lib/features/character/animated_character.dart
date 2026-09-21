import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/catalog.dart';
import '../maze/models/maze.dart';
import 'character_painter.dart';

/// A character that is alive on screen: it breathes, blinks and walks.
/// With [animate] off (reduced motion) it holds still and only changes pose.
class AnimatedCharacter extends StatefulWidget {
  const AnimatedCharacter({
    super.key,
    required this.def,
    this.pose = CharacterPose.idle,
    this.facing = Direction.down,
    this.size = 120,
    this.animate = true,
    this.greyed = false,
  });

  final CharacterDef def;
  final CharacterPose pose;
  final Direction facing;
  final double size;
  final bool animate;
  final bool greyed;

  @override
  State<AnimatedCharacter> createState() => _AnimatedCharacterState();
}

class _AnimatedCharacterState extends State<AnimatedCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop;
  Timer? _blinkTimer;
  bool _blink = false;
  final _rng = math.Random();

  Duration get _period => switch (widget.pose) {
        CharacterPose.walk => const Duration(milliseconds: 340),
        CharacterPose.celebrate => const Duration(milliseconds: 700),
        CharacterPose.happy => const Duration(milliseconds: 600),
        CharacterPose.sleep => const Duration(milliseconds: 2400),
        _ => const Duration(milliseconds: 1600),
      };

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(vsync: this, duration: _period);
    _sync();
    _scheduleBlink();
  }

  @override
  void didUpdateWidget(AnimatedCharacter old) {
    super.didUpdateWidget(old);
    if (old.pose != widget.pose || old.animate != widget.animate) {
      _loop.duration = _period;
      _sync();
    }
  }

  void _sync() {
    if (widget.animate && !widget.greyed) {
      _loop.repeat();
    } else {
      _loop.stop();
      _loop.value = 0;
    }
  }

  void _scheduleBlink() {
    _blinkTimer = Timer(Duration(milliseconds: 1800 + _rng.nextInt(2600)), () {
      if (!mounted) return;
      if (widget.animate && !widget.greyed) {
        setState(() => _blink = true);
        Timer(const Duration(milliseconds: 130), () {
          if (mounted) setState(() => _blink = false);
        });
      }
      _scheduleBlink();
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget art = AnimatedBuilder(
      animation: _loop,
      builder: (context, _) => CustomPaint(
        size: Size.square(widget.size),
        painter: CharacterPainter(
          def: widget.def,
          pose: widget.pose,
          facing: widget.facing,
          t: _loop.value,
          blink: _blink,
        ),
      ),
    );
    if (widget.greyed) {
      art = Opacity(
        opacity: 0.55,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.33, 0.33, 0.33, 0, 0, //
            0.33, 0.33, 0.33, 0, 0, //
            0.33, 0.33, 0.33, 0, 0, //
            0, 0, 0, 1, 0,
          ]),
          child: art,
        ),
      );
    }
    return Semantics(
      label: widget.def.name,
      image: true,
      child: RepaintBoundary(child: SizedBox.square(dimension: widget.size, child: art)),
    );
  }
}
