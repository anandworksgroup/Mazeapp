import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../app/app_controller.dart';
import '../../../app/app_scope.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/constants/catalog.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/widgets/chunky.dart';
import '../../../database/dao/models.dart';
import '../../character/animated_character.dart';
import '../../character/character_painter.dart';
import '../../settings/game_settings.dart';
import '../../themes/world_art.dart';
import '../engine/game_session.dart';
import '../engine/seeds.dart';
import '../generator/maze_generator.dart';
import '../models/maze.dart';
import '../models/maze_size.dart';
import '../movement/joystick.dart';
import '../movement/movement_controller.dart';
import 'game_launch.dart';
import 'maze_painters.dart';
import 'result_panel.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.launch});

  final GameLaunch launch;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late GameLaunch _launch;
  late GameSession _session;
  late MazeGeometry _geometry;
  late MovementController _mover;
  late WorldDef _world;
  late CharacterDef _character;

  late final AnimationController _move;
  late final AnimationController _loop;
  late final AnimationController _bump;
  late final AnimationController _confetti;
  late final Ticker _clock;

  Pos _from = const Pos(0, 0);
  Direction _facing = Direction.down;
  Direction _bumpDir = Direction.down;
  CharacterPose _pose = CharacterPose.idle;

  final _seconds = ValueNotifier<int>(0);
  int _elapsedBase = 0;
  bool _started = false;
  bool _paused = false;
  bool _completing = false;
  bool _needsTiltCalibration = false;
  CompletionResult? _result;
  bool _dirty = false;
  bool _interstitialDue = false;

  Offset _swipeAcc = Offset.zero;

  /// Direction already sent during the current finger-down gesture. One
  /// swipe = one slide; only a change of direction sends another.
  Direction? _gestureDir;
  StreamSubscription<AccelerometerEvent>? _tiltSub;
  Offset? _tiltBase;
  Offset _tiltNow = Offset.zero;
  Timer? _autosave;
  DateTime _lastBumpFeedback = DateTime(0);

  // Board layout, refreshed every build; used to map touches to cells.
  double _cell = 40;
  double _pad = 16;
  Offset _boardOrigin = Offset.zero;
  final _viewportKey = GlobalKey();
  final _focus = FocusNode();

  GameSettings get _settings => context.appRead.settings;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _launch = widget.launch;
    _move = AnimationController(vsync: this)..addStatusListener(_onMoveStatus);
    _loop = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _bump = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _confetti = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
    _clock = createTicker(_onTick);
    _build(_launch);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applySettings();
  }

  void _applySettings() {
    final s = _settings;
    _move.duration = Duration(
        milliseconds: s.animations
            ? context.config.moveDurationMs
            : context.config.reducedMotionMoveDurationMs);
    if (!s.animations) {
      _loop.stop();
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
    _syncTilt();
    _autosave ??= Timer.periodic(
        Duration(milliseconds: context.config.autosaveIntervalMs), (_) => _save());
  }

  void _build(GameLaunch launch) {
    _launch = launch;
    final maze = const MazeGenerator().generate(seed: launch.seed, size: launch.size);
    final saved = launch.resume;
    _session = GameSession(
      maze: maze,
      size: launch.size,
      position: saved?.position,
      moves: saved?.moves ?? 0,
      bumps: saved?.bumps ?? 0,
      elapsedMs: saved?.elapsedMs ?? 0,
      trail: saved == null || saved.trail.isEmpty ? null : saved.trail,
    );
    _geometry = MazeGeometry(maze);
    _world = Catalog.world(launch.worldId);
    _character = Catalog.character(launch.characterId);
    _mover = MovementController(_session);
    _from = _session.position;
    _facing = Direction.down;
    _pose = CharacterPose.idle;
    _elapsedBase = _session.elapsedMs;
    _seconds.value = _elapsedBase ~/ 1000;
    _started = false;
    _completing = false;
    _result = null;
    _dirty = false;
    _paused = false;
    _move.value = 1;
    _confetti.value = 0;
    _swipeAcc = Offset.zero;
    if (_clock.isActive) _clock.stop();
  }

  // ---- timer & persistence -------------------------------------------------

  void _onTick(Duration elapsed) {
    _session.elapsedMs = _elapsedBase + elapsed.inMilliseconds;
    final s = _session.elapsedMs ~/ 1000;
    if (s != _seconds.value) _seconds.value = s;
  }

  void _startClockIfNeeded() {
    if (_started || _paused) return;
    _started = true;
    _elapsedBase = _session.elapsedMs;
    _clock.start();
  }

  void _stopClock() {
    if (_clock.isActive) {
      _clock.stop();
      _elapsedBase = _session.elapsedMs;
    }
  }

  Future<void> _save() async {
    if (!_dirty || _session.isComplete || _completing) return;
    _dirty = false;
    await context.appRead.saveGame(SavedGame(
      seed: _launch.seed,
      sizeId: _launch.size.id,
      themeId: _launch.worldId,
      characterId: _launch.characterId,
      mode: _launch.mode,
      dayKey: _launch.mode == PlayMode.daily ? context.appRead.todayKey : null,
      position: _session.position,
      moves: _session.moves,
      bumps: _session.bumps,
      elapsedMs: _session.elapsedMs,
      trail: _session.trail,
    ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_started && !_session.isComplete && !_paused) _setPaused(true);
      _save();
    }
  }

  // ---- movement ------------------------------------------------------------

  void _kick() {
    if (_paused || _completing || _needsTiltCalibration) return;
    if (_move.isAnimating) return;
    final d = _mover.next();
    if (d == null) {
      if (_pose == CharacterPose.walk) setState(() => _pose = CharacterPose.idle);
      return;
    }
    _startClockIfNeeded();
    final before = _session.position;
    final outcome = _session.step(d);
    _mover.onStepped();
    _dirty = true;
    final audio = context.audio;
    switch (outcome) {
      case StepOutcome.blocked:
        _bumpDir = d;
        setState(() => _facing = d);
        _bump.forward(from: 0);
        final now = DateTime.now();
        if (now.difference(_lastBumpFeedback).inMilliseconds > 250) {
          _lastBumpFeedback = now;
          audio.play(Sfx.blocked, volume: 0.8);
          audio.haptic(HapticKind.bump);
        }
        // Keep draining input (a queued turn may still be pending).
        Future.microtask(_kick);
      case StepOutcome.moved:
      case StepOutcome.reachedGoal:
        audio.play(Sfx.movement, volume: 0.45);
        setState(() {
          _from = before;
          _facing = d;
          _pose = CharacterPose.walk;
        });
        _move.forward(from: 0);
    }
  }

  void _onMoveStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (_session.isComplete) {
      _onGoal();
      return;
    }
    _kick();
  }

  Future<void> _onGoal() async {
    if (_completing) return;
    _completing = true;
    _stopClock();
    _mover.clear();
    final audio = context.audio;
    final controller = context.appRead;
    final ads = context.ads;
    audio.play(Sfx.goal);
    audio.haptic(HapticKind.success);
    setState(() => _pose = CharacterPose.celebrate);
    if (_settings.animations) _confetti.forward(from: 0);

    final result = await controller.recordCompletion(
      session: _session,
      themeId: _launch.worldId,
      characterId: _launch.characterId,
      mode: _launch.mode,
    );
    // The full-screen ad is counted here but shown only when the player
    // leaves the result screen, so it never lands on the celebration.
    _interstitialDue = ads.countMazeAndCheck();
    await Future<void>.delayed(Duration(milliseconds: _settings.animations ? 1100 : 300));
    if (!mounted) return;
    audio.play(Sfx.success);
    setState(() => _result = result);
    if (result.hasUnlocks) {
      Future.delayed(const Duration(milliseconds: 1300), () => audio.play(Sfx.unlock));
    }
    if (result.newAchievements.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 1900), () => audio.play(Sfx.achievement));
    }
  }

  // ---- input ---------------------------------------------------------------

  Direction _dominant(Offset v) => v.dx.abs() > v.dy.abs()
      ? (v.dx > 0 ? Direction.right : Direction.left)
      : (v.dy > 0 ? Direction.down : Direction.up);

  void _onPanStart(DragStartDetails d) {
    _swipeAcc = Offset.zero;
    _gestureDir = null;
    if (_settings.controlMode == ControlMode.drag) _dragTo(d.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails d) {
    switch (_settings.controlMode) {
      case ControlMode.swipe:
        _swipeAcc += d.delta;
        if (_swipeAcc.distance >= context.config.swipeThresholdPx) {
          final dir = _dominant(_swipeAcc);
          _swipeAcc = Offset.zero;
          if (dir != _gestureDir) {
            _gestureDir = dir;
            _mover.swipe(dir, moving: _move.isAnimating);
            _kick();
          }
        }
      case ControlMode.drag:
        _dragTo(d.localPosition);
      default:
        break;
    }
  }

  void _onPanEnd(DragEndDetails d) {
    if (_settings.controlMode == ControlMode.swipe) {
      // A quick flick shorter than the threshold still counts.
      final v = d.velocity.pixelsPerSecond;
      if (_gestureDir == null && (_swipeAcc.distance > 6 || v.distance > 300)) {
        _mover.swipe(_dominant(_swipeAcc.distance > 6 ? _swipeAcc : v),
            moving: _move.isAnimating);
        _kick();
      }
      _swipeAcc = Offset.zero;
    } else if (_settings.controlMode == ControlMode.drag) {
      _mover.dragTarget = null;
    }
  }

  void _dragTo(Offset local) {
    final boardLocal = local - _boardOrigin - Offset(_pad, _pad);
    final x = (boardLocal.dx / _cell).floor();
    final y = (boardLocal.dy / _cell).floor();
    final maze = _session.maze;
    final target = Pos(x.clamp(0, maze.columns - 1), y.clamp(0, maze.rows - 1));
    _mover.dragTarget = target;
    _kick();
  }

  void _onStick(Offset v) {
    _mover.held = v.distance < 0.35 ? null : _dominant(v);
    _kick();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final d = switch (e.logicalKey) {
      LogicalKeyboardKey.arrowUp || LogicalKeyboardKey.keyW => Direction.up,
      LogicalKeyboardKey.arrowDown || LogicalKeyboardKey.keyS => Direction.down,
      LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.keyA => Direction.left,
      LogicalKeyboardKey.arrowRight || LogicalKeyboardKey.keyD => Direction.right,
      _ => null,
    };
    if (e.logicalKey == LogicalKeyboardKey.escape || e.logicalKey == LogicalKeyboardKey.keyP) {
      _setPaused(!_paused);
      return KeyEventResult.handled;
    }
    if (d == null) return KeyEventResult.ignored;
    _mover.swipe(d, moving: _move.isAnimating);
    _kick();
    return KeyEventResult.handled;
  }

  void _syncTilt() {
    final tilt = _settings.controlMode == ControlMode.tilt;
    if (tilt && _tiltSub == null) {
      _needsTiltCalibration = !_session.isComplete;
      try {
        _tiltSub = accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
            .listen(_onTilt, onError: (_) {});
      } catch (_) {
        _needsTiltCalibration = false;
      }
    } else if (!tilt && _tiltSub != null) {
      _tiltSub?.cancel();
      _tiltSub = null;
      _needsTiltCalibration = false;
      _mover.held = null;
    }
  }

  void _onTilt(AccelerometerEvent e) {
    // Light smoothing so hand tremor doesn't jitter the direction.
    _tiltNow = Offset.lerp(_tiltNow, Offset(e.x, e.y), 0.3)!;
    final base = _tiltBase;
    if (base == null || _needsTiltCalibration) return;
    // Android/iOS convention: lowering the right edge makes x negative,
    // lowering the top edge makes y negative. Roll "downhill" like a marble.
    final v = Offset(-(_tiltNow.dx - base.dx), _tiltNow.dy - base.dy);
    final dir = v.distance < context.config.tiltThreshold ? null : _dominant(v);
    _mover.held = dir;
    if (dir != null) _kick();
  }

  void _calibrateTilt() {
    setState(() {
      _tiltBase = _tiltNow;
      _needsTiltCalibration = false;
    });
  }

  // ---- menu actions --------------------------------------------------------

  void _setPaused(bool paused) {
    if (_session.isComplete || _completing) return;
    setState(() => _paused = paused);
    if (paused) {
      _stopClock();
      _mover.clear();
      _save();
    } else if (_started) {
      _elapsedBase = _session.elapsedMs;
      _clock.start();
    }
  }

  Future<void> _abandonIfPlayed() async {
    if (_session.isComplete) return;
    await context.appRead.recordAbandon(
      session: _session,
      themeId: _launch.worldId,
      characterId: _launch.characterId,
      mode: _launch.mode,
    );
  }

  Future<void> _restart() async {
    await _abandonIfPlayed();
    if (!mounted) return;
    setState(() => _build(GameLaunch(
          seed: _launch.seed,
          size: _launch.size,
          worldId: _launch.worldId,
          characterId: _launch.characterId,
          mode: _launch.mode,
        )));
    _syncTiltCalibration();
  }

  Future<void> _newMaze() async {
    await _showInterstitialIfDue();
    await _abandonIfPlayed();
    if (!mounted) return;
    final app = context.appRead;
    // After a Daily Maze, "next" continues with the player's own picks.
    final next = _launch.mode == PlayMode.daily
        ? GameLaunch.fresh(
            size: MazeSizeLookup.selected(app),
            worldId: app.player.selectedTheme,
            characterId: app.player.selectedCharacter,
          )
        : GameLaunch(
            seed: Seeds.random(),
            size: _launch.size,
            worldId: _launch.worldId,
            characterId: _launch.characterId,
          );
    setState(() => _build(next));
    _syncTiltCalibration();
  }

  /// Plays the pending full-screen ad, if one is due. Safe to call anywhere:
  /// with no ad loaded it returns at once.
  Future<void> _showInterstitialIfDue() async {
    if (!_interstitialDue) return;
    _interstitialDue = false;
    await context.ads.showInterstitialIfDue();
  }

  void _syncTiltCalibration() {
    if (_settings.controlMode == ControlMode.tilt) {
      setState(() => _needsTiltCalibration = true);
    }
  }

  Future<void> _home() async {
    await _showInterstitialIfDue();
    await _save();
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _change() async {
    await _showInterstitialIfDue();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(Routes.play);
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).pushNamed(Routes.settings);
    if (!mounted) return;
    _applySettings();
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autosave?.cancel();
    _tiltSub?.cancel();
    _clock.dispose();
    _move.dispose();
    _loop.dispose();
    _bump.dispose();
    _confetti.dispose();
    _seconds.dispose();
    _focus.dispose();
    super.dispose();
  }

  // ---- build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final s = app.settings;
    final l10n = context.l10n;
    final p = context.palette;
    final joystick = s.controlMode == ControlMode.joystick;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_result != null || _session.isComplete) {
          _home();
        } else {
          _setPaused(!_paused);
        }
      },
      child: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: Scaffold(
          backgroundColor: _world.skyBottom,
          body: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: ScenePainter(world: _world)),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _hud(l10n, s),
                    Expanded(child: _viewport(s)),
                    if (joystick)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                        child: Align(
                          alignment: s.leftHanded ? Alignment.centerLeft : Alignment.centerRight,
                          child: Joystick(onChanged: _onStick, size: s.largeUi ? 176 : 150),
                        ),
                      ),
                  ],
                ),
              ),
              if (!_started && !_paused && _result == null && !_needsTiltCalibration)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: joystick ? 190 : 28,
                  child: IgnorePointer(child: Center(child: _hint(l10n, s))),
                ),
              if (s.animations)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _confetti,
                      builder: (_, __) => CustomPaint(
                        painter: ConfettiPainter(progress: _confetti.value, seed: _launch.seed),
                      ),
                    ),
                  ),
                ),
              if (_needsTiltCalibration) _tiltOverlay(l10n, p),
              if (_paused) _pauseOverlay(l10n, p),
              if (_result != null)
                ResultPanel(
                  result: _result!,
                  session: _session,
                  world: _world,
                  character: _character,
                  daily: _launch.mode == PlayMode.daily,
                  onNext: _newMaze,
                  onChange: _change,
                  onHome: _home,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hud(AppLocalizations l10n, GameSettings s) {
    final p = context.palette;
    Widget chip(IconData icon, Widget text) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: p.card.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.outline, width: p.outlineWidth),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 20, color: p.ink),
            const SizedBox(width: 6),
            DefaultTextStyle(
              style: TextStyle(
                  fontSize: s.largeUi ? 22 : 18,
                  fontWeight: FontWeight.w900,
                  color: p.ink,
                  fontFeatures: const [FontFeature.tabularFigures()]),
              child: text,
            ),
          ]),
        );
    final pause = RoundButton(
      icon: Icons.pause_rounded,
      tooltip: l10n.paused,
      onTap: _result == null ? () => _setPaused(true) : null,
      size: s.largeUi ? 60 : 50,
    );
    final recenter = s.controlMode == ControlMode.tilt
        ? RoundButton(
            icon: Icons.screen_rotation_alt_rounded,
            tooltip: l10n.recalibrate,
            onTap: () => setState(() => _needsTiltCalibration = true),
            size: s.largeUi ? 60 : 50,
          )
        : SizedBox(width: s.largeUi ? 60 : 50);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        textDirection: s.leftHanded ? TextDirection.rtl : TextDirection.ltr,
        children: [
          pause,
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                if (s.showTimer)
                  chip(Icons.timer_rounded, ValueListenableBuilder<int>(
                    valueListenable: _seconds,
                    builder: (_, secs, __) => Text(l10n.clock(secs * 1000)),
                  )),
                if (s.showMoves)
                  chip(Icons.directions_walk_rounded, AnimatedBuilder(
                    animation: _move,
                    builder: (_, __) => Text('${_session.moves}'),
                  )),
              ],
            ),
          ),
          recenter,
        ],
      ),
    );
  }

  Widget _viewport(GameSettings s) {
    return LayoutBuilder(builder: (context, box) {
      final maze = _session.maze;
      final minCell = s.largeUi ? context.config.minCellPxLargeUi : context.config.minCellPx;
      const margin = 12.0;
      final fit = math.min(
        (box.maxWidth - margin * 2) / (maze.columns + 0.9),
        (box.maxHeight - margin * 2) / (maze.rows + 0.9),
      );
      final cell = math.min(120.0, math.max(fit, minCell));
      final pad = cell * 0.45;
      final boardW = maze.columns * cell + pad * 2;
      final boardH = maze.rows * cell + pad * 2;
      final follows = boardW > box.maxWidth || boardH > box.maxHeight;
      _cell = cell;
      _pad = pad;

      return GestureDetector(
        key: _viewportKey,
        behavior: HitTestBehavior.opaque,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: ClipRect(
          child: AnimatedBuilder(
            animation: Listenable.merge([_move, _loop, _bump]),
            builder: (context, _) {
              final tMove = Curves.easeInOut.transform(_move.value);
              final here = _session.position;
              final vx = _from.x + (here.x - _from.x) * tMove;
              final vy = _from.y + (here.y - _from.y) * tMove;

              double axis(double view, double board, double focus) {
                if (board <= view) return (view - board) / 2;
                return (view / 2 - focus).clamp(view - board, 0.0);
              }

              final origin = Offset(
                axis(box.maxWidth, boardW, pad + (vx + 0.5) * cell),
                axis(box.maxHeight, boardH, pad + (vy + 0.5) * cell),
              );
              _boardOrigin = origin;

              final shake = math.sin(_bump.value * math.pi) * cell * 0.12;
              final charSize = cell * 1.08;
              final charPos = origin +
                  Offset(pad + (vx + 0.5) * cell, pad + (vy + 0.5) * cell) +
                  Offset(_bumpDir.dx * shake, _bumpDir.dy * shake) -
                  Offset(charSize / 2, charSize * 0.58);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: origin.dx,
                    top: origin.dy,
                    width: boardW,
                    height: boardH,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: MazeBoardPainter(
                          geometry: _geometry,
                          world: _world,
                          cell: cell,
                          padding: pad,
                          highContrast: s.highContrast,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: origin.dx,
                    top: origin.dy,
                    width: boardW,
                    height: boardH,
                    child: CustomPaint(
                      painter: MazeOverlayPainter(
                        maze: maze,
                        world: _world,
                        trail: _session.trail,
                        cell: cell,
                        padding: pad,
                        t: _loop.value,
                        highContrast: s.highContrast,
                        showGoal: !_session.isComplete || _move.isAnimating,
                      ),
                    ),
                  ),
                  Positioned(
                    left: charPos.dx,
                    top: charPos.dy,
                    child: IgnorePointer(
                      child: AnimatedCharacter(
                        def: _character,
                        pose: _pose,
                        facing: _facing,
                        size: charSize,
                        animate: s.animations,
                      ),
                    ),
                  ),
                  if (follows && s.miniMap) _miniMap(box, origin, cell, pad, Offset(vx, vy)),
                ],
              );
            },
          ),
        ),
      );
    });
  }

  Widget _miniMap(BoxConstraints box, Offset origin, double cell, double pad, Offset player) {
    final p = context.palette;
    final maze = _session.maze;
    final side = math.min(130.0, box.maxWidth * 0.3);
    final h = side * maze.rows / maze.columns;
    final viewport = Rect.fromLTWH(
      (-origin.dx - pad) / cell,
      (-origin.dy - pad) / cell,
      box.maxWidth / cell,
      box.maxHeight / cell,
    );
    final left = _settings.leftHanded;
    return Positioned(
      top: 8,
      right: left ? null : 8,
      left: left ? 8 : null,
      child: IgnorePointer(
        child: Container(
          width: side + 6,
          height: h + 6,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: p.outline, width: 2.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CustomPaint(
              size: Size(side, h),
              painter: MiniMapPainter(
                geometry: _geometry,
                world: _world,
                player: player,
                viewport: viewport,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hint(AppLocalizations l10n, GameSettings s) {
    final p = context.palette;
    final text = switch (s.controlMode) {
      ControlMode.swipe => l10n.hintSwipe,
      ControlMode.drag => l10n.hintDrag,
      ControlMode.tilt => l10n.hintTilt,
      ControlMode.joystick => l10n.hintJoystick,
    };
    final icon = switch (s.controlMode) {
      ControlMode.swipe => Icons.swipe_rounded,
      ControlMode.drag => Icons.touch_app_rounded,
      ControlMode.tilt => Icons.screen_rotation_rounded,
      ControlMode.joystick => Icons.gamepad_rounded,
    };
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: p.card.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: p.outline, width: p.outlineWidth),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: p.ink),
        const SizedBox(width: 8),
        Flexible(
          child: Text(text,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: s.largeUi ? 20 : 16, color: p.ink)),
        ),
      ]),
    );
  }

  Widget _dim({required Widget child}) => Positioned.fill(
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.45),
          child: SafeArea(child: Center(child: SingleChildScrollView(child: child))),
        ),
      );

  Widget _tiltOverlay(AppLocalizations l10n, Palette p) => Positioned.fill(
        child: GestureDetector(
          onTap: _calibrateTilt,
          child: ColoredBox(
            color: Colors.black.withValues(alpha: 0.4),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: CuteCard(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.screen_rotation_rounded, size: 56, color: p.ink),
                    const SizedBox(height: 12),
                    Text(l10n.tiltCalibrate,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _pauseOverlay(AppLocalizations l10n, Palette p) {
    Widget button(String label, IconData icon, Color color, VoidCallback onTap) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ChunkyButton(
            onTap: onTap,
            label: label,
            icon: Icon(icon, color: Colors.white, size: 28),
            color: color,
            expand: true,
            height: 58,
          ),
        );
    return _dim(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: CuteCard(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlineText(l10n.paused, size: 36, color: p.yellow),
                const SizedBox(height: 6),
                AnimatedCharacter(
                    def: _character, pose: CharacterPose.sleep, size: 90, animate: _settings.animations),
                const SizedBox(height: 10),
                button(l10n.resume, Icons.play_arrow_rounded, p.play, () => _setPaused(false)),
                button(l10n.restart, Icons.replay_rounded, p.blue, _restart),
                button(l10n.newMaze, Icons.auto_awesome_rounded, p.purple, _newMaze),
                button(l10n.home, Icons.home_rounded, p.orange, _home),
                button(l10n.settings, Icons.settings_rounded, p.pink, _openSettings),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Resolves the player's selected size, falling back to an unlocked one.
class MazeSizeLookup {
  MazeSizeLookup._();

  static MazeSize selected(AppController app) {
    final id = app.player.selectedSize;
    return MazeSize.byId(app.sizes.contains(id) ? id : 'small');
  }
}
