import 'package:flutter/material.dart';

import '../../core/constants/catalog.dart';
import '../../core/localization/l10n.dart';
import '../character/animated_character.dart';
import '../character/character_painter.dart';
import '../themes/world_art.dart';

/// Shown only while the local database opens (a fraction of a second).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final world = Catalog.worlds.first;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: ScenePainter(world: world))),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedCharacter(
                  def: Catalog.characters.first,
                  pose: error == null ? CharacterPose.happy : CharacterPose.sad,
                  size: 140,
                ),
                const SizedBox(height: 12),
                if (error == null)
                  Text(context.l10n.loading,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF4A2E1F)))
                else
                  IconButton.filled(
                    iconSize: 40,
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
