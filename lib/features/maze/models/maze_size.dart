/// Generator knobs for one size. See `MazeGenerator` for what they do.
class GeneratorTuning {
  const GeneratorTuning({required this.branchChance, required this.braidChance});

  final double branchChance;
  final double braidChance;
}

/// A maze size is also the difficulty level: bigger grids get more branching
/// and fewer forgiving loops, so "Huge" is harder than a scaled-up "Tiny".
class MazeSize {
  const MazeSize({
    required this.id,
    required this.level,
    required this.columns,
    required this.rows,
    required this.tuning,
    required this.parSecondsPerStep,
  });

  final String id;

  /// 1 (Tiny) .. 6 (Extreme).
  final int level;
  final int columns;
  final int rows;
  final GeneratorTuning tuning;

  /// How long a relaxed player takes per optimal step; sets the 3-star time.
  final double parSecondsPerStep;

  String get dimensions => '$columns × $rows';

  static const tiny = MazeSize(
    id: 'tiny',
    level: 1,
    columns: 5,
    rows: 5,
    tuning: GeneratorTuning(branchChance: 0.0, braidChance: 0.25),
    parSecondsPerStep: 0.9,
  );
  static const small = MazeSize(
    id: 'small',
    level: 2,
    columns: 8,
    rows: 8,
    tuning: GeneratorTuning(branchChance: 0.1, braidChance: 0.15),
    parSecondsPerStep: 0.75,
  );
  static const medium = MazeSize(
    id: 'medium',
    level: 3,
    columns: 12,
    rows: 12,
    tuning: GeneratorTuning(branchChance: 0.25, braidChance: 0.08),
    parSecondsPerStep: 0.65,
  );
  static const large = MazeSize(
    id: 'large',
    level: 4,
    columns: 16,
    rows: 16,
    tuning: GeneratorTuning(branchChance: 0.3, braidChance: 0.05),
    parSecondsPerStep: 0.6,
  );
  static const huge = MazeSize(
    id: 'huge',
    level: 5,
    columns: 24,
    rows: 24,
    tuning: GeneratorTuning(branchChance: 0.45, braidChance: 0.02),
    parSecondsPerStep: 0.55,
  );
  static const extreme = MazeSize(
    id: 'extreme',
    level: 6,
    columns: 32,
    rows: 32,
    tuning: GeneratorTuning(branchChance: 0.5, braidChance: 0.0),
    parSecondsPerStep: 0.5,
  );

  static const all = [tiny, small, medium, large, huge, extreme];

  static MazeSize byId(String id) =>
      all.firstWhere((s) => s.id == id, orElse: () => medium);
}
