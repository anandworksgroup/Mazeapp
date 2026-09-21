import 'package:flutter/material.dart';

import '../features/achievements/achievements_screen.dart';
import '../features/character/characters_screen.dart';
import '../features/home/home_screen.dart';
import '../features/home/play_flow_screen.dart';
import '../features/maze/view/game_launch.dart';
import '../features/maze/view/game_screen.dart';
import '../features/settings/full_unlock_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/statistics/statistics_screen.dart';
import '../features/themes/worlds_screen.dart';

class Routes {
  Routes._();

  static const home = '/';
  static const play = '/play';
  static const game = '/game';
  static const characters = '/characters';
  static const worlds = '/worlds';
  static const achievements = '/achievements';
  static const statistics = '/statistics';
  static const settings = '/settings';
  static const fullUnlock = '/full-unlock';

  static Route<dynamic> onGenerateRoute(RouteSettings s) {
    final Widget page = switch (s.name) {
      play => const PlayFlowScreen(),
      game => GameScreen(launch: s.arguments! as GameLaunch),
      characters => const CharactersScreen(),
      worlds => const WorldsScreen(),
      achievements => const AchievementsScreen(),
      statistics => const StatisticsScreen(),
      settings => const SettingsScreen(),
      fullUnlock => const FullUnlockScreen(),
      _ => const HomeScreen(),
    };
    return MaterialPageRoute(builder: (_) => page, settings: s);
  }
}
