import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:human_benchmark/data/model/chimp_test_result.dart';
import 'package:human_benchmark/data/cubit/game_result/game_result_cubit.dart';

class ChimpTestPage extends StatefulWidget {
  const ChimpTestPage({super.key});

  @override
  State<ChimpTestPage> createState() => _ChimpTestPageState();
}

class _ChimpTestPageState extends State<ChimpTestPage> {
  int lives = 3;
  int sequenceLength = 1;
  int mouseX = 0;
  int mouseY = 0;
  double cursorXValue = 0;
  double cursorYValue = 0;
  double cursorX = 0;
  double cursorY = 0;
  double sensitivity = 15.0;
  double cursorDiameter = 40;
  Timer? cursorTimer;
  StreamSubscription<GamepadEvent>? gamepadSubscription;
  static const int gridHeight = 600;

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

        cursorX = clampDouble(
          cursorX,
          cursorDiameter / 2,
          gridHeight - cursorDiameter / 2,
        );
        cursorY = clampDouble(
          cursorY,
          cursorDiameter / 2,
          gridHeight - cursorDiameter / 2,
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
          // averageMovement = Offset(
          //   sumX / recentMovements.length,
          //   sumY / recentMovements.length,
          // );
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

  int calculateGridSize() {
    if (sequenceLength < 5) return 4;
    if (sequenceLength < 7) return 5;
    if (sequenceLength < 10) return 6;
    if (sequenceLength < 15) return 7;
    return 7;
  }

  int get gridSize => calculateGridSize();

  List<int> sequencePositions = [];
  int correct = 0;
  final int firstHiddenSequenceLength = 1;

  void passLevel() {
    sequenceLength++;
    newLevel();
  }

  void endGame() {
    GetIt.I<GameResultCubit>().chimpTestOver(
      ChimpTestResult(sequenceLength: sequenceLength - 1),
    );
    context.go('/');
  }

  void failLevel() {
    lives--;
    if (lives <= 0) {
      endGame();
      return;
    }
    newLevel();
  }

  void setMouseToIdx(int idx) {
    int x = idx % gridSize;
    int y = idx ~/ gridSize;

    setState(() {
      mouseX = x;
      mouseY = y;
    });
  }

  void newLevel() {
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
    setMouseToIdx(sequencePositions[0]);
    setCursorPos(
      getTileX(sequencePositions[0]),
      getTileY(sequencePositions[0]),
    );
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
    gamepadSubscription = Gamepads.events.listen(handleGamepadEvent);
    startMovementTimer();
    newLevel();
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
    // int tileIdx = mouseX + mouseY * gridSize;
    // if (!sequencePositions.contains(tileIdx)) return;
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

  // void changeMousePos(int dX, int dY) {
  //   if (dX != 0) {
  //     int nextXTile = findNextColumnTile(mouseX, mouseY, dX);
  //     if (nextXTile != -1) {
  //       setState(() {
  //         mouseX = getXPosFromTileIdx(nextXTile);
  //         mouseY = getYPosFromTileIdx(nextXTile);
  //       });
  //     }
  //   } else if (dY != 0) {
  //     int nextYTile = findNextRowTile(mouseX, mouseY, dY);
  //     if (nextYTile != -1) {
  //       setState(() {
  //         mouseX = getXPosFromTileIdx(nextYTile);
  //         mouseY = getYPosFromTileIdx(nextYTile);
  //       });
  //     }
  //   }
  // }
  void changeMousePos(int dX, int dY) {
    setState(() {
      mouseX += dX;
      mouseY += dY;
    });
  }

  // Initialize the game with a new level
  void handleGamepadEvent(GamepadEvent event) {
    if (event.type == KeyType.button) {
      if (event.key == 'y.circle') {
        if (event.value == 0) {
          confirmTile();
        }
      }
    }
    if (event.type == KeyType.analog) {
      if (event.key == 'l.joystick - yAxis') {
        cursorYValue = event.value;
        // if (event.value <= -.95) {
        //   changeMousePos(0, -1);
        // } else if (event.value >= .95) {
        //   changeMousePos(0, 1);
        // }
      } else if (event.key == 'l.joystick - xAxis') {
        cursorXValue = event.value;
        // if (event.value <= -.95) {
        //   changeMousePos(1, 0);
        // } else if (event.value >= .95) {
        //   changeMousePos(-1, 0);
        // }
      }
    }
  }

  void selectTile(int pos) {
    if (sequencePositions[correct] == pos) {
      setState(() {
        correct++;
        if (correct == sequenceLength) {
          passLevel();
        }
      });
    } else {
      if (correct > 0) {
        // dont fail if click wrong tile first
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

    // Offset clampedAverageMovement = clampOffset(averageMovement, 200.0);

    // final removedVelocityX = centerX - averageMovement.dx;
    // final removedVelocityY = centerY - averageMovement.dy;
    // final removedVelocityX = centerX - clampedAverageMovement.dx;
    // final removedVelocityY = centerY - clampedAverageMovement.dy;

    return sqrt(pow(centerX - cursorX, 2) + pow(centerY - cursorY, 2));
    // return sqrt(
    //   pow(removedVelocityX - cursorX, 2) + pow(removedVelocityY - cursorY, 2),
    // );
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
    return getHoveredTile() == idx;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('chimp game'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < lives; i++)
                  Icon(Icons.favorite, color: Colors.red, size: 30),
              ],
            ),
            Stack(
              children: [
                Container(
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
                            margin: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: isHovered(i)
                                  ? Border.all(
                                      color: Colors.black,
                                      width: 4,
                                    )
                                  : null,
                              color: sequencePositions.contains(i)
                                  ? (correct <= sequencePositions.indexOf(i)
                                        ? Colors.red
                                        : Colors.green)
                                  : Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                '${sequencePositions.contains(i) && (correct == 0 || sequenceLength <= firstHiddenSequenceLength) ? sequencePositions.indexOf(i) + 1 : ''}',
                                style: TextStyle(
                                  color: sequencePositions.contains(i)
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Positioned(
                //   left:
                //       (cursorX -
                //           cursorDiameter / 2 +
                //           // normalizeOffset(averageMovement, 100).dx) +
                //           clampOffset(averageMovement, 200.0).dx) +
                //       cursorDiameter / 4,
                //   top:
                //       (cursorY -
                //           cursorDiameter / 2 +
                //           // normalizeOffset(averageMovement, 100).dy) +
                //           clampOffset(averageMovement, 200.0).dy) +
                //       cursorDiameter / 4,
                //   child: Container(
                //     height: cursorDiameter / 2,
                //     width: cursorDiameter / 2,
                //     decoration: BoxDecoration(
                //       color: Colors.red.withValues(alpha: .4),
                //       borderRadius: BorderRadius.circular(100),
                //     ),
                //   ),
                // ),
                Positioned(
                  left: cursorX - cursorDiameter / 2,
                  top: cursorY - cursorDiameter / 2,
                  child: Container(
                    height: cursorDiameter,
                    width: cursorDiameter,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: .4),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
