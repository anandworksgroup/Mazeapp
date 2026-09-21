// Renders the app icon from the game's own vector art into every Android
// and iOS icon size. Run with:
//
//   flutter test tool/generate_icons_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maze_adventure/core/constants/catalog.dart';
import 'package:maze_adventure/features/character/character_painter.dart';
import 'package:maze_adventure/features/maze/generator/maze_generator.dart';
import 'package:maze_adventure/features/maze/models/maze_size.dart';
import 'package:maze_adventure/features/maze/view/maze_painters.dart';
import 'package:maze_adventure/features/themes/world_art.dart';

void paintIcon(Canvas canvas, double s) {
  final rect = Rect.fromLTWH(0, 0, s, s);
  canvas.drawRect(
    rect,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF9BDC7E), Color(0xFF4F9A3E)],
      ).createShader(rect),
  );
  // A small maze board behind the hero.
  final world = Catalog.worlds.first;
  final geometry = MazeGeometry(const MazeGenerator().generate(seed: 11, size: MazeSize.tiny));
  final board = s * 0.78;
  canvas.save();
  canvas.translate((s - board) / 2, s * 0.1);
  final cell = board / 5.9;
  MazeBoardPainter(
    geometry: geometry,
    world: world,
    cell: cell,
    padding: cell * 0.45,
    highContrast: false,
  ).paint(canvas, Size(board, board));
  canvas.restore();
  WorldArt.goal(canvas, world.goal, Offset(s * 0.76, s * 0.24), s * 0.2);
  // Milo, big and front.
  canvas.save();
  canvas.translate(s * 0.14, s * 0.26);
  CharacterPainter(def: Catalog.characters.first, pose: CharacterPose.happy, t: 0.25)
      .paint(canvas, Size.square(s * 0.72));
  canvas.restore();
}

Future<void> writePng(String path, int size) async {
  final recorder = ui.PictureRecorder();
  paintIcon(Canvas(recorder), size.toDouble());
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  await File(path).writeAsBytes(bytes!.buffer.asUint8List());
}

void main() {
  test('generate icons', () async {
    const android = {
      'mdpi': 48,
      'hdpi': 72,
      'xhdpi': 96,
      'xxhdpi': 144,
      'xxxhdpi': 192,
    };
    for (final e in android.entries) {
      await writePng('android/app/src/main/res/mipmap-${e.key}/ic_launcher.png', e.value);
    }

    const iosDir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
    final contents = jsonDecode(File('$iosDir/Contents.json').readAsStringSync()) as Map;
    for (final img in (contents['images'] as List).cast<Map>()) {
      final base = double.parse((img['size'] as String).split('x').first);
      final scale = int.parse((img['scale'] as String).replaceAll('x', ''));
      await writePng('$iosDir/${img['filename']}', (base * scale).round());
    }

    await writePng('store/app_icon_1024.png', 1024);
  });
}
