import '../engine/game_session.dart';
import '../models/maze.dart';

/// Turns raw input (swipes, a drag target, a held direction from the joystick
/// or tilt) into one step at a time. The game screen asks [next] whenever the
/// previous step's animation has finished.
///
/// It never moves the player itself — [GameSession.step] does, which keeps
/// collision in one place.
class MovementController {
  MovementController(this.session);

  final GameSession session;

  final List<Direction> _plan = [];
  Direction? _queuedTurn;
  Pos? _dragTarget;
  Direction? _held;

  /// (position, direction) of the last wall bump from continuous input, so
  /// holding the stick against a wall counts as one bump, not sixty.
  (Pos, Direction)? _lastBump;

  bool get hasWork =>
      _plan.isNotEmpty ||
      _queuedTurn != null ||
      (_dragTarget != null && _dragTarget != session.position) ||
      _held != null;

  void clear() {
    _plan.clear();
    _queuedTurn = null;
    _dragTarget = null;
    _held = null;
    _lastBump = null;
  }

  /// A swipe: run down the corridor. Swiping sideways while running queues a
  /// turn that is taken at the next opening, so kids don't need perfect timing.
  void swipe(Direction d, {required bool moving}) {
    _dragTarget = null;
    if (!moving) {
      _plan
        ..clear()
        ..addAll(session.slidePlan(d));
      if (_plan.isEmpty) _plan.add(d); // Walks into the wall: a bump.
      _queuedTurn = null;
      return;
    }
    final current = _plan.isNotEmpty ? _plan.first : null;
    if (current == d) return;
    if (session.maze.canMove(session.position, d)) {
      _plan
        ..clear()
        ..addAll(session.slidePlan(d));
      _queuedTurn = null;
    } else {
      _queuedTurn = d;
    }
  }

  /// Single step (keyboard / accessibility), no sliding.
  void nudge(Direction d) {
    _plan
      ..clear()
      ..add(d);
    _queuedTurn = null;
  }

  set dragTarget(Pos? target) {
    _dragTarget = target;
    if (target != null) {
      _plan.clear();
      _queuedTurn = null;
    }
  }

  set held(Direction? d) {
    if (d != _held) _lastBump = null;
    _held = d;
    if (d != null) {
      _plan.clear();
      _queuedTurn = null;
    }
  }

  /// The next direction to attempt, or null when there is nothing to do.
  /// Returns directions that are open, except when a deliberate input
  /// should register as a wall bump.
  Direction? next() {
    final maze = session.maze;
    final here = session.position;

    if (_queuedTurn != null && maze.canMove(here, _queuedTurn!)) {
      final turn = _queuedTurn!;
      _queuedTurn = null;
      _plan
        ..clear()
        ..addAll(session.slidePlan(turn));
    }
    if (_plan.isNotEmpty) return _plan.removeAt(0);
    if (_queuedTurn != null) {
      // Ran out of corridor before the turn was possible: bump into it.
      final turn = _queuedTurn!;
      _queuedTurn = null;
      return turn;
    }

    final target = _dragTarget;
    if (target != null && target != here) {
      final dx = target.x - here.x;
      final dy = target.y - here.y;
      final horizontal = dx == 0 ? null : (dx > 0 ? Direction.right : Direction.left);
      final vertical = dy == 0 ? null : (dy > 0 ? Direction.down : Direction.up);
      final ordered = dx.abs() >= dy.abs()
          ? [horizontal, vertical]
          : [vertical, horizontal];
      for (final d in ordered) {
        if (d != null && maze.canMove(here, d)) return d;
      }
      return _bumpOnce(ordered.firstWhere((d) => d != null)!);
    }

    final held = _held;
    if (held != null) {
      if (maze.canMove(here, held)) return held;
      return _bumpOnce(held);
    }
    return null;
  }

  Direction? _bumpOnce(Direction d) {
    final key = (session.position, d);
    if (_lastBump == key) return null;
    _lastBump = key;
    return d;
  }

  /// Called after every step so a new cell re-arms bump detection.
  void onStepped() {
    if (_lastBump != null && _lastBump!.$1 != session.position) _lastBump = null;
  }
}
