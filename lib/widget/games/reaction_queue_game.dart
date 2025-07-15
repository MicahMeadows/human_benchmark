import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:human_benchmark/colors.dart';
import 'package:human_benchmark/data/sound_manager.dart';
import 'package:human_benchmark/main.dart';

class ReactionQueueGame extends StatefulWidget {
  const ReactionQueueGame({super.key});

  @override
  State<ReactionQueueGame> createState() => _ReactionQueueGameState();
}

enum Option { up, right, down, left, circle, bomb }

enum Direction { up, right, down, left }

class _ReactionQueueGameState extends State<ReactionQueueGame>
    with TickerProviderStateMixin {
  /* ─────────────────────  TUNABLES  ───────────────────── */
  static const double _slideDistance = 0.1; // fly‑off overlay
  static const Duration _flyDuration = Duration(milliseconds: 400);

  static const double _zoneSize = 300; // hit zone
  static const double _iconSize = 100; // arrow icon size
  static const double _spawnOffset = 500; // distance from centre
  // static const Duration _arrowDuration = Duration(seconds: 1);

  bool endAfterCircle = false;
  bool isCircleGame = false;
  int circleGameAngleWindow = 15;
  double circleGameStartAngle = 0;
  double circleGameEndAngle = 0;
  double circleGameDeltaAngle = 0;
  late AnimationController _circleGameController;
  Duration get _circleGameDuration =>
      Duration(milliseconds: getCircleGameDurMillis());
  late Animation<double> _circleGameProgress; // from 0 to 1

  int getCircleGameDurMillis() {
    if (level < 5) return 1000;
    if (level < 10) return 800;
    if (level < 20) return 600;
    return 400;
    // return 2000 - ((level - 2) * 100) + 100;
  }

  Duration get _arrowDuration => Duration(milliseconds: getArrowDuration());
  bool _inputCooldown = false;
  int getArrowDuration() {
    return 1000 - ((level - 2) * 25) + 25;

    // if (level < 3) return 1000;
    // if (level < 5) return 900;
    // if (level < 8) return 850;
    // if (level < 11) return 850;
    // if (level < 15) return 600;
    // if (level < 18) return 500;
    // return 400;
  }

  bool showX = false;

  int totalScore = 0;

  int levelScore = 0;
  GlobalKey scoreGlobalKey = GlobalKey();
  GlobalKey cursorGlobalKey = GlobalKey();
  List<GlobalKey> heartKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  void animateScoreFly({required Offset start, required int scoreDelta}) {
    // 1️⃣  Find the score text's top‑left on screen
    final scoreBox =
        scoreGlobalKey.currentContext?.findRenderObject() as RenderBox?;
    if (scoreBox == null) return;
    final end = scoreBox.localToGlobal(Offset.zero);

    // 2️⃣  Choose randomised duration, curve, scale, and Bézier control point
    final duration = Duration(milliseconds: Random().nextInt(400) + 400);

    final curveOptions = [
      Curves.easeInOut,
      Curves.easeOutBack,
      Curves.fastOutSlowIn,
      Curves.decelerate,
    ];
    final curve = curveOptions[Random().nextInt(curveOptions.length)];

    final mid = Offset.lerp(start, end, .5)!;
    final arcHeight = 100 + Random().nextDouble() * 100;
    final arcDir = Random().nextBool() ? 1 : -1;
    final arcWidth = Random().nextDouble() * 100 * arcDir;
    final ctrl = mid + Offset(arcWidth, -arcHeight);

    final scaleStart = .5 + Random().nextDouble() * .1; // 0.5–0.6
    final scaleEnd = 1.0 + Random().nextDouble() * .5; // 1.0–1.5

    Offset qBezier(double t, Offset p0, Offset p1, Offset p2) {
      final u = 1 - t;
      return Offset(
        u * u * p0.dx + 2 * u * t * p1.dx + t * t * p2.dx,
        u * u * p0.dy + 2 * u * t * p1.dy + t * t * p2.dy,
      );
    }

    // 3️⃣  Build overlay entry
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: duration,
        curve: curve,
        builder: (_, t, child) {
          final pos = qBezier(t, start, ctrl, end);
          final scale = lerpDouble(scaleStart, scaleEnd, t)!;

          return Positioned(
            left: pos.dx,
            top: pos.dy,
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: max(min(0, 1 - t), 1),
                child: child,
              ),
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: Text(
            '${scoreDelta > 0 ? '+' : ''}$scoreDelta',
            style: TextStyle(
              fontSize: 32,
              color: scoreDelta >= 0 ? secondary : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(duration, () => entry.remove());
  }

  double _centreBonusMultiplier() {
    final size = MediaQuery.of(context).size;

    final iconTL = _iconTopLeft(
      size,
      _arrowController.value,
      _currentArrowDirection,
    );
    final iconCtr = iconTL + const Offset(_iconSize / 2, _iconSize / 2);

    final zoneCtr = Offset(size.width / 2, size.height / 2);

    final dist = (iconCtr - zoneCtr).distance;

    final maxDist = (_zoneSize - _iconSize) / 2;

    final threshold = maxDist * 0.2;

    if (dist <= threshold) {
      return 1.0;
    }

    final t = ((dist - threshold) / (maxDist - threshold)).clamp(0.0, 1.0);
    return 1.0 - 0.5 * t; // drops from 1 to 0.5 between 80% and 100%
  }

  void animateLostHeart(int index) {
    final context = heartKeys[index].currentContext;
    if (context == null) return;

    final box = context.findRenderObject() as RenderBox;
    final startOffset = box.localToGlobal(Offset.zero);

    final overlay = Overlay.of(context);
    final duration = Duration(milliseconds: 800);

    final random = Random();
    // Random angle between 5 and 25 degrees, with random sign (±)
    final endRotationDegrees =
        (5 + random.nextDouble() * 20) * (random.nextBool() ? 1 : -1);
    final endRotationRadians = endRotationDegrees * (pi / 180);

    final entry = OverlayEntry(
      builder: (ctx) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: duration,
        builder: (context, t, child) {
          final rotation = lerpDouble(0, endRotationRadians, t)!;
          return Positioned(
            top: startOffset.dy + t * 60,
            left: startOffset.dx,
            child: Opacity(
              opacity: 1 - t,
              child: Transform.rotate(
                angle: rotation,
                child: child,
              ),
            ),
          );
        },
        child: Icon(
          Icons.favorite_border,
          color: Colors.white,
          size: 40,
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(duration, () => entry.remove());
  }

  static const int maxLives = 3;

  Color? _zoneBorderColor;

  /* ─────────────────────  STATE  ───────────────────── */
  late Direction _currentArrowDirection;
  final Random _random = Random();

  int getOptionCount() {
    // return 3;
    return level + 2;
  }

  int level = 1;
  // int optionCount = 3;
  int get optionCount => getOptionCount();

  final List<Option> options = [];
  StreamSubscription<GamepadEvent>? gamepadSubscription;
  late final SoundManager soundManager;

  Option? lastCorrectOption;

  late Animation<double> _circleGameAngle;

  late final AnimationController _flyController;
  late Animation<Offset> _flyOffset;
  late final Animation<double> _flyOpacity;
  late final Animation<double> _circleScale;

  late final AnimationController _arrowController;

  bool showFlyOverlay = false;
  bool levelTransitioning = false;
  bool showCheck = false;
  bool _isLastOptionCorrect = true;
  bool didMissArrow = false;

  // Lives & game over state
  int lives = maxLives;
  int levelLives = 3;

  /* ─────────────────────  INIT / DISPOSE  ───────────────────── */
  @override
  void initState() {
    super.initState();
    soundManager = GetIt.instance<SoundManager>();

    _circleGameController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _flyController = AnimationController(vsync: this, duration: _flyDuration);
    _flyOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _flyController, curve: Curves.easeOutCubic),
    );
    _circleScale = Tween<double>(begin: 1, end: 1.8).animate(
      CurvedAnimation(parent: _flyController, curve: Curves.easeOutCubic),
    );

    _arrowController = AnimationController(
      vsync: this,
      duration: _arrowDuration,
    );

    // Mark a miss when arrow reaches its target edge
    _arrowController.addListener(() {
      if (!didMissArrow && _arrowController.value >= 1.0) {
        didMissArrow = true;
        if (options.isNotEmpty && options.first == Option.bomb) {
          // Bomb reached end: treat as correct (player avoided it)
          handleCorrectOption();
        } else {
          // Normal arrow missed
          handleWrongOption();
        }
      }
    });

    startNewLevel();
    gamepadSubscription = Gamepads.events.listen(handleGamepadEvent);
  }

  @override
  void dispose() {
    gamepadSubscription?.cancel();
    _flyController.dispose();
    _arrowController.dispose();
    super.dispose();
  }

  /* ─────────────────────  LEVEL / OPTION LOGIC  ───────────────────── */
  void startNewLevel() {
    levelLives = 3;

    // setState(() {
    //   options
    //     ..clear()
    //     ..addAll(
    //       List<Option>.generate(optionCount, (_) {
    //         return Option.values[_random.nextInt(Option.values.length)];
    //       }),
    //     );
    // });
    setState(() {
      options
        ..clear()
        ..addAll(
          List<Option>.generate(optionCount, (_) {
            final pool = <Option>[
              Option.up,
              Option.right,
              Option.down,
              Option.left,
              Option.circle,
            ];

            if (level > 5) {
              final randomChance = .05;
              final randomValue = _random.nextDouble();

              if (randomValue < randomChance) {
                return Option.bomb; // 10% chance to add a bomb
              }
            }

            return pool[_random.nextInt(pool.length)];
          }),
        );
    });

    didMissArrow = false;
    _pickNewArrowDirection();
    _arrowController.duration = _arrowDuration;
    _arrowController.forward(from: 0);
  }

  void _pickNewArrowDirection() {
    if (level <= 5) {
      final choices = [
        Direction.up,
      ];
      _currentArrowDirection = choices[_random.nextInt(choices.length)];
    } else if (level <= 10) {
      final choices = [
        Direction.up,
        Direction.down,
      ];
      _currentArrowDirection = choices[_random.nextInt(choices.length)];
    } else {
      final choices = Direction.values;
      _currentArrowDirection = choices[_random.nextInt(choices.length)];
    }
  }

  void _nextArrowOrLevelEnd() {
    if (options.isNotEmpty) {
      didMissArrow = false;
      _pickNewArrowDirection();
      _arrowController.forward(from: 0); // launch next arrow
    } else {
      if (isCircleGame) {
        endAfterCircle = true;
      } else {
        handleLevelComplete(false);
      }
    }
  }

  /* ─────────────────────  GAMEPAD INPUT  ───────────────────── */
  void handleGamepadEvent(GamepadEvent event) {
    if (event.type == KeyType.button &&
        ['y.circle', 'l1.rectangle.roundedbottom'].contains(event.key) &&
        event.value == 1) {
      handleSelectOption(Option.circle);
    }

    if (event.type == KeyType.analog) {
      if (event.key == 'l.joystick - yAxis') {
        if (event.value > .95) {
          handleSelectOption(Option.down);
        } else if (event.value < -.95) {
          handleSelectOption(Option.up);
        }
      } else if (event.key == 'l.joystick - xAxis') {
        if (event.value > .95) {
          handleSelectOption(Option.left);
        } else if (event.value < -.95) {
          handleSelectOption(Option.right);
        }
      }
    }
  }

  /* ─────────────────────  POSITION HELPERS  ───────────────────── */
  /// Returns the **top‑left** coordinate of the icon for the current animation
  Offset _iconTopLeft(Size size, double t, Direction dir) {
    final half = _iconSize / 2;
    final centreX = size.width / 2;
    final centreY = size.height / 2;

    final zoneLeft = centreX - _zoneSize / 2;
    final zoneRight = centreX + _zoneSize / 2;
    final zoneTop = centreY - _zoneSize / 2;
    final zoneBottom = centreY + _zoneSize / 2;

    late double startX, startY, targetX, targetY;

    switch (dir) {
      case Direction.down: // moves ↓
        startX = centreX - half;
        startY = centreY - _spawnOffset - half;
        targetX = startX;
        targetY = zoneBottom - half;
        break;

      case Direction.up: // moves ↑
        startX = centreX - half;
        startY = centreY + _spawnOffset - half;
        targetX = startX;
        targetY = zoneTop - half;
        break;

      case Direction.right: // moves →
        startY = centreY - half;
        startX = centreX - _spawnOffset - half;
        targetY = startY;
        targetX = zoneRight - half;
        break;

      case Direction.left: // moves ←
        startY = centreY - half;
        startX = centreX + _spawnOffset - half;
        targetY = startY;
        targetX = zoneLeft - half;
        break;
    }

    final top = startY + (targetY - startY) * t;
    final left = startX + (targetX - startX) * t;
    return Offset(left, top);
  }

  bool _arrowIsInsideZone(BuildContext context) {
    if (options.isEmpty) return false;
    final size = MediaQuery.of(context).size;
    final pos = _iconTopLeft(
      size,
      _arrowController.value,
      _currentArrowDirection,
    );
    final half = _iconSize / 2;
    final centre = pos + Offset(half, half);

    final zoneLeft = size.width / 2 - _zoneSize / 2;
    final zoneRight = zoneLeft + _zoneSize;
    final zoneTop = size.height / 2 - _zoneSize / 2;
    final zoneBottom = zoneTop + _zoneSize;

    return centre.dx >= zoneLeft &&
        centre.dx <= zoneRight &&
        centre.dy >= zoneTop &&
        centre.dy <= zoneBottom;
  }

  /* ─────────────────────  GAME LOGIC  ───────────────────── */
  void handleSelectOption(Option option) {
    if (_inputCooldown) return;
    if (options.isEmpty || levelTransitioning) return;

    if (isCircleGame) {
      handleCircleTap();
      return;
    }

    final bool inZone = _arrowIsInsideZone(context);
    final Option real = options.first;

    if (real == Option.bomb) {
      // Bomb always wrong even if in zone
      handleWrongOption();
      return;
    }

    if (inZone && real == option) {
      handleCorrectOption(isCircleStart: real == Option.circle);
    } else {
      handleWrongOption();
    }
  }

  void handleCorrectOption({
    bool isCircleStart = false,
    bool isCircleEnd = false,
  }) {
    if (_inputCooldown) return; // Prevent double input
    _inputCooldown = true;

    // 1️⃣  Work out where the icon is right now
    final size = MediaQuery.of(context).size;
    final iconTL = _iconTopLeft(
      size,
      _arrowController.value,
      _currentArrowDirection,
    );
    final iconCtr = iconTL + const Offset(_iconSize / 2, _iconSize / 2);

    // 2️⃣  Bonus calculation
    final mult = _centreBonusMultiplier(); // 1.0 → 0.5
    final earned = (100 * mult).round(); // int score

    // 3️⃣  State & sound
    soundManager.playCorrectChoiceSound();
    if (isCircleStart) {
      triggerFlyOverlay(options.first, true);
    }

    setState(() {
      // 🔥 KEY FIX: Don't remove circle option when starting circle game
      if (!isCircleEnd && !endAfterCircle && !isCircleStart) {
        options.removeAt(0);
      }
      // Only remove the circle option when the circle game actually ends
      if (isCircleEnd) {
        options.removeAt(0);
      }

      _zoneBorderColor = Colors.green;
      levelScore += earned;
      totalScore += earned;
    });

    // 4️⃣  Animate the flying "+score"
    animateScoreFly(start: iconCtr, scoreDelta: earned);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {
        _zoneBorderColor = null;
      });
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        _inputCooldown = false; // Reset cooldown after 100ms
      });
    });

    if (isCircleStart) {
      startCircleGame();
      return;
    }

    // Handle circle game completion
    if (isCircleEnd) {
      // Check if this was the last option after removing it
      if (options.isEmpty) {
        handleLevelComplete(false);
      } else {
        _nextArrowOrLevelEnd();
      }
      return;
    }

    // Handle regular options
    if (!isCircleEnd) {
      _nextArrowOrLevelEnd();
    }
  }

  void handleCircleTap() {
    bool counterClockWise = circleGameEndAngle > circleGameStartAngle;

    double anticipation =
        15 * (counterClockWise ? 1 : -1); // how far before the real target
    const double tolerance = 10; // ± window size

    final double currentAngle = _circleGameAngle.value % 360;

    // Shift the target 15° earlier and wrap into 0‑360
    final double anticipatedAngle =
        (circleGameEndAngle - anticipation + 360) % 360;

    // Smallest distance between two bearings
    double diff = (currentAngle - anticipatedAngle).abs();
    if (diff > 180) diff = 360 - diff;

    final bool isCorrect = diff <= tolerance;

    if (isCorrect) {
      winCircleGame();
    } else {
      failCircleGame();
    }
  }

  void failCircleGame() {
    _circleGameController.stop();
    handleWrongOption(isCircleGame: true);
    // if (endAfterCircle) {
    //   handleLevelComplete(false);
    // }
    setState(() {
      isCircleGame = false;
      _arrowController.forward(from: 0); // Restart arrow animation
    });
  }

  void winCircleGame() {
    _circleGameController.stop();
    handleCorrectOption(isCircleEnd: true);

    // if (endAfterCircle) {
    //   handleLevelComplete(false);
    // }
    setState(() {
      isCircleGame = false;
      _arrowController.forward(from: 0); // Restart arrow animation
    });
  }

  void startCircleGame() {
    final randomStartAngle = _random.nextInt(360).toDouble();
    // random value between 60 and 90
    final randomVal = 60 + _random.nextInt(31).toDouble();
    final randomEndAngle =
        randomStartAngle + (randomVal * (_random.nextBool() ? 1 : -1));

    setState(() {
      circleGameStartAngle = randomStartAngle;
      circleGameEndAngle = randomEndAngle;

      // Calculate delta, handling 0°/360° boundary correctly
      double delta = randomEndAngle - randomStartAngle;
      if (delta < 0) delta += 360;
      if (delta > 180) delta -= 360; // Take shortest path

      circleGameDeltaAngle = delta;
      isCircleGame = true;
      _arrowController.stop();
    });

    _arrowController.forward(from: 0);
    _arrowController.reset();
    _arrowController.stop();

    // Reset the controller to ensure it starts from 0
    _circleGameController.reset();

    // Set duration and create animation
    _circleGameController.duration = const Duration(seconds: 2);
    _circleGameProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _circleGameController, curve: Curves.linear),
    );

    // Create the angle animation - this is the key fix
    _circleGameAngle =
        Tween<double>(
          begin: circleGameStartAngle,
          end: circleGameStartAngle + circleGameDeltaAngle,
        ).animate(
          CurvedAnimation(parent: _circleGameController, curve: Curves.linear),
        );

    // Start the animation from 0
    // _circleGameController.duration = _circleGameDuration;
    _circleGameController.duration = _circleGameDuration;
    _circleGameController.forward(from: 0).whenComplete(() {
      if (mounted) {
        // winCircleGame();
        failCircleGame();
      }
    });
  }

  void failLevel() {
    lives--;
    animateLostHeart(lives);

    setState(() {
      totalScore -= levelScore;
    });

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final center =
          renderBox.localToGlobal(Offset.zero) +
          Offset(
            MediaQuery.of(context).size.width / 2,
            MediaQuery.of(context).size.height / 2,
          );
      animateScoreFly(start: center, scoreDelta: -levelScore);
      if (levelScore > 0) {
        Future.delayed(const Duration(milliseconds: 100), () {
          animateScoreFly(start: center, scoreDelta: -levelScore);
        });
      }
    }

    setState(() {
      levelScore = 0;
    });

    options.clear();
    handleLevelComplete(lives <= 0);
  }

  void endGame() {
    // GetIt.I<GameResultCubit>().chimpTestOver(
    //   ChimpTestResult(highScore: sequenceLength - 1),
    // );
    // GetIt.I<RecordsCubit>().saveChimpGameResult(
    //   ChimpTestResult(highScore: totalScore),
    // );
    context.go('/');
  }

  void handleWrongOption({bool isCircleGame = false}) {
    if (_inputCooldown ||
        levelTransitioning ||
        (options.isEmpty && !isCircleGame))
      return;
    _inputCooldown = true;

    soundManager.playBuzzSound();
    // triggerFlyOverlay(options.first, false);
    setState(() => _zoneBorderColor = Colors.red);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _zoneBorderColor = null; // Reset cooldown after 100ms
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _inputCooldown = false; // Reset cooldown after 100ms
        });
      }
    });

    setState(() {
      if (!isCircleGame && !endAfterCircle) {
        options.removeAt(0);
      }
      levelLives--;
      totalScore -= 50;

      if (levelLives <= 0) {
        failLevel();
      } else {
        if (!isCircleGame) {
          _nextArrowOrLevelEnd(); // 🟢 This was missing for levelLives > 0
        }
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final center =
              renderBox.localToGlobal(Offset.zero) +
              Offset(
                MediaQuery.of(context).size.width / 2,
                MediaQuery.of(context).size.height / 2,
              );
          animateScoreFly(start: center, scoreDelta: -50);
        }
      }
    });

    if (isCircleGame && endAfterCircle) {
      // If it's a circle game and we failed, we still want to end the level
      handleLevelComplete(false);
    }
  }

  Future<void> handleLevelComplete(bool shouldEnd) async {
    if (levelTransitioning) return;
    levelTransitioning = true;

    soundManager.playLevelCompleteSound();

    if (levelLives <= 0) {
      setState(() => showX = true);
      await Future.delayed(const Duration(seconds: 1));
      setState(() => showX = false);
    } else {
      level++;
      levelScore = 0; // 🔄 Reset only on level success
      setState(() => showCheck = true);
      await Future.delayed(const Duration(seconds: 1));
      setState(() => showCheck = false);
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (shouldEnd) {
      endGame();
      return;
    }

    startNewLevel();
    levelTransitioning = false;
  }

  Widget buildFailOverlay() {
    return showX
        ? Center(child: Icon(Icons.close, size: 100, color: error))
        : const SizedBox.shrink();
  }

  /* ─────────────────────  VISUAL OVERLAYS  ───────────────────── */
  void triggerFlyOverlay(Option option, bool isCorrect) {
    final Offset endOffset = switch (option) {
      Option.up => const Offset(0, -_slideDistance),
      Option.right => const Offset(_slideDistance, 0),
      Option.down => const Offset(0, _slideDistance),
      Option.left => const Offset(-_slideDistance, 0),
      Option.bomb => Offset.zero,
      Option.circle => Offset.zero,
    };

    _flyOffset = Tween<Offset>(begin: Offset.zero, end: endOffset).animate(
      CurvedAnimation(parent: _flyController, curve: Curves.easeOutCubic),
    );

    setState(() {
      lastCorrectOption = option;
      _isLastOptionCorrect = isCorrect;
      showFlyOverlay = true;
    });

    _flyController.forward(from: 0).then((_) {
      setState(() => showFlyOverlay = false);
    });
  }

  /* ─────────────────────  WIDGET BUILDERS  ───────────────────── */
  Widget buildOptionIcon(
    Option opt, {
    double size = _iconSize,
    Color? overrideColor,
  }) {
    switch (opt) {
      case Option.bomb:
        return Icon(
          Icons.warning, // or Icons.dangerous, Icons.brightness_high, etc.
          size: size,
          color: overrideColor ?? Colors.redAccent,
        );

      case Option.up:
        return Icon(
          Icons.arrow_upward,
          size: size,
          color: overrideColor ?? primary,
        );
      case Option.right:
        return Icon(
          Icons.arrow_forward,
          size: size,
          color: overrideColor ?? primary,
        );
      case Option.down:
        return Icon(
          Icons.arrow_downward,
          size: size,
          color: overrideColor ?? primary,
        );
      case Option.left:
        return Icon(
          Icons.arrow_back,
          size: size,
          color: overrideColor ?? primary,
        );
      //   return Icon(Icons.close, size: size, color: overrideColor ?? error);
      case Option.circle:
        return Icon(
          Icons.circle_outlined,
          size: size - 20,
          // color: overrideColor ?? error,
          color: overrideColor ?? primary,
        );
    }
  }

  Widget buildArrow() {
    if (options.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _arrowController,
      builder: (context, child) {
        final size = MediaQuery.of(context).size;
        final pos = _iconTopLeft(
          size,
          _arrowController.value,
          _currentArrowDirection,
        );

        // Fade‑in for first 25 % of the travel
        final opacity = (_arrowController.value / 0.25).clamp(0.0, 1.0);

        return Positioned(
          top: pos.dy,
          left: pos.dx,
          child: Opacity(opacity: opacity, child: child!),
        );
      },
      child: buildOptionIcon(options.first),
    );
  }

  Widget buildZone() {
    return Center(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: _zoneSize,
        width: _zoneSize,
        decoration: BoxDecoration(
          color: const Color(0xff050505),
          border: Border.all(
            color: _zoneBorderColor ?? Colors.white.withOpacity(.35),
            width: 4,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget buildFlyOverlay() {
    if (!showFlyOverlay || lastCorrectOption == null)
      return const SizedBox.shrink();

    final child = Center(
      child: buildOptionIcon(
        lastCorrectOption!,
        size: _iconSize,
        overrideColor: _isLastOptionCorrect ? primary : error,
      ),
    );

    return lastCorrectOption == Option.circle
        ? ScaleTransition(
            scale: _circleScale,
            child: FadeTransition(opacity: _flyOpacity, child: child),
          )
        : SlideTransition(
            position: _flyOffset,
            child: FadeTransition(opacity: _flyOpacity, child: child),
          );
  }

  Widget buildCheckOverlay() {
    return showCheck
        ? Center(child: Icon(Icons.check, size: 100, color: secondary))
        : const SizedBox.shrink();
  }

  Widget buildLivesDisplay() {
    return Container(
      margin: EdgeInsets.only(left: 80, top: 80, right: 80),
      child: Row(
        children: [
          SizedBox(width: 5),
          Text(
            'SCORE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 25),
          Text(
            key: scoreGlobalKey,
            '$totalScore',
            style: TextStyle(
              color: secondary,
              fontSize: 40,
            ),
          ),
          Spacer(),
          Text(
            'LIVES',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
            ),
          ),
          const SizedBox(width: 20),
          for (int i = 0; i < 3; i++)
            Container(
              key: heartKeys[i],
              child: Icon(
                // i < lives ? Icons.favorite : Icons.favorite_border,
                Icons.favorite,
                color: i < lives ? Colors.white : Colors.transparent,
                size: 40,
              ),
            ),

          // Icon(
          //   i < lives ? Icons.favorite : Icons.favorite_border,
          //   color: Colors.white,
          //   size: 40,
          // ),
        ],
      ),
    );
  }

  Widget buildCircleGame() {
    final double radius = 100; // Half of the big circle's size (200/2)
    final double smallCircleRadius =
        16; // Half of the existing small circle's size (20/2)
    final double smallerCircleRadius = 10; // New smaller circle radius

    bool counterClockWise = circleGameEndAngle > circleGameStartAngle;

    return Center(
      child: AnimatedBuilder(
        animation: _circleGameController,
        builder: (context, child) {
          // Get current angle from animation (already in degrees)
          final double currentAngleDegrees = _circleGameAngle.value;
          // Convert to radians for trigonometric functions
          final double endAngleDegrees =
              (circleGameEndAngle -
                  (circleGameAngleWindow * (counterClockWise ? 1 : -1))) %
              360;

          // Convert to radians for trigonometric functions
          final double currentAngleRad = currentAngleDegrees * pi / 180;
          final double endAngleRad = endAngleDegrees * pi / 180;

          // Center of the big circle
          final centerX = radius;
          final centerY = radius;

          // Position for the target circle at endAngle
          final targetCircleX = centerX + (radius - 2) * cos(endAngleRad);
          final targetCircleY = centerY + (radius - 2) * sin(endAngleRad);
          final targetLeft = targetCircleX - smallCircleRadius;
          final targetTop = targetCircleY - smallCircleRadius;

          // Position for the moving circle at current animated angle
          final movingCircleX = centerX + (radius - 2) * cos(currentAngleRad);
          final movingCircleY = centerY + (radius - 2) * sin(currentAngleRad);
          final movingLeft = movingCircleX - smallerCircleRadius;
          final movingTop = movingCircleY - smallerCircleRadius;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Big circle border
              Container(
                height: radius * 2,
                width: radius * 2,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.white, width: 4),
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              Positioned(
                left: targetLeft,
                top: targetTop,
                child: Container(
                  height: smallCircleRadius * 2,
                  width: smallCircleRadius * 2,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(smallCircleRadius),
                    border: Border.all(
                      color: primary,
                      width: 4,
                    ),
                  ),
                ),
              ),

              // Moving circle (the one that animates)
              Positioned(
                left: movingLeft,
                top: movingTop,
                child: Container(
                  height: smallerCircleRadius * 2,
                  width: smallerCircleRadius * 2,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(smallerCircleRadius),
                    border: Border.all(
                      color: primary,
                      width: 3,
                    ),
                  ),
                ),
              ),

              // Target circle (the one to aim for)
            ],
          );
        },
      ),
    );
  }

  /* ──────────────────────────────  BUILD  ────────────────────────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          buildLivesDisplay(),
          buildZone(),
          buildArrow(),
          buildFlyOverlay(),
          buildCheckOverlay(),
          buildFailOverlay(),
          if (isCircleGame) buildCircleGame(),
        ],
      ),
    );
  }
}
