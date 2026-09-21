import 'package:flutter/material.dart';

import '../../features/maze/models/maze_size.dart';

/// What it takes to unlock something by playing. Nothing in the game is
/// purchase-only: the optional Full Unlock just skips the wait.
class UnlockRule {
  const UnlockRule.free()
      : completions = 0,
        stars = 0,
        completedSizeId = null;
  const UnlockRule.completions(this.completions)
      : stars = 0,
        completedSizeId = null;
  const UnlockRule.stars(this.stars)
      : completions = 0,
        completedSizeId = null;
  const UnlockRule.completeSize(this.completedSizeId)
      : completions = 0,
        stars = 0;

  final int completions;
  final int stars;
  final String? completedSizeId;

  bool get isFree => completions == 0 && stars == 0 && completedSizeId == null;
}

enum EarStyle { round, pointy, floppy, long, antlers, none, tufts }

enum Feature { none, stripes, spikes, backSpikes, bigEyes, segments, tail, wings }

class CharacterDef {
  const CharacterDef({
    required this.id,
    required this.name,
    required this.body,
    required this.belly,
    required this.accent,
    required this.ears,
    this.feature = Feature.none,
    this.unlock = const UnlockRule.free(),
  });

  final String id;

  /// Proper names are the same in every language.
  final String name;
  final Color body;
  final Color belly;
  final Color accent;
  final EarStyle ears;
  final Feature feature;
  final UnlockRule unlock;
}

enum Deco { tree, flower, mushroom, car, sign, tower, torch, shell, coral, fish, snowman, pine, rock, ember, star, planet, lollipop, candyCane }

enum GoalKind { flower, house, crown, treasure, gift, gem, planet, cake }

class WorldDef {
  const WorldDef({
    required this.id,
    required this.sky,
    required this.skyBottom,
    required this.floor,
    required this.floorAlt,
    required this.wall,
    required this.wallTop,
    required this.trail,
    required this.decorations,
    required this.goal,
    this.unlock = const UnlockRule.free(),
  });

  final String id;
  final Color sky;
  final Color skyBottom;
  final Color floor;
  final Color floorAlt;
  final Color wall;
  final Color wallTop;
  final Color trail;
  final List<Deco> decorations;
  final GoalKind goal;
  final UnlockRule unlock;
}

class Catalog {
  Catalog._();

  static const characters = <CharacterDef>[
    CharacterDef(id: 'milo', name: 'Milo', body: Color(0xFFB9B4C7), belly: Color(0xFFF3E9F2), accent: Color(0xFFF7A1B5), ears: EarStyle.round, feature: Feature.tail),
    CharacterDef(id: 'luna', name: 'Luna', body: Color(0xFFF4A259), belly: Color(0xFFFFE8CC), accent: Color(0xFFFF8FA3), ears: EarStyle.pointy, feature: Feature.stripes),
    CharacterDef(id: 'buddy', name: 'Buddy', body: Color(0xFFC98F5A), belly: Color(0xFFF6E0C3), accent: Color(0xFF6B4226), ears: EarStyle.floppy),
    CharacterDef(id: 'clover', name: 'Clover', body: Color(0xFFF2F2F2), belly: Color(0xFFFFFFFF), accent: Color(0xFFFFA8C5), ears: EarStyle.long),
    CharacterDef(id: 'pip', name: 'Pip', body: Color(0xFF7BC96F), belly: Color(0xFFD8F5C8), accent: Color(0xFF3E8E41), ears: EarStyle.none, feature: Feature.bigEyes),
    CharacterDef(id: 'buzz', name: 'Buzz', body: Color(0xFFFFD23F), belly: Color(0xFFFFF1A8), accent: Color(0xFF3D3B30), ears: EarStyle.none, feature: Feature.wings, unlock: UnlockRule.completions(3)),
    CharacterDef(id: 'momo', name: 'Momo', body: Color(0xFF9C6B4E), belly: Color(0xFFF1D1B5), accent: Color(0xFF6E4631), ears: EarStyle.round, feature: Feature.tail, unlock: UnlockRule.completions(6)),
    CharacterDef(id: 'rex', name: 'Rex', body: Color(0xFF5FB49C), belly: Color(0xFFD4F2E1), accent: Color(0xFFF28F3B), ears: EarStyle.none, feature: Feature.backSpikes, unlock: UnlockRule.completions(10)),
    CharacterDef(id: 'ollie', name: 'Ollie', body: Color(0xFF8D6E97), belly: Color(0xFFEBDDF0), accent: Color(0xFFFFB347), ears: EarStyle.tufts, feature: Feature.bigEyes, unlock: UnlockRule.stars(40)),
    CharacterDef(id: 'spike', name: 'Spike', body: Color(0xFF8A6A55), belly: Color(0xFFF3DEC8), accent: Color(0xFF5A4031), ears: EarStyle.round, feature: Feature.spikes, unlock: UnlockRule.completions(20)),
    CharacterDef(id: 'rudy', name: 'Rudy', body: Color(0xFFB07A52), belly: Color(0xFFF4DCC0), accent: Color(0xFFE63946), ears: EarStyle.antlers, unlock: UnlockRule.stars(90)),
    CharacterDef(id: 'wiggles', name: 'Wiggles', body: Color(0xFFFF9EAA), belly: Color(0xFFFFD6DC), accent: Color(0xFFE56B7E), ears: EarStyle.none, feature: Feature.segments, unlock: UnlockRule.completions(40)),
  ];

  static const worlds = <WorldDef>[
    WorldDef(
      id: 'forest',
      sky: Color(0xFFBFE8A8), skyBottom: Color(0xFF8CCB6E),
      floor: Color(0xFFE9D8A6), floorAlt: Color(0xFFE2CE97),
      wall: Color(0xFF4F9A3E), wallTop: Color(0xFF79C25B), trail: Color(0xFFC49A5A),
      decorations: [Deco.tree, Deco.flower, Deco.mushroom],
      goal: GoalKind.flower,
    ),
    WorldDef(
      id: 'candy',
      sky: Color(0xFFFFD6E8), skyBottom: Color(0xFFFFB3D1),
      floor: Color(0xFFFFF4E6), floorAlt: Color(0xFFFFEBD6),
      wall: Color(0xFF9B5DE5), wallTop: Color(0xFFC39BF2), trail: Color(0xFFFF7EB6),
      decorations: [Deco.lollipop, Deco.candyCane, Deco.flower],
      goal: GoalKind.cake,
    ),
    WorldDef(
      id: 'ocean',
      sky: Color(0xFF9EE3F5), skyBottom: Color(0xFF4FB6DB),
      floor: Color(0xFFF7E7B4), floorAlt: Color(0xFFF1DDA0),
      wall: Color(0xFF1F7FB3), wallTop: Color(0xFF4AB0DE), trail: Color(0xFFFF9F68),
      decorations: [Deco.shell, Deco.coral, Deco.fish],
      goal: GoalKind.treasure,
    ),
    WorldDef(
      id: 'road',
      sky: Color(0xFFCDE7F0), skyBottom: Color(0xFF9FD0E0),
      floor: Color(0xFF6C7A89), floorAlt: Color(0xFF647282),
      wall: Color(0xFF8FC96B), wallTop: Color(0xFFB5E08F), trail: Color(0xFFFFE066),
      decorations: [Deco.car, Deco.sign, Deco.tree],
      goal: GoalKind.house,
      unlock: UnlockRule.completions(4),
    ),
    WorldDef(
      id: 'snow',
      sky: Color(0xFFE3F2FD), skyBottom: Color(0xFFBBDEFB),
      floor: Color(0xFFFFFFFF), floorAlt: Color(0xFFF1F7FC),
      wall: Color(0xFF6FA8DC), wallTop: Color(0xFFA9CFF0), trail: Color(0xFF90CAF9),
      decorations: [Deco.snowman, Deco.pine, Deco.star],
      goal: GoalKind.gift,
      unlock: UnlockRule.completions(8),
    ),
    WorldDef(
      id: 'castle',
      sky: Color(0xFFD7CCE8), skyBottom: Color(0xFFA99BC9),
      floor: Color(0xFFD9D4CC), floorAlt: Color(0xFFCFC9BF),
      wall: Color(0xFF7D7A8C), wallTop: Color(0xFFA7A4B5), trail: Color(0xFFE0B04F),
      decorations: [Deco.tower, Deco.torch, Deco.flower],
      goal: GoalKind.crown,
      unlock: UnlockRule.completions(12),
    ),
    WorldDef(
      id: 'volcano',
      sky: Color(0xFFFFC6A5), skyBottom: Color(0xFFE88D67),
      floor: Color(0xFF5B4B49), floorAlt: Color(0xFF54443F),
      wall: Color(0xFFE4572E), wallTop: Color(0xFFFF8A5B), trail: Color(0xFFFFD166),
      decorations: [Deco.rock, Deco.ember, Deco.rock],
      goal: GoalKind.gem,
      unlock: UnlockRule.stars(60),
    ),
    WorldDef(
      id: 'space',
      sky: Color(0xFF2B2D6E), skyBottom: Color(0xFF14163F),
      floor: Color(0xFF3C3F8F), floorAlt: Color(0xFF373A86),
      wall: Color(0xFFB388FF), wallTop: Color(0xFFD1B8FF), trail: Color(0xFF7CF0FF),
      decorations: [Deco.star, Deco.planet, Deco.star],
      goal: GoalKind.planet,
      unlock: UnlockRule.completions(25),
    ),
  ];

  /// Sizes Tiny..Huge are free; Extreme is earned by beating a Huge maze.
  static const sizeUnlocks = <String, UnlockRule>{
    'tiny': UnlockRule.free(),
    'small': UnlockRule.free(),
    'medium': UnlockRule.free(),
    'large': UnlockRule.free(),
    'huge': UnlockRule.free(),
    'extreme': UnlockRule.completeSize('huge'),
  };

  static List<MazeSize> get sizes => MazeSize.all;

  static CharacterDef character(String id) =>
      characters.firstWhere((c) => c.id == id, orElse: () => characters.first);

  static WorldDef world(String id) =>
      worlds.firstWhere((w) => w.id == id, orElse: () => worlds.first);
}

/// Local achievements. Each one's condition lives in `AchievementEngine`.
enum Achievement {
  firstMaze('🏁'),
  explorer('🧭'),
  mazeMaster('👑'),
  speedRunner('⚡'),
  giant('🦣'),
  collector('🎒'),
  worldTraveler('🌍'),
  perfect('💎'),
  dailyHero('📅'),
  starCollector('🌟'),
  streak3('🔥');

  const Achievement(this.emoji);
  final String emoji;
}
