import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';
import 'package:get_it/get_it.dart';
import 'package:human_benchmark/colors.dart';
import 'package:human_benchmark/data/sound_manager.dart';
import 'package:human_benchmark/main.dart';

class ReactionQueueGame extends StatefulWidget {
  const ReactionQueueGame({super.key});

  @override
  State<ReactionQueueGame> createState() => _ReactionQueueGameState();
}

enum Option { up, right, down, left, bomb }

class _ReactionQueueGameState extends State<ReactionQueueGame>
    with TickerProviderStateMixin {
  static const double _slideDistance = 0.1;
  static const Duration _flyDuration = Duration(milliseconds: 400);

  int optionCount = 3;
  final List<Option> options = [];
  StreamSubscription<GamepadEvent>? gamepadSubscription;
  late final SoundManager soundManager;

  Option? lastCorrectOption;

  late final AnimationController _flyController;
  late Animation<Offset> _flyOffset;
  late final Animation<double> _flyOpacity;
  late final Animation<double> _bombScale;

  bool showFlyOverlay = false;
  bool levelTransitioning = false;
  bool showCheck = false;
  bool _isLastOptionCorrect = true;

  @override
  void initState() {
    soundManager = GetIt.instance<SoundManager>();
    super.initState();

    startNewLevel();
    gamepadSubscription = Gamepads.events.listen(handleGamepadEvent);

    _flyController = AnimationController(
      vsync: this,
      duration: _flyDuration,
    );

    _flyOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _flyController, curve: Curves.easeOutCubic),
    );

    _bombScale = Tween<double>(begin: 1, end: 1.8).animate(
      CurvedAnimation(parent: _flyController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    gamepadSubscription?.cancel();
    _flyController.dispose();
    super.dispose();
  }

  /* ───────────────────────────  GAME LOGIC  ─────────────────────────── */

  void startNewLevel() {
    setState(() {
      options
        ..clear()
        ..addAll(
          List<Option>.generate(optionCount, (_) {
            const bombChance = 0.1;
            final isBomb = Random().nextDouble() < bombChance;
            return isBomb
                ? Option.bomb
                : Option.values[Random().nextInt(Option.values.length - 1)];
          }),
        );
    });
  }

  void triggerFlyOverlay(Option option, bool isCorrect) {
    final Offset endOffset = switch (option) {
      Option.up => Offset(0, -_slideDistance),
      Option.right => Offset(_slideDistance, 0),
      Option.down => Offset(0, _slideDistance),
      Option.left => Offset(-_slideDistance, 0),
      Option.bomb => Offset.zero,
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

  void handleCorrectOption() {
    final option = options.first;
    soundManager.playCorrectChoiceSound();
    triggerFlyOverlay(option, true);

    setState(() => options.removeAt(0));

    if (options.length == 1) {
      Future.delayed(const Duration(milliseconds: 600), handleLevelComplete);
    }
  }

  void handleWrongOption() {
    soundManager.playBuzzSound();
    final option = options.first;
    triggerFlyOverlay(option, false);
  }

  Future<void> handleLevelComplete() async {
    if (levelTransitioning) return;
    levelTransitioning = true;

    setState(() => showCheck = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() => showCheck = false);
    await Future.delayed(const Duration(milliseconds: 500));

    optionCount++;
    startNewLevel();
    levelTransitioning = false;
  }

  void handleSelectOption(Option option) {
    if (options.isEmpty || levelTransitioning) return;
    final realOption = options.first;
    realOption == option ? handleCorrectOption() : handleWrongOption();
  }

  /* ─────────────────────────  GAMEPAD EVENTS  ───────────────────────── */

  void handleGamepadEvent(GamepadEvent event) {
    if (event.type == KeyType.button &&
        ['y.circle', 'l1.rectangle.roundedbottom'].contains(event.key) &&
        event.value == 1) {
      handleSelectOption(Option.bomb);
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

  /* ────────────────────────────  UI HELPERS  ─────────────────────────── */

  Widget buildOptionIcon(
    Option option, {
    double size = 100,
    Color? overrideColor,
  }) {
    switch (option) {
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
      case Option.bomb:
        return Icon(Icons.close, size: size, color: overrideColor ?? error);
    }
  }

  Widget buildOptionWidget() {
    if (showCheck) {
      return Center(child: Icon(Icons.check, size: 100, color: secondary));
    }
    if (options.isEmpty) return const SizedBox.shrink();
    return Center(child: buildOptionIcon(options.first));
  }

  Widget buildFlyOverlay() {
    if (!showFlyOverlay || lastCorrectOption == null)
      return const SizedBox.shrink();

    final child = Center(
      child: buildOptionIcon(
        lastCorrectOption!,
        size: 100,
        overrideColor: _isLastOptionCorrect ? primary : error,
      ),
    );

    return lastCorrectOption == Option.bomb
        ? ScaleTransition(
            scale: _bombScale,
            child: FadeTransition(opacity: _flyOpacity, child: child),
          )
        : SlideTransition(
            position: _flyOffset,
            child: FadeTransition(opacity: _flyOpacity, child: child),
          );
  }

  /* ──────────────────────────────  BUILD  ────────────────────────────── */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                color: const Color(0xff050505),
                border: Border.all(
                  color: Colors.white.withOpacity(.35),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: buildOptionWidget(),
            ),
            buildFlyOverlay(),
          ],
        ),
      ),
    );
  }
}
