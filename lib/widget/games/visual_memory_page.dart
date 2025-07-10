import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:human_benchmark/data/cubit/game_result/game_result_cubit.dart';
import 'package:human_benchmark/data/cubit/records/records_cubit.dart';
import 'package:human_benchmark/data/model/visual_memory_test_result.dart';
import 'package:human_benchmark/widget/flip_tile.dart';
import 'package:just_audio/just_audio.dart';

class VisualMemoryPage extends StatefulWidget {
  const VisualMemoryPage({super.key});

  @override
  State<VisualMemoryPage> createState() => _VisualMemoryPageState();
}

enum GameState {
  notStarted,
  preview,
  playing,
  finished,
  lost,
}

class _VisualMemoryPageState extends State<VisualMemoryPage> {
  int calculateGridHeight() {
    // if (sequenceLength < 5) return 500;
    // if (sequenceLength < 7) return 600;
    // if (sequenceLength < 11) return 800;
    // if (sequenceLength < 15) return 800;
    // return 800;
    return 800;
  }

  int get gridHeight => calculateGridHeight();
  int calculateGridSize() {
    if (sequenceLength < 5) return 3;
    if (sequenceLength < 9) return 4;
    if (sequenceLength < 12) return 5;
    if (sequenceLength < 17) return 6;
    return 7;
  }

  final clickPlayer = AudioPlayer();
  final levelWinPlayer = AudioPlayer();
  final buzzPlayer = AudioPlayer();
  StreamSubscription<GamepadEvent>? gamepadSubscription;

  int get gridSize => calculateGridSize();
  int sequenceLength = 3;
  int lives = 3;
  int levelLives = 3;
  Set<int> availablePositions = {};
  Set<int> hiddenPositions = {};
  Set<int> correctPositions = {};
  Set<int> wrongGuessPositions = {};
  GameState gameState = GameState.notStarted;
  int mouseX = 0;
  int mouseY = 0;

  bool getTileRevealed(int index) {
    return (gameState == GameState.preview &&
            hiddenPositions.contains(index)) ||
        correctPositions.contains(index) ||
        gameState == GameState.finished ||
        gameState == GameState.lost;
  }

  @override
  void dispose() {
    gamepadSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    clickPlayer.setAsset('assets/audio/click-click.wav');
    levelWinPlayer.setAsset('assets/audio/click2.wav');
    buzzPlayer.setAsset('assets/audio/buzz.wav');

    gamepadSubscription = Gamepads.events.listen(handleGamepadEvent);

    startLevel();
    super.initState();
  }

  void changeMousePos(int dX, int dY) {
    setState(() {
      mouseX = mouseX + dX;
      mouseY = mouseY + dY;

      if (mouseX < 0) {
        mouseX = gridSize - 1;
      } else if (mouseX >= gridSize) {
        mouseX = 0;
      }
      if (mouseY < 0) {
        mouseY = gridSize - 1;
      } else if (mouseY >= gridSize) {
        mouseY = 0;
      }
    });
  }

  void handleGamepadEvent(GamepadEvent event) {
    // print('type: ${event.type}, key: ${event.key}, value: ${event.value}');
    if (event.type == KeyType.button) {
      if (['y.circle', 'l1.rectangle.roundedbottom'].contains(event.key)) {
        // if (event.key == 'y.circle') {
        if (event.value == 0) {
          confirmTile();
        }
      }
    }
    if (event.type == KeyType.analog) {
      if (event.key == 'l.joystick - yAxis') {
        if (event.value <= -.95) {
          changeMousePos(0, -1);
        } else if (event.value >= .95) {
          changeMousePos(0, 1);
        }
      } else if (event.key == 'l.joystick - xAxis') {
        if (event.value <= -.95) {
          changeMousePos(1, 0);
        } else if (event.value >= .95) {
          changeMousePos(-1, 0);
        }
      }
    }
  }

  void confirmTile() {
    final int tileIdx = mouseX + (mouseY * gridSize);
    if (tileIsTappable(tileIdx)) {
      chooseTile(tileIdx);
    }
  }

  Future<void> startLevel() async {
    levelLives = 3;
    availablePositions = {};
    hiddenPositions = {};
    correctPositions = {};
    wrongGuessPositions = {};
    for (int i = 0; i < gridSize * gridSize; i++) {
      availablePositions.add(i);
    }
    for (int i = 0; i < sequenceLength; i++) {
      int randomAvailableTile = Random().nextInt(availablePositions.length);
      int element = availablePositions.elementAt(randomAvailableTile);
      availablePositions.remove(element);
      hiddenPositions.add(element);
    }
    gameState = GameState.notStarted;

    await Future.delayed(Duration(seconds: 2));
    setState(() {});

    gameState = GameState.preview;

    setState(() {});

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      gameState = GameState.playing;
    });
  }

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

  void winLevel() async {
    playLevelCompleteSound();

    setState(() {
      gameState = GameState.finished;
    });
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      sequenceLength++;
    });
    await startLevel();
  }

  void handleCorrectTile(int idx) {
    if (gameState != GameState.playing) {
      return; // avoid double win or win during other states
    }
    setState(() {
      hiddenPositions.remove(idx);
      correctPositions.add(idx);
    });
    if (hiddenPositions.isEmpty) {
      winLevel();
    } else {
      playCorrectChoiceSound();
    }
  }

  void handleGameLose() async {
    setState(() {
      gameState = GameState.lost;
    });
    await Future.delayed(Duration(seconds: 2));
    if (context.mounted) {
      GetIt.I<GameResultCubit>().visualMemoryTestOver(
        VisualMemoryTestResult(tileCount: sequenceLength - 1),
      );
      GetIt.I<RecordsCubit>().saveVisualMemoryGameResult(
        VisualMemoryTestResult(tileCount: sequenceLength - 1),
      );
      // ignore: use_build_context_synchronously
      context.go('/');
    }
  }

  bool tileIsTappable(int idx) {
    if (gameState != GameState.playing) {
      return false;
    }
    if (correctPositions.contains(idx)) {
      return false;
    }
    if (wrongGuessPositions.contains(idx)) {
      return false;
    }
    return true;
  }

  void handleIncorrectTile(int idx) async {
    if (wrongGuessPositions.contains(idx)) return;
    playBuzzSound();
    wrongGuessPositions.add(idx);
    setState(() {
      levelLives--;
    });
    if (levelLives <= 0) {
      setState(() {
        lives--;

        gameState = GameState.lost;
      });

      if (lives <= 0) {
        handleGameLose();
      } else {
        await Future.delayed(Duration(seconds: 2));
        await startLevel();
      }
    }
  }

  void chooseTile(int idx) {
    if (hiddenPositions.contains(idx)) {
      handleCorrectTile(idx);
    } else {
      handleIncorrectTile(idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < lives; i++)
                    Icon(Icons.favorite, color: Colors.red, size: 30),
                  if (lives <= 0)
                    Icon(Icons.favorite, color: Colors.transparent, size: 30),
                ],
              ),
              Spacer(),
              Container(
                height: gridHeight.toDouble(),
                width: gridHeight.toDouble(),
                child: GridView.count(
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: gridSize,
                  children: [
                    for (int i = 0; i < gridSize * gridSize; i++)
                      FlipTile(
                        isHovered: () {
                          var x = i % gridSize;
                          var y = (i / gridSize).floor();
                          // if (gameState == GameState.playing) {
                          if (mouseX == x && mouseY == y) {
                            return true;
                          }
                          // }

                          return false;
                        }(),
                        key: ValueKey('${i}}'),
                        isRevealed: getTileRevealed(i),
                        onTap: tileIsTappable(i) == false
                            ? null
                            : () => chooseTile(i),
                        frontColor: wrongGuessPositions.contains(i)
                            ? Colors.lightBlue.shade900
                            : Colors.blue,
                        backColor: gameState == GameState.lost
                            ? Colors.red
                            : Colors.green,
                      ),
                  ],
                ),
              ),
              Spacer(),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
