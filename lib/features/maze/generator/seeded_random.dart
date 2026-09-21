/// A small, fully specified PRNG (mulberry32).
///
/// `dart:math`'s [Random] does not promise the same sequence across Dart
/// versions or platforms, and a saved seed must rebuild the same maze forever
/// (resume, daily maze, backups). So the generator owns its random source.
class SeededRandom {
  SeededRandom(int seed) : _state = seed & 0xFFFFFFFF;

  int _state;

  /// Next unsigned 32-bit value.
  int nextUint32() {
    _state = (_state + 0x6D2B79F5) & 0xFFFFFFFF;
    var t = _state;
    t = _imul(t ^ (t >> 15), t | 1);
    t ^= (t + _imul(t ^ (t >> 7), t | 61)) & 0xFFFFFFFF;
    return (t ^ (t >> 14)) & 0xFFFFFFFF;
  }

  /// Uniform integer in `[0, max)`.
  int nextInt(int max) {
    assert(max > 0);
    return nextUint32() % max;
  }

  /// Uniform double in `[0, 1)`.
  double nextDouble() => nextUint32() / 4294967296.0;

  bool nextBool(double probability) => nextDouble() < probability;

  static int _imul(int a, int b) => (a * b) & 0xFFFFFFFF;
}

/// Stable 32-bit FNV-1a hash, used to turn text (a date, a label) into a seed.
int fnv1a32(String text) {
  var hash = 0x811C9DC5;
  for (final unit in text.codeUnits) {
    hash ^= unit & 0xFF;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
    hash ^= unit >> 8;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}
