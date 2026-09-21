import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../audio/audio_service.dart';

Color darken(Color c, [double amount = 0.22]) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

Color lighten(Color c, [double amount = 0.15]) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

/// Big illustrated button: thick outline, a darker "edge" underneath that
/// the face presses down into, and a click sound.
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.onTap,
    this.label,
    this.icon,
    this.color,
    this.height = 64,
    this.fontSize = 22,
    this.expand = false,
    this.radius = 22,
    this.child,
    this.semanticLabel,
  });

  final VoidCallback? onTap;
  final String? label;
  final Widget? icon;
  final Color? color;
  final double height;
  final double fontSize;
  final bool expand;
  final double radius;
  final Widget? child;
  final String? semanticLabel;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _down = false;

  static const _edge = 6.0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final enabled = widget.onTap != null;
    final face = enabled ? (widget.color ?? p.orange) : p.locked;
    final edge = darken(face, 0.2);
    final press = _down ? _edge - 2 : 0.0;

    final content = widget.child ??
        Row(
          mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) widget.icon!,
            if (widget.icon != null && widget.label != null)
              const SizedBox(width: 10),
            if (widget.label != null)
              Flexible(
                child: OutlineText(
                  widget.label!,
                  size: widget.fontSize,
                  color: Colors.white,
                  outline: darken(face, 0.35),
                  strokeWidth: 4,
                ),
              ),
          ],
        );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel ?? widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTap: enabled
            ? () {
                context.audio.play(Sfx.buttonClick);
                context.audio.haptic(HapticKind.tick);
                widget.onTap!();
              }
            : null,
        child: SizedBox(
          height: widget.height + _edge,
          width: widget.expand ? double.infinity : null,
          child: Stack(
            children: [
              Positioned.fill(
                top: _edge,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: edge,
                    borderRadius: BorderRadius.circular(widget.radius),
                    border: Border.all(color: p.outline, width: p.outlineWidth),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 70),
                left: 0,
                right: 0,
                top: press,
                height: widget.height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [lighten(face, 0.08), face],
                    ),
                    borderRadius: BorderRadius.circular(widget.radius),
                    border: Border.all(color: p.outline, width: p.outlineWidth),
                  ),
                  child: Stack(
                    children: [
                      // Glossy highlight strip, like a painted toy button.
                      Positioned(
                        left: 14,
                        right: 14,
                        top: 6,
                        height: widget.height * 0.18,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Center(child: content),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round chunky icon button (back, pause, settings…).
class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.size = 54,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final double size;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      width: size,
      child: ChunkyButton(
        onTap: onTap,
        color: color ?? p.card,
        height: size,
        radius: size / 2,
        semanticLabel: tooltip,
        child: Icon(icon,
            color: color == null ? p.ink : Colors.white, size: size * 0.5),
      ),
    );
  }
}

/// A rounded, outlined card with a soft drop shadow.
class CuteCard extends StatelessWidget {
  const CuteCard({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.onTap,
    this.selected = false,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? p.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: selected ? p.play : p.outline,
          width: selected ? p.outlineWidth + 2.5 : p.outlineWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: p.outline.withValues(alpha: 0.28),
            offset: const Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.audio.play(Sfx.buttonClick);
        context.audio.haptic(HapticKind.tick);
        onTap!();
      },
      child: card,
    );
  }
}

/// Chunky text with a thick outline, for titles on busy backgrounds.
class OutlineText extends StatelessWidget {
  const OutlineText(
    this.text, {
    super.key,
    this.size = 32,
    this.color = Colors.white,
    this.outline,
    this.strokeWidth = 7,
    this.textAlign = TextAlign.center,
    this.maxLines = 2,
  });

  final String text;
  final double size;
  final Color color;
  final Color? outline;
  final double strokeWidth;
  final TextAlign textAlign;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w900,
      height: 1.1,
      letterSpacing: 0.5,
    );
    return Stack(
      children: [
        Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..strokeJoin = StrokeJoin.round
              ..color = outline ?? context.palette.outline,
          ),
        ),
        Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(color: color),
        ),
      ],
    );
  }
}

class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.count, this.size = 28, this.max = 3});

  final int count;
  final double size;
  final int max;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < max; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              Icons.star_rounded,
              size: size,
              color: i < count ? p.yellow : p.locked.withValues(alpha: 0.6),
              shadows: [Shadow(color: p.outline, blurRadius: 0, offset: const Offset(0, 2))],
            ),
          ),
      ],
    );
  }
}

class LockBadge extends StatelessWidget {
  const LockBadge({super.key, this.size = 30});

  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: p.locked,
        shape: BoxShape.circle,
        border: Border.all(color: p.outline, width: 2.5),
      ),
      child: Icon(Icons.lock_rounded, size: size * 0.55, color: Colors.white),
    );
  }
}
