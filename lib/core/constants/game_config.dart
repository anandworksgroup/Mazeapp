import 'dart:convert';

import 'package:flutter/services.dart';

/// Tunables loaded from the bundled `assets/config/game_config.json`, so feel
/// can be adjusted without touching game code. Missing keys fall back to the
/// defaults below.
class GameConfig {
  const GameConfig({
    this.moveDurationMs = 170,
    this.reducedMotionMoveDurationMs = 90,
    this.minCellPx = 26,
    this.minCellPxLargeUi = 38,
    this.swipeThresholdPx = 22,
    this.tiltThreshold = 2.2,
    this.autosaveIntervalMs = 2000,
    this.fullUnlockProductId = 'maze_adventure_full_unlock',
  });

  final int moveDurationMs;
  final int reducedMotionMoveDurationMs;
  final double minCellPx;
  final double minCellPxLargeUi;
  final double swipeThresholdPx;
  final double tiltThreshold;
  final int autosaveIntervalMs;
  final String fullUnlockProductId;

  static Future<GameConfig> load(AssetBundle bundle) async {
    try {
      final m = jsonDecode(
          await bundle.loadString('assets/config/game_config.json')) as Map;
      const d = GameConfig();
      return GameConfig(
        moveDurationMs: (m['move_duration_ms'] as num?)?.toInt() ?? d.moveDurationMs,
        reducedMotionMoveDurationMs:
            (m['reduced_motion_move_duration_ms'] as num?)?.toInt() ??
                d.reducedMotionMoveDurationMs,
        minCellPx: (m['min_cell_px'] as num?)?.toDouble() ?? d.minCellPx,
        minCellPxLargeUi: (m['min_cell_px_large_ui'] as num?)?.toDouble() ??
            d.minCellPxLargeUi,
        swipeThresholdPx:
            (m['swipe_threshold_px'] as num?)?.toDouble() ?? d.swipeThresholdPx,
        tiltThreshold: (m['tilt_threshold'] as num?)?.toDouble() ?? d.tiltThreshold,
        autosaveIntervalMs:
            (m['autosave_interval_ms'] as num?)?.toInt() ?? d.autosaveIntervalMs,
        fullUnlockProductId:
            m['full_unlock_product_id'] as String? ?? d.fullUnlockProductId,
      );
    } catch (_) {
      return const GameConfig();
    }
  }
}
