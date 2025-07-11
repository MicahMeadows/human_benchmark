import 'dart:async';
import 'dart:math';
import 'dart:ui' show lerpDouble; // ← for animations

import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:human_benchmark/data/cubit/game_result/game_result_cubit.dart';
import 'package:human_benchmark/data/cubit/records/records_cubit.dart';
import 'package:human_benchmark/data/model/visual_memory_test_result.dart';
import 'package:human_benchmark/widget/flip_tile.dart';
import 'package:just_audio/just_audio.dart';

enum GameState { notStarted, preview, playing, finished, lost }

class VisualMemoryPage extends StatefulWidget {
  const VisualMemoryPage({super.key});
  @override
  State<VisualMemoryPage> createState() => _VisualMemoryPageState();
}

class _VisualMemoryPageState extends State<VisualMemoryPage> {
  int calculateGridHeight() => 800;
  int get gridHeight => calculateGridHeight();
  int calculateGridSize() {
    if (sequenceLength < 5) return 3;
    if (sequenceLength < 9) return 4;
    if (sequenceLength < 12) return 5;
    if (sequenceLength < 17) return 6;
    return 7;
  }

  int get gridSize => calculateGridSize();

  int sequenceLength = 3;
  int lives = 3; // overall lives
  int levelLives = 3; // lives in the current level (3 strikes → lose 1 life)
  GameState gameState = GameState.notStarted;

  int mouseX = 0;
  int mouseY = 0;

  int totalScore = 0;
  int bonusCountdown = 1000;
  bool isCountingDown = false;
  Timer? countdownTimer;

  final clickPlayer = AudioPlayer();
  final levelWinPlayer = AudioPlayer();
  final buzzPlayer = AudioPlayer();

  Set<int> availablePositions = {};
  Set<int> hiddenPositions = {};
  Set<int> correctPositions = {};
  Set<int> wrongGuessPositions = {};

  final List<GlobalKey> heartKeys = [GlobalKey(), GlobalKey(), GlobalKey()];
  final GlobalKey scoreGlobalKey = GlobalKey();
  late List<GlobalKey> tileKeys;

  StreamSubscription<GamepadEvent>? gamepadSubscription;
  @override
  void initState() {
    super.initState();

    clickPlayer.setAsset('assets/audio/click-click.wav');
    levelWinPlayer.setAsset('assets/audio/click2.wav');
    buzzPlayer.setAsset('assets/audio/buzz.wav');

    gamepadSubscription = Gamepads.events.listen(handleGamepadEvent);
    startLevel();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    gamepadSubscription?.cancel();
    super.dispose();
  }

  void handleGamepadEvent(GamepadEvent event) {
    if (event.type == KeyType.button) {
      if (['y.circle', 'l1.rectangle.roundedbottom'].contains(event.key) &&
          event.value == 0) {
        confirmTile();
      }
    } else if (event.type == KeyType.analog) {
      if (event.key == 'l.joystick - yAxis') {
        if (event.value <= -.95) {
          changeCursor(0, -1);
        } else if (event.value >= .95) {
          changeCursor(0, 1);
        }
      } else if (event.key == 'l.joystick - xAxis') {
        if (event.value <= -.95) {
          changeCursor(1, 0);
        } else if (event.value >= .95) {
          changeCursor(-1, 0);
        }
      }
    }
  }

  void changeCursor(int dX, int dY) {
    setState(() {
      mouseX = (mouseX + dX) % gridSize;
      mouseY = (mouseY + dY) % gridSize;
      if (mouseX < 0) mouseX += gridSize;
      if (mouseY < 0) mouseY += gridSize;
    });
  }

  Future<void> startLevel() async {
    levelLives = 3;
    bonusCountdown = 1000;
    isCountingDown = false;
    countdownTimer?.cancel();

    tileKeys = List.generate(gridSize * gridSize, (_) => GlobalKey());

    availablePositions = {};
    hiddenPositions = {};
    correctPositions = {};
    wrongGuessPositions = {};
    for (int i = 0; i < gridSize * gridSize; i++) {
      availablePositions.add(i);
    }

    for (int i = 0; i < sequenceLength; i++) {
      final idx = availablePositions.elementAt(
        Random().nextInt(availablePositions.length),
      );
      availablePositions.remove(idx);
      hiddenPositions.add(idx);
    }

    gameState = GameState.notStarted;
    await Future.delayed(const Duration(seconds: 2));

    setState(() => gameState = GameState.preview);
    await Future.delayed(const Duration(seconds: 2));

    setState(() => gameState = GameState.playing);
    startBonusCountdown();
  }

  void startBonusCountdown() {
    isCountingDown = true;
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (bonusCountdown <= 0 || gameState != GameState.playing) {
        bonusCountdown = max(0, bonusCountdown);
        t.cancel();
        return;
      }
      setState(() => bonusCountdown = max(0, bonusCountdown - 10));
    });
  }

  void addScore(int score, int tileIdx) {
    setState(() => totalScore += score);
    animateScore(tileIdx, score);
  }

  void removeScore(int score, int tileIdx) {
    setState(() => totalScore -= score);
    animateScore(tileIdx, -score);
  }

  void animateScore(int tileIdx, int score) {
    final tileCtx = tileKeys[tileIdx].currentContext;
    final scoreCtx = scoreGlobalKey.currentContext;
    if (tileCtx == null || scoreCtx == null) return;

    final tileBox = tileCtx.findRenderObject() as RenderBox;
    final scoreBox = scoreCtx.findRenderObject() as RenderBox;
    final start = tileBox.localToGlobal(Offset.zero);
    final end = scoreBox.localToGlobal(Offset.zero);

    animateScoreFrom(startOffset: start, endOffset: end, score: score);
  }

  void animateScoreFrom({
    required Offset startOffset,
    required Offset endOffset,
    required int score,
  }) {
    final overlay = Overlay.of(context);
    final duration = Duration(milliseconds: Random().nextInt(400) + 400);

    final mid = Offset.lerp(startOffset, endOffset, 0.5)!;
    final arcHeight = 100 + Random().nextDouble() * 100;
    final arcDir = Random().nextBool() ? 1 : -1;
    final control =
        mid + Offset(arcDir * Random().nextDouble() * 100, -arcHeight);

    Offset quad(double t, Offset p0, Offset p1, Offset p2) {
      final u = 1 - t;
      return Offset(
        u * u * p0.dx + 2 * u * t * p1.dx + t * t * p2.dx,
        u * u * p0.dy + 2 * u * t * p1.dy + t * t * p2.dy,
      );
    }

    final entry = OverlayEntry(
      builder: (_) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: duration,
        curve: Curves.easeInOut,
        builder: (_, t, child) {
          final pos = quad(t, startOffset, control, endOffset);
          final scale = lerpDouble(0.5, 1.5, t)!;
          return Positioned(
            top: pos.dy,
            left: pos.dx,
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: Text(
            '${score >= 0 ? '+' : '-'}${score.abs()}',
            style: TextStyle(
              fontSize: 32,
              color: score < 0 ? Color(0xffcf6679) : Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(duration, entry.remove);
  }

  void animateLostHeart(int idx) {
    final ctx = heartKeys[idx].currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject() as RenderBox;
    final start = box.localToGlobal(Offset.zero);
    final duration = const Duration(milliseconds: 800);
    final rnd = Random();
    final endRot =
        ((5 + rnd.nextDouble() * 20) * (rnd.nextBool() ? 1 : -1)) * (pi / 180);

    final entry = OverlayEntry(
      builder: (_) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: duration,
        builder: (_, t, child) {
          return Positioned(
            top: start.dy + 60 * t,
            left: start.dx,
            child: Opacity(
              opacity: 1 - t,
              child: Transform.rotate(
                angle: lerpDouble(0, endRot, t)!,
                child: child,
              ),
            ),
          );
        },
        child: const Icon(Icons.favorite_border, color: Colors.white, size: 40),
      ),
    );
    Overlay.of(context).insert(entry);
    Future.delayed(duration, entry.remove);
  }

  bool tileIsTappable(int idx) =>
      gameState == GameState.playing &&
      !correctPositions.contains(idx) &&
      !wrongGuessPositions.contains(idx);

  void confirmTile() {
    final idx = mouseX + mouseY * gridSize;
    if (tileIsTappable(idx)) chooseTile(idx);
  }

  void chooseTile(int idx) {
    if (hiddenPositions.contains(idx)) {
      handleCorrectTile(idx);
    } else {
      handleIncorrectTile(idx);
    }
  }

  bool getTileRevealed(int index) {
    return (gameState == GameState.preview &&
            hiddenPositions.contains(index)) ||
        correctPositions.contains(index) ||
        gameState == GameState.finished ||
        gameState == GameState.lost;
  }

  void handleCorrectTile(int idx) {
    if (gameState != GameState.playing) return;

    setState(() {
      hiddenPositions.remove(idx);
      correctPositions.add(idx);
    });

    // award points
    final isLast = hiddenPositions.isEmpty;
    addScore(isLast ? 100 + bonusCountdown : 100, idx);

    if (isLast) {
      winLevel();
    } else {
      playCorrectChoiceSound();
    }
  }

  void handleIncorrectTile(int idx) async {
    if (wrongGuessPositions.contains(idx)) return;

    playBuzzSound();
    setState(() {
      wrongGuessPositions.add(idx);
      levelLives--;
      removeScore(50, idx);
    });

    if (levelLives <= 0) {
      animateLostHeart(lives - 1);
      setState(() {
        lives--;
        gameState = GameState.lost;
      });
      countdownTimer?.cancel();

      if (lives <= 0) {
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        GetIt.I<GameResultCubit>().visualMemoryTestOver(
          VisualMemoryTestResult(tileCount: sequenceLength - 1),
        );
        GetIt.I<RecordsCubit>().saveVisualMemoryGameResult(
          VisualMemoryTestResult(tileCount: sequenceLength - 1),
        );
        context.go('/');
      } else {
        await Future.delayed(const Duration(seconds: 2));
        await startLevel();
      }
    }
  }

  void winLevel() async {
    playLevelCompleteSound();
    countdownTimer?.cancel();
    setState(() => gameState = GameState.finished);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => sequenceLength++);
    await startLevel();
  }

  void playLevelCompleteSound() async {
    await clickPlayer.seek(Duration.zero);
    await clickPlayer.play();
  }

  void playCorrectChoiceSound() async {
    await levelWinPlayer.seek(Duration.zero);
    await levelWinPlayer.play();
  }

  void playBuzzSound() async {
    await buzzPlayer.seek(Duration.zero);
    await buzzPlayer.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: const Color(0xFF121212),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 80, top: 80, right: 80),
                child: Row(
                  children: [
                    const SizedBox(width: 5),
                    const Text(
                      'SCORE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 25),
                    Text(
                      '$totalScore',
                      key: scoreGlobalKey,
                      style: const TextStyle(
                        color: Color(0xFF03DAC6),
                        fontSize: 40,
                      ),
                    ),
                    const Spacer(),
                    const Text(
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
                          Icons.favorite,
                          color: i < lives ? Colors.white : Colors.transparent,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 80, right: 80),
                child: Row(
                  children: [
                    const Text(
                      'BONUS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      '$bonusCountdown',
                      style: const TextStyle(
                        color: Color(0xFF03DAC6),
                        fontSize: 40,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 4),
              SizedBox(
                height: gridHeight.toDouble(),
                width: gridHeight.toDouble(),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: gridSize,
                  children: [
                    for (int i = 0; i < gridSize * gridSize; i++)
                      Container(
                        key: tileKeys[i],
                        margin: const EdgeInsets.all(6),
                        child: FlipTile(
                          key: ValueKey('tile_$i'),
                          isHovered:
                              mouseX == i % gridSize && mouseY == i ~/ gridSize,
                          isRevealed: getTileRevealed(i),
                          onTap: tileIsTappable(i) ? () => chooseTile(i) : null,
                          frontColor: wrongGuessPositions.contains(i)
                              ? Colors.lightBlue.shade900
                              : Colors.blue,
                          backColor: gameState == GameState.lost
                              ? Colors.red
                              : const Color(0xFF03DAC6),
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(flex: 6),
            ],
          ),
        ),
      ),
    );
  }
}
