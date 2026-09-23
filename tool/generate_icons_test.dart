// Renders the app icon from the game's own vector art into every Android and
// iOS icon size. Run with:
//
//   flutter test tool/generate_icons_test.dart
//
// The icon is drawn in two layers so Android's adaptive icon can move them
// independently: a forest-green background with a faint maze pattern, and a
// foreground holding Milo and the flower goal. Everything the eye needs sits
// inside the middle 66% of the canvas, which is the only part Android
// guarantees to show after masking.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maze_adventure/core/constants/catalog.dart';
import 'package:maze_adventure/features/character/character_painter.dart';
import 'package:maze_adventure/features/maze/generator/maze_generator.dart';
import 'package:maze_adventure/features/maze/models/maze.dart';
import 'package:maze_adventure/features/maze/models/maze_size.dart';

void paintBackground(Canvas canvas, double s) {
  final rect = Rect.fromLTWH(0, 0, s, s);
  canvas.drawRect(
    rect,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9BDC7E), Color(0xFF3E8E41)],
      ).createShader(rect),
  );

  // A real maze, drawn faintly, as wallpaper behind the hero.
  final maze = const MazeGenerator().generate(seed: 11, size: MazeSize.tiny);
  final cell = s / 4.6;
  final origin = Offset(-cell * 0.2, -cell * 0.2);
  final walls = Path();
  for (var y = 0; y < maze.rows; y++) {
    for (var x = 0; x < maze.columns; x++) {
      final p = Pos(x, y);
      if (!maze.canMove(p, Direction.up)) {
        walls
          ..moveTo(origin.dx + x * cell, origin.dy + y * cell)
          ..lineTo(origin.dx + (x + 1) * cell, origin.dy + y * cell);
      }
      if (!maze.canMove(p, Direction.left)) {
        walls
          ..moveTo(origin.dx + x * cell, origin.dy + y * cell)
          ..lineTo(origin.dx + x * cell, origin.dy + (y + 1) * cell);
      }
    }
  }
  canvas.drawPath(
    walls,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.05
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.22),
  );

  // Soft light from the top-left so the flat green has some life.
  canvas.drawCircle(
    Offset(s * 0.3, s * 0.22),
    s * 0.42,
    Paint()..color = Colors.white.withValues(alpha: 0.1),
  );
}

/// The hero layer. Android's adaptive mask only shows a circle across the
/// middle 66% of the canvas, so the flower goal — which sits out at a corner —
/// is drawn only for the flat icon, and Milo is centred on his own for the
/// adaptive foreground.
void paintForeground(Canvas canvas, double s, {bool withGoal = true}) {
  final size = s * (withGoal ? 0.74 : 0.74);
  canvas.save();
  canvas.translate((s - size) / 2, s * (withGoal ? 0.16 : 0.13));
  CharacterPainter(def: Catalog.characters.first, pose: CharacterPose.happy, t: 0.25)
      .paint(canvas, Size.square(size));
  canvas.restore();
  if (!withGoal) return;

  // The goal he is heading for. Drawn here rather than via WorldArt.goal so
  // it comes without the in-game glow, which reads as a smudge at 48px.
  final c = Offset(s * 0.775, s * 0.225);
  final r = s * 0.062;
  final outline = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.018
    ..color = const Color(0xFF3B2418);
  for (var i = 0; i < 6; i++) {
    final a = i / 6 * 2 * math.pi;
    final petal = Offset(math.cos(a), math.sin(a)) * r * 1.35 + c;
    canvas.drawCircle(petal, r, Paint()..color = const Color(0xFFFF6FA5));
    canvas.drawCircle(petal, r, outline);
  }
  canvas.drawCircle(c, r * 0.95, Paint()..color = const Color(0xFFFFD23F));
  canvas.drawCircle(c, r * 0.95, outline);
}

/// Flat icon (iOS, Android legacy, store listing).
void paintIcon(Canvas canvas, double s) {
  paintBackground(canvas, s);
  paintForeground(canvas, s);
}

/// Single-colour silhouette for Android 13+ themed icons: a maze glyph with
/// the goal at its heart. Drawn in white on transparent; Android tints it.
void paintMonochrome(Canvas canvas, double s) {
  final paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.075
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = Colors.white;
  final c = Offset(s / 2, s / 2);
  final step = s * 0.1;
  // A square spiral: the simplest shape that still says "maze".
  final path = Path()..moveTo(c.dx + step * 2.4, c.dy + step * 3.0);
  final turns = [
    Offset(-step * 3.0, step * 3.0),
    Offset(-step * 3.0, -step * 3.0),
    Offset(step * 3.0, -step * 3.0),
    Offset(step * 3.0, step * 1.6),
    Offset(-step * 1.4, step * 1.6),
    Offset(-step * 1.4, -step * 1.4),
    Offset(step * 1.2, -step * 1.4),
  ];
  for (final t in turns) {
    path.lineTo(c.dx + t.dx, c.dy + t.dy);
  }
  canvas.drawPath(path, paint);
  canvas.drawCircle(c + Offset(0, -step * 0.2), s * 0.055, Paint()..color = Colors.white);
}

Future<void> writePng(String path, int size, void Function(Canvas, double) paint) async {
  final recorder = ui.PictureRecorder();
  paint(Canvas(recorder), size.toDouble());
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  await File(path).parent.create(recursive: true);
  await File(path).writeAsBytes(bytes!.buffer.asUint8List());
}

void main() {
  test('generate icons', () async {
    // Android legacy launcher icon (pre-Android 8 and some launchers).
    const android = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192};
    for (final e in android.entries) {
      await writePng(
          'android/app/src/main/res/mipmap-${e.key}/ic_launcher.png', e.value, paintIcon);
    }

    // Adaptive icon layers. Android crops these to 72/108 of their size, so
    // each layer is rendered on a canvas 1.5× the legacy size.
    const adaptive = {'mdpi': 108, 'hdpi': 162, 'xhdpi': 216, 'xxhdpi': 324, 'xxxhdpi': 432};
    for (final e in adaptive.entries) {
      final dir = 'android/app/src/main/res/mipmap-${e.key}';
      // The visible part is the middle 72/108, so scale the artwork to fill
      // exactly that and let the rest bleed off the edges.
      await writePng('$dir/ic_launcher_background.png', e.value, paintBackground);
      await writePng('$dir/ic_launcher_foreground.png', e.value, (canvas, s) {
        const scale = 108 / 72;
        canvas.translate(s / 2, s / 2);
        canvas.scale(1 / scale);
        canvas.translate(-s / 2, -s / 2);
        paintForeground(canvas, s, withGoal: false);
      });
      await writePng('$dir/ic_launcher_monochrome.png', e.value, (canvas, s) {
        canvas.translate(s / 2, s / 2);
        canvas.scale(0.72);
        canvas.translate(-s / 2, -s / 2);
        paintMonochrome(canvas, s);
      });
    }

    const iosDir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
    final contents = jsonDecode(File('$iosDir/Contents.json').readAsStringSync()) as Map;
    for (final img in (contents['images'] as List).cast<Map>()) {
      final base = double.parse((img['size'] as String).split('x').first);
      final scale = int.parse((img['scale'] as String).replaceAll('x', ''));
      await writePng('$iosDir/${img['filename']}', (base * scale).round(), paintIcon);
    }

    // Store listing art.
    await writePng('store/app_icon_1024.png', 1024, paintIcon);
    await writePng('store/app_icon_512.png', 512, paintIcon);
  });
}
