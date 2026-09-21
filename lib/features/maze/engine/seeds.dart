import 'dart:math';

import '../generator/seeded_random.dart';

/// Seeds for mazes. Only the seed (plus size) is ever stored; the generator
/// rebuilds the exact maze from it.
class Seeds {
  Seeds._();

  static const _dailySalt = 'maze-adventure/daily/v1';
  static final Random _secure = _makeRandom();

  static Random _makeRandom() {
    try {
      return Random.secure();
    } catch (_) {
      return Random();
    }
  }

  /// A fresh random seed for "New Maze".
  static int random() => _secure.nextInt(0x7FFFFFFF) + 1;

  /// Same maze for every player on the same calendar day, with no server:
  /// the seed is a hash of the local date and a fixed salt.
  static int daily(DateTime day) => fnv1a32('${dayKey(day)}|$_dailySalt') & 0x7FFFFFFF;

  static String dayKey(DateTime day) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${day.year}-${two(day.month)}-${two(day.day)}';
  }
}
