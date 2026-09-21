// Prints the swipe directions that solve a maze, using the game's own
// generator and slide rule. Handy for driving a device in manual QA:
//   dart run tool/solve_swipes.dart <seed> <sizeId> [x y]
import 'package:maze_adventure/features/maze/engine/game_session.dart';
import 'package:maze_adventure/features/maze/generator/maze_generator.dart';
import 'package:maze_adventure/features/maze/models/maze.dart';
import 'package:maze_adventure/features/maze/models/maze_size.dart';

void main(List<String> args) {
  final size = MazeSize.byId(args[1]);
  final maze = const MazeGenerator().generate(seed: int.parse(args[0]), size: size);
  final start = args.length >= 4 ? Pos(int.parse(args[2]), int.parse(args[3])) : maze.start;
  final s = GameSession(maze: maze, size: size, position: start);
  final path = maze.shortestPath(start, maze.goal);
  final out = <String>[];
  while (s.position != maze.goal) {
    final next = path[path.indexOf(s.position) + 1];
    final d = Direction.values.firstWhere((d) => s.position.step(d) == next);
    for (final step in s.slidePlan(d)) {
      s.step(step);
    }
    out.add(d.name);
  }
  // ignore: avoid_print
  print(out.join(' '));
}
