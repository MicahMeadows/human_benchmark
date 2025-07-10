import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:human_benchmark/data/cubit/records/records_cubit.dart';
import 'package:human_benchmark/data/model/chimp_test_result.dart';
import 'package:human_benchmark/data/cubit/game_result/game_result_cubit.dart';
import 'package:just_audio/just_audio.dart';

class ChimpTestPage extends StatefulWidget {
  const ChimpTestPage({super.key});

  @override
  State<ChimpTestPage> createState() => _ChimpTestPageState();
}

class _ChimpTestPageState extends State<ChimpTestPage> {
  List<OverlayEntry> overlayEntries = [];
  List<GlobalKey> tileKeys = [];
  GlobalKey scoreGlobalKey = GlobalKey();
  GlobalKey cursorGlobalKey = GlobalKey();
  List<GlobalKey> heartKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  int wrongTileIdx = -1;
  int totalScore = 0;
  int totalBonusPoints = 0;
  int countdownValue = 10;
  int bonusCountdown = 1000;
  bool isCountingDown = false;
  Timer? countdownTimer;

  bool canClick = true;
  final clickPlayer = AudioPlayer();
  final levelWinPlayer = AudioPlayer();
  final buzzPlayer = AudioPlayer();
  int lastSelectionTime = 0;
  int calculateGridHeight() {
    if (sequenceLength < 5) return 500;
    if (sequenceLength < 7) return 600;
    if (sequenceLength < 11) return 800;
    if (sequenceLength < 15) return 800;
    return 800;
  }

  int get gridHeight => calculateGridHeight();

  int calculateGridSize() {
    if (sequenceLength < 5) return 3;
    if (sequenceLength < 7) return 4;
    if (sequenceLength < 11) return 5;
    if (sequenceLength < 15) return 6;
    return 6;
  }

  int get gridSize => calculateGridSize();
  Duration selectionDelay = Duration(milliseconds: 100);
  int lives = 3;
  int progress = 0;
  int sequenceLength = 1;
  static const double cursorDiameter = 40;
  late double cursorX = (gridHeight / 2) - (cursorDiameter / 2);
  late double cursorY = (gridHeight / 2) + (cursorDiameter / 2);
  double cursorXValue = 0;
  double cursorYValue = 0;
  double sensitivity = 25.0;
  Timer? cursorTimer;
  StreamSubscription<GamepadEvent>? gamepadSubscription;

  // Last non-zero joystick direction for filtering tiles
  double lastDirX = 0;
  double lastDirY = 0;

  Queue<Offset> recentMovements = Queue<Offset>();
  Offset averageMovement = Offset.zero;

  Offset normalizeOffset(Offset offset, double len) {
    double magnitude = offset.distance;
    if (magnitude < 0.1) return Offset.zero; // Ignore very small movements
    return offset * (len / magnitude);
  }

  Offset clampOffset(Offset offset, double max) {
    return Offset(
      clampDouble(offset.dx, -max, max),
      clampDouble(offset.dy, -max, max),
    );
  }

  void startMovementTimer() {
    cursorTimer?.cancel();
    cursorTimer = Timer.periodic(Duration(milliseconds: 10), (timer) {
      setState(() {
        bool isDiagonal = cursorXValue.abs() > 0.1 && cursorYValue.abs() > 0.1;
        double deltaX =
            -(cursorXValue * sensitivity) * (isDiagonal ? 0.707 : 1);
        double deltaY = (cursorYValue * sensitivity) * (isDiagonal ? 0.707 : 1);

        cursorX += deltaX;
        cursorY += deltaY;

        int cursorOutOfBoundAmnt = 100;

        cursorX = clampDouble(
          cursorX,
          cursorDiameter / 2 - 100,
          gridHeight - cursorDiameter / 2 + 100,
        );
        cursorY = clampDouble(
          cursorY,
          cursorDiameter / 2 - 100,
          gridHeight - cursorDiameter / 2 + 100,
        );

        if (deltaY.abs() > 0.1 || deltaX.abs() > 0.1) {
          recentMovements.add(Offset(deltaX, deltaY));
        }

        if (recentMovements.length > 20) {
          recentMovements.removeFirst();
        }

        if (recentMovements.isNotEmpty) {
          // Calculate average movement vector
          double sumX = 0;
          double sumY = 0;
          for (final movement in recentMovements) {
            sumX += movement.dx;
            sumY += movement.dy;
          }

          averageMovement = Offset(
            sumX,
            sumY,
          );
        }
      });
    });
  }

  void stopMovementTimer() {
    cursorTimer?.cancel();
    cursorTimer = null;
  }

  List<int> sequencePositions = [];
  int correct = 0;
  final int firstHiddenSequenceLength = 1;

  void playLevelCompleteSound() async {
    clickPlayer.stop();
    await clickPlayer.seek(Duration.zero);
    await clickPlayer.play();
    await clickPlayer.stop();
  }

  void playCorrectChoiceSound() async {
    levelWinPlayer.stop();
    await levelWinPlayer.seek(Duration.zero);
    await levelWinPlayer.play();
    await levelWinPlayer.stop();
  }

  void playBuzzSound() async {
    buzzPlayer.stop();
    await buzzPlayer.seek(Duration.zero);
    await buzzPlayer.play();
    await buzzPlayer.stop();
  }

  void passLevel() {
    countdownTimer?.cancel();
    // Animate life return from the last selected tile to the heart position
    if (correct > 0) {
      int lastTileIdx = sequencePositions[correct - 1];
      int heartIdx = lives; // the heart index to fill next (0-based)

      if (lives < 3) {
        animateLifeReturnFromTileToHeart(lastTileIdx, heartIdx - 1);
      }
    } else {
      // fallback if no last tile
      setState(() {
        lives = min(3, lives + 1);
        isCountingDown = false;
      });
    }

    progress++;
    if (sequenceLength < 3 || progress >= 3) {
      progress = 0;
      newLevel(1);
    } else {
      newLevel(0);
    }
  }

  void endGame() {
    countdownTimer?.cancel();
    setState(() {
      isCountingDown = false;
    });
    GetIt.I<GameResultCubit>().chimpTestOver(
      ChimpTestResult(highScore: sequenceLength - 1),
    );
    GetIt.I<RecordsCubit>().saveChimpGameResult(
      ChimpTestResult(highScore: totalScore),
    );
    context.go('/');
  }

  void failLevel() {
    countdownTimer?.cancel();
    if (lives > 0) {
      animateLostHeart(lives - 1);
    }

    setState(() {
      isCountingDown = false;
      lives--;
    });

    if (lives <= 0) {
      endGame();
      return;
    }
    newLevel(0);
  }

  Future<void> gracePeriod(int ms) async {
    canClick = false;
    await Future.delayed(Duration(milliseconds: ms));
    canClick = true;
  }

  void startBonusCountdown() {
    bonusCountdown = 1000;
    isCountingDown = true;

    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (bonusCountdown <= 0) {
        bonusCountdown = 0;
        timer.cancel();
      } else {
        setState(() {
          bonusCountdown -= 10;
        });
      }
    });
  }

  void newLevel(int sequenceChange) async {
    await gracePeriod(1000);
    setState(() {
      wrongTileIdx = -1;
    });
    sequenceLength += sequenceChange;

    tileKeys.clear();
    for (int i = 0; i < gridSize * gridSize; i++) {
      tileKeys.add(GlobalKey());
    }

    averageMovement = Offset.zero;
    recentMovements.clear();
    correct = 0;
    Set<int> availablePositions = {};
    for (int i = 0; i < gridSize * gridSize; i++) {
      availablePositions.add(i);
    }
    List<int> newSequencePositions = [];
    for (int i = 0; i < sequenceLength; i++) {
      int randomIndex = Random().nextInt(availablePositions.length);
      int pos = availablePositions.elementAt(randomIndex);
      availablePositions.remove(pos);
      newSequencePositions.add(pos);
    }
    setState(() {
      sequencePositions = newSequencePositions;
    });
    setCursorPos(
      getTileX(sequencePositions[0]),
      getTileY(sequencePositions[0]),
    );
    await gracePeriod(100);
    startBonusCountdown();
  }

  @override
  void dispose() {
    super.dispose();
    stopMovementTimer();
    gamepadSubscription?.cancel();
  }

  @override
  void initState() {
    super.initState();
    clickPlayer.setAsset('assets/audio/click-click.wav');
    levelWinPlayer.setAsset('assets/audio/click2.wav');
    buzzPlayer.setAsset('assets/audio/buzz.wav');
    gamepadSubscription = Gamepads.events.listen(handleGamepadEvent);
    startMovementTimer();
    newLevel(0);
  }

  void setCursorPos(double x, double y) {
    setState(() {
      cursorX = clampDouble(
        x,
        cursorDiameter / 2,
        gridHeight - cursorDiameter / 2,
      );
      cursorY = clampDouble(
        y,
        cursorDiameter / 2,
        gridHeight - cursorDiameter / 2,
      );
    });
  }

  void confirmTile() {
    if (!canClick) return;

    final tileIdx = getHoveredTile();
    if (tileIdx == null || !sequencePositions.contains(tileIdx)) return;

    selectTile(tileIdx);
  }

  void moveCursorToTileCenter(int tileIdx) {
    double tileX = getTileX(tileIdx);
    double tileY = getTileY(tileIdx);
    setCursorPos(tileX, tileY);
  }

  int getXPosFromTileIdx(int tileIdx) {
    return tileIdx % gridSize;
  }

  int getYPosFromTileIdx(int tileIdx) {
    return tileIdx ~/ gridSize;
  }

  int findNextColumnTile(int x, int y, int dir) {
    int newX = x + dir;
    if (newX < 0 || newX >= gridSize) {
      return -1;
    }

    int topIdx = y;
    int botIdx = y;

    while (topIdx >= 0 || botIdx < gridSize) {
      if (topIdx >= 0) {
        int topTileIdx = newX + topIdx * gridSize;
        if (sequencePositions.contains(topTileIdx)) {
          if (correct <= sequencePositions.indexOf(topTileIdx)) {
            return topTileIdx;
          }
        }
        topIdx--;
      }
      if (botIdx < gridSize) {
        int botTileIdx = newX + botIdx * gridSize;
        if (sequencePositions.contains(botTileIdx)) {
          if (correct <= sequencePositions.indexOf(botTileIdx)) {
            return botTileIdx;
          }
        }
        botIdx++;
      }
    }

    return findNextColumnTile(x + dir, y, dir);
  }

  int findNextRowTile(int x, int y, int dir) {
    int newY = y + dir;
    if (newY < 0 || newY >= gridSize) {
      return -1;
    }

    int leftIdx = x;
    int rightIdx = x;

    while (leftIdx >= 0 || rightIdx < gridSize) {
      if (leftIdx >= 0) {
        int leftTileIdx = leftIdx + newY * gridSize;
        if (sequencePositions.contains(leftTileIdx)) {
          if (correct <= sequencePositions.indexOf(leftTileIdx)) {
            return leftTileIdx;
          }
        }
        leftIdx--;
      }
      if (rightIdx < gridSize) {
        int rightTileIdx = rightIdx + newY * gridSize;
        if (sequencePositions.contains(rightTileIdx)) {
          if (correct <= sequencePositions.indexOf(rightTileIdx)) {
            return rightTileIdx;
          }
        }
        rightIdx++;
      }
    }

    return findNextRowTile(x, y + dir, dir);
  }

  // Initialize the game with a new level
  void handleGamepadEvent(GamepadEvent event) {
    if (event.type == KeyType.button) {
      // print('type: ${event.type}, key: ${event.key}, value: ${event.value}');
      if (['y.circle', 'l1.rectangle.roundedbottom'].contains(event.key)) {
        // if (event.key == 'y.circle') {
        if (event.value == 0) {
          confirmTile();
        }
      }
    }
    if (event.type == KeyType.analog) {
      if (event.key == 'l.joystick - yAxis') {
        cursorYValue = event.value;
      } else if (event.key == 'l.joystick - xAxis') {
        cursorXValue = event.value;
      }
    }
  }

  void animatePointLoss({
    required Offset startOffset,
    required int points,
  }) {
    final duration = Duration(milliseconds: 800);
    final overlay = Overlay.of(context);

    final random = Random();
    final horizontalJitter = random.nextDouble() * 60 - 30; // -30 to +30 px
    final dropDistance = 80 + random.nextDouble() * 40; // 80–120 px drop

    final entry = OverlayEntry(
      builder: (ctx) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: duration,
        curve: Curves.easeIn,
        builder: (context, t, child) {
          final dx = startOffset.dx + horizontalJitter * t;
          final dy = startOffset.dy + dropDistance * t;
          final opacity = 1.0 - t;

          return Positioned(
            left: dx,
            top: dy,
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: 1.0 - 0.2 * t,
                child: child,
              ),
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: Text(
            '-$points',
            style: const TextStyle(
              fontSize: 32,
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(duration, () => entry.remove());
  }

  void animateLifeReturnFromTileToHeart(int tileIdx, int heartIdx) {
    // final tileContext = tileKeys[tileIdx].currentContext;
    final tileContext = cursorGlobalKey.currentContext;
    final heartContext = heartKeys[heartIdx].currentContext;

    if (tileContext == null || heartContext == null) return;

    final tileBox = tileContext.findRenderObject() as RenderBox;
    final heartBox = heartContext.findRenderObject() as RenderBox;

    final startOffset = tileBox.localToGlobal(
      Offset(
        tileBox.size.width / 2 - (cursorDiameter / 2),
        tileBox.size.height / 2 - (cursorDiameter / 2),
      ),
    );
    final endOffset = heartBox.localToGlobal(
      Offset(heartBox.size.width / 2, heartBox.size.height / 2),
    );

    final overlay = Overlay.of(context);
    final duration = Duration(milliseconds: 800);

    final random = Random();
    final endRotationDegrees =
        (5 + random.nextDouble() * 20) * (random.nextBool() ? 1 : -1);
    final endRotationRadians = endRotationDegrees * (pi / 180);

    final entry = OverlayEntry(
      builder: (ctx) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        curve: Curves.easeInOut,
        duration: duration,
        builder: (context, t, child) {
          final rotation = lerpDouble(endRotationRadians, 0, t)!;

          // Linear interpolate position between start and end:
          final pos = Offset.lerp(startOffset, endOffset, t)!;

          return Positioned(
            top: pos.dy,
            left: pos.dx,
            child: Transform.rotate(
              angle: rotation,
              child: child,
            ),
          );
        },
        child: Icon(
          Icons.favorite,
          color: Colors.white,
          size: 40,
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(duration, () {
      entry.remove();

      // After animation ends, add life back
      setState(() {
        lives = min(3, lives + 1);
      });
    });
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

  void animateScoreFrom({
    required Offset startOffset,
    required Offset endOffset,
    required int score,
  }) {
    final duration = Duration(milliseconds: Random().nextInt(400) + 400);
    final overlay = Overlay.of(context);

    // Pick a control point above the mid-point to create an arc
    final midPoint = Offset.lerp(startOffset, endOffset, 0.5)!;

    final arcHeight = 100 + Random().nextDouble() * 100; // vertical curve
    final arcDirection = (Random().nextBool() ? 1 : -1); // left or right
    final arcWidth = Random().nextDouble() * 100 * arcDirection;

    final controlOffset = midPoint + Offset(arcWidth, -arcHeight);

    final curveOptions = [
      Curves.easeInOut,
      Curves.easeOutBack,
      Curves.fastOutSlowIn,
      Curves.decelerate,
    ];
    final randomCurve = curveOptions[Random().nextInt(curveOptions.length)];

    final randomScaleStart = Random().nextDouble() * 0.1 + 0.5; // 0.5–0.6
    final randomScaleEnd = Random().nextDouble() * 0.5 + 1.0; // 1.0–1.5

    Offset getQuadraticBezierPoint(double t, Offset p0, Offset p1, Offset p2) {
      final oneMinusT = 1 - t;
      final x =
          oneMinusT * oneMinusT * p0.dx +
          2 * oneMinusT * t * p1.dx +
          t * t * p2.dx;
      final y =
          oneMinusT * oneMinusT * p0.dy +
          2 * oneMinusT * t * p1.dy +
          t * t * p2.dy;
      return Offset(x, y);
    }

    final entry = OverlayEntry(
      builder: (ctx) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: duration,
          curve: randomCurve,
          builder: (context, t, child) {
            final curvedOffset = getQuadraticBezierPoint(
              t,
              startOffset,
              controlOffset,
              endOffset,
            );
            final scale = lerpDouble(randomScaleStart, randomScaleEnd, t)!;

            return Positioned(
              top: curvedOffset.dy,
              left: curvedOffset.dx,
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            );
          },
          child: Material(
            color: Colors.transparent,
            child: Text(
              '+$score',
              style: const TextStyle(
                fontSize: 32,
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);

    Future.delayed(duration, () => entry.remove());
  }

  void animateScore(int pos, int score) {
    final key = tileKeys[pos];
    final context = key.currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox;
      final offset = box.localToGlobal(Offset.zero);

      final scoreContext = scoreGlobalKey.currentContext;
      if (scoreContext != null) {
        final scoreBox = scoreContext.findRenderObject() as RenderBox;
        final scoreOffset = scoreBox.localToGlobal(Offset.zero);
        // Use the score offset as the end position
        animateScoreFrom(
          startOffset: offset,
          endOffset: scoreOffset,
          score: score,
        );
      }
    }
  }

  void addScore(int score) {
    setState(() {
      totalScore += score;
    });
  }

  void removeScore(int score) {
    setState(() {
      totalScore = max(0, totalScore - score);
    });

    final context = scoreGlobalKey.currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox;
      final offset = box.localToGlobal(Offset.zero);
      animatePointLoss(startOffset: offset, points: score);
    }
  }

  void selectTile(int pos) {
    if (DateTime.now().millisecondsSinceEpoch - lastSelectionTime <
        selectionDelay.inMilliseconds) {
      return;
    }
    lastSelectionTime = DateTime.now().millisecondsSinceEpoch;
    if (!canClick) return;

    if (sequencePositions[correct] == pos) {
      // Get screen position

      setState(() {
        correct++;
        if (correct == sequenceLength) {
          print('correct: $correct, sequenceLength: $sequenceLength');
          addScore(100 + bonusCountdown);
          animateScore(pos, 100 + bonusCountdown);
          playLevelCompleteSound();
          passLevel();
        } else {
          addScore(100);
          animateScore(pos, 100);
          playCorrectChoiceSound();
        }
      });
    } else {
      if (correct > 0) {
        setState(() {
          wrongTileIdx = pos;
        });
        removeScore(correct * 100);
        playBuzzSound();
        failLevel();
      }
    }
  }

  double getTileX(int tileIdx) {
    return (tileIdx % gridSize) * (gridHeight / gridSize) +
        (gridHeight / gridSize) / 2;
  }

  double getTileY(int tileIdx) {
    return (tileIdx ~/ gridSize) * (gridHeight / gridSize) +
        (gridHeight / gridSize) / 2;
  }

  double distanceFromCursor(int tileIdx) {
    var centerX = getTileX(tileIdx);
    var centerY = getTileY(tileIdx);

    return sqrt(
      pow(centerX - cursorX, 2) + pow(centerY - cursorY, 2),
    );
  }

  int? getHoveredTile() {
    int? closestTileIdx;

    for (int i = 0; i < gridSize * gridSize; i++) {
      if (!sequencePositions.contains(i)) continue;
      if (correct > sequencePositions.indexOf(i)) continue;
      double distance = distanceFromCursor(i);
      if (closestTileIdx == null ||
          distance < distanceFromCursor(closestTileIdx)) {
        closestTileIdx = i;
      }
    }

    return closestTileIdx;
  }

  bool isHovered(int idx) {
    if (!canClick) return false;
    if (getHoveredTile() == idx) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          // color: Colors.black,
          color: Color(0xFF121212),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
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
                        color: Color(0xFF03DAC6),
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
              ),
              Container(
                margin: EdgeInsets.only(left: 80, right: 80),
                child: Row(
                  children: [
                    Text(
                      'BONUS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(
                      '$bonusCountdown',
                      style: TextStyle(
                        color: Color(0xFF03DAC6),
                        fontSize: 40,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(flex: 4),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(),
                    height: gridHeight.toDouble(),
                    width: gridHeight.toDouble(),
                    child: GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: gridSize,
                      children: [
                        for (int i = 0; i < gridSize * gridSize; i++)
                          InkWell(
                            onTap:
                                !sequencePositions.contains(i) ||
                                    correct > sequencePositions.indexOf(i)
                                ? null
                                : () {
                                    selectTile(i);
                                  },
                            child: Container(
                              key: tileKeys.length > i ? tileKeys[i] : null,
                              margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: isHovered(i)
                                    ? Border.all(
                                        // color: Colors.black,
                                        color: Colors.white.withValues(
                                          alpha: .8,
                                        ),
                                        width: 6,
                                      )
                                    : null,
                                color: wrongTileIdx == i
                                    ? Color(0xFFCF6679)
                                    : sequencePositions.contains(i)
                                    ? (correct <= sequencePositions.indexOf(i)
                                          ? Colors.lightBlue
                                          // : Colors.green)
                                          : Color(0xFF03DAC6))
                                    : Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  '${sequencePositions.contains(i) && (correct == 0 || sequenceLength <= firstHiddenSequenceLength) ? sequencePositions.indexOf(i) + 1 : ''}',
                                  style: TextStyle(
                                    // color: sequencePositions.contains(i)
                                    //     ? Colors.black
                                    //     : Colors.white,
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Positioned(
                    key: cursorGlobalKey,
                    left: cursorX - cursorDiameter / 2,
                    top: cursorY - cursorDiameter / 2,
                    child: Container(
                      height: cursorDiameter,
                      width: cursorDiameter,
                      decoration: BoxDecoration(
                        // color: Colors.blue.withValues(alpha: .4),
                        color: Colors.white.withValues(alpha: .4),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(flex: 6),
            ],
          ),
        ),
      ),
    );
  }
}
