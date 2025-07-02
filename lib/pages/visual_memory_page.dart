import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  int calculateGridSize() {
    if (tileCount < 5) return 3;
    if (tileCount < 7) return 4;
    if (tileCount < 10) return 5;
    if (tileCount < 15) return 6;
    return 7;
  }

  int get gridSize => calculateGridSize();
  int tileCount = 3;
  int lives = 3;
  int levelLives = 3;
  Set<int> availablePositions = {};
  Set<int> hiddenPositions = {};
  Set<int> correctPositions = {};
  GameState gameState = GameState.notStarted;

  Color getTileColor(int index) {
    if (gameState == GameState.lost) {
      return Colors.red;
    } else if (gameState == GameState.finished) {
      return Colors.green;
    } else if ((gameState == GameState.preview &&
            hiddenPositions.contains(index)) ||
        correctPositions.contains(index)) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  @override
  void initState() {
    startLevel();
    super.initState();
  }

  void startLevel() async {
    levelLives = 3;
    setState(() {
      availablePositions = {};
      hiddenPositions = {};
      correctPositions = {};
      for (int i = 0; i < gridSize * gridSize; i++) {
        availablePositions.add(i);
      }
      for (int i = 0; i < tileCount; i++) {
        int randomAvailableTile = Random().nextInt(availablePositions.length);
        int element = availablePositions.elementAt(randomAvailableTile);
        availablePositions.remove(element);
        hiddenPositions.add(element);
      }
      gameState = GameState.preview;
    });

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      gameState = GameState.playing;
    });
  }

  void winLevel() async {
    setState(() {
      gameState = GameState.finished;
    });
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      tileCount++;
      startLevel();
    });
  }

  void handleCorrectTile(int idx) {
    setState(() {
      hiddenPositions.remove(idx);
      correctPositions.add(idx);
    });
    if (hiddenPositions.isEmpty) {
      winLevel();
    }
  }

  void handleGameLose() async {
    setState(() {
      gameState = GameState.lost;
    });
    await Future.delayed(Duration(seconds: 2));
    if (context.mounted) {
      // ignore: use_build_context_synchronously
      context.go('/');
    }
  }

  void handleIncorrectTile(int idx) async {
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
        startLevel();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < lives; i++)
                    Icon(Icons.favorite, color: Colors.red, size: 30),
                  if (lives <= 0)
                    Icon(Icons.favorite, color: Colors.transparent, size: 30),
                ],
              ),
              Container(
                height: 600,
                width: 600,
                child: GridView.count(
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: gridSize,
                  children: [
                    for (int i = 0; i < gridSize * gridSize; i++)
                      InkWell(
                        onTap: () {
                          if (gameState == GameState.playing) {
                            chooseTile(i);
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: getTileColor(i),
                          ),
                          child: Center(
                            child: Text(
                              '',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
