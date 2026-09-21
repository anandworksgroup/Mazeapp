import 'package:flutter_test/flutter_test.dart';
import 'package:maze_adventure/features/maze/engine/difficulty.dart';
import 'package:maze_adventure/features/maze/engine/game_session.dart';
import 'package:maze_adventure/features/maze/engine/seeds.dart';
import 'package:maze_adventure/features/maze/generator/maze_generator.dart';
import 'package:maze_adventure/features/maze/generator/seeded_random.dart';
import 'package:maze_adventure/features/maze/models/maze.dart';
import 'package:maze_adventure/features/maze/models/maze_size.dart';

void main() {
  const gen = MazeGenerator();

  test('PRNG sequence is pinned so saved seeds never change meaning', () {
    final r = SeededRandom(12345);
    expect([for (var i = 0; i < 4; i++) r.nextUint32()],
        [4207900869, 1317490944, 2079646450, 3513001552]);
  });

  test('same seed and size give the same maze', () {
    for (final size in MazeSize.all) {
      final a = gen.generate(seed: 12345, size: size);
      final b = gen.generate(seed: 12345, size: size);
      for (var y = 0; y < size.rows; y++) {
        for (var x = 0; x < size.columns; x++) {
          expect(a.openingsAt(Pos(x, y)), b.openingsAt(Pos(x, y)));
        }
      }
      expect(a.goal, b.goal);
    }
  });

  test('different seeds give different mazes', () {
    final a = gen.generate(seed: 12345, size: MazeSize.medium);
    final b = gen.generate(seed: 91827, size: MazeSize.medium);
    var differs = false;
    for (var i = 0; i < 144 && !differs; i++) {
      final p = Pos(i % 12, i ~/ 12);
      differs = a.openingsAt(p) != b.openingsAt(p);
    }
    expect(differs, isTrue);
  });

  test('every cell is reachable and the goal is on the edge', () {
    for (final size in MazeSize.all) {
      for (var seed = 1; seed <= 40; seed++) {
        final m = gen.generate(seed: seed * 7919, size: size);
        final dist = m.distancesFrom(m.start);
        expect(dist.every((d) => d >= 0), isTrue,
            reason: '${size.id} seed $seed');
        final g = m.goal;
        expect(
            g.x == 0 || g.y == 0 || g.x == m.columns - 1 || g.y == m.rows - 1,
            isTrue);
        expect(g, isNot(m.start));
      }
    }
  });

  test('walls are symmetric between neighbours', () {
    final m = gen.generate(seed: 42, size: MazeSize.extreme);
    for (var y = 0; y < m.rows; y++) {
      for (var x = 0; x < m.columns; x++) {
        final p = Pos(x, y);
        for (final d in Direction.values) {
          final n = p.step(d);
          if (!m.contains(n)) {
            expect(m.canMove(p, d), isFalse);
          } else {
            expect(m.canMove(p, d), m.canMove(n, d.opposite));
          }
        }
      }
    }
  });

  test('difficulty rises with size on average', () {
    const analyzer = DifficultyAnalyzer();
    double avg(MazeSize s) {
      var total = 0.0;
      for (var seed = 1; seed <= 20; seed++) {
        total += analyzer.analyze(gen.generate(seed: seed, size: s)).score;
      }
      return total / 20;
    }

    final scores = MazeSize.all.map(avg).toList();
    for (var i = 1; i < scores.length; i++) {
      expect(scores[i], greaterThan(scores[i - 1]), reason: '$scores');
    }
  });

  test('session blocks walls, counts bumps and finishes on the goal', () {
    final m = gen.generate(seed: 7, size: MazeSize.small);
    final s = GameSession(maze: m, size: MazeSize.small);
    final blocked = Direction.values.firstWhere((d) => !m.canMove(m.start, d));
    expect(s.step(blocked), StepOutcome.blocked);
    expect(s.bumps, 1);
    expect(s.position, m.start);

    final path = m.shortestPath(m.start, m.goal);
    StepOutcome last = StepOutcome.moved;
    for (var i = 1; i < path.length; i++) {
      final d = Direction.values.firstWhere(
          (d) => path[i - 1].step(d) == path[i]);
      last = s.step(d);
    }
    expect(last, StepOutcome.reachedGoal);
    expect(s.moves, s.optimalSteps);
    expect(s.stars, greaterThanOrEqualTo(2));
    expect(s.isPerfect, isFalse);
  });

  test('slide stops at forks and walls', () {
    final m = gen.generate(seed: 99, size: MazeSize.large);
    final s = GameSession(maze: m, size: MazeSize.large);
    for (final d in m.exits(m.start)) {
      final plan = s.slidePlan(d);
      expect(plan, isNotEmpty);
      var p = m.start;
      for (final step in plan) {
        expect(m.canMove(p, step), isTrue);
        p = p.step(step);
      }
    }
  });

  test('daily seed is stable per date and changes across days', () {
    final a = Seeds.daily(DateTime(2026, 9, 21, 8));
    final b = Seeds.daily(DateTime(2026, 9, 21, 23));
    final c = Seeds.daily(DateTime(2026, 9, 22));
    expect(a, b);
    expect(a, isNot(c));
    expect(Seeds.dayKey(DateTime(2026, 9, 1)), '2026-09-01');
  });
}
