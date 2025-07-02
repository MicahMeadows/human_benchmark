import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChimpTestPage extends StatefulWidget {
  const ChimpTestPage({super.key});

  @override
  State<ChimpTestPage> createState() => _ChimpTestPageState();
}

class _ChimpTestPageState extends State<ChimpTestPage> {
  int lives = 3;
  int sequenceLength = 3;

  int calculateGridSize() {
    if (sequenceLength < 5) return 3;
    if (sequenceLength < 7) return 4;
    if (sequenceLength < 10) return 5;
    if (sequenceLength < 15) return 6;
    return 7;
  }

  int get gridSize => calculateGridSize();

  List<int> sequencePositions = [];
  // List<int> sequencePositions = [21, 4, 8];
  int correct = 0;
  final int initialSequenceLength = 3;

  void passLevel() {
    sequenceLength++;
    newLevel();
  }

  void endGame() {
    context.go('/');
    // sequenceLength = initialSequenceLength;
    // lives = 3;
    // newLevel();
  }

  void failLevel() {
    lives--;
    if (lives <= 0) {
      endGame();
      return;
    }
    newLevel();
  }

  void newLevel() {
    correct = 0;
    Set<int> newSequencePositions = {};
    while (newSequencePositions.length < sequenceLength) {
      int newPos = Random().nextInt(gridSize * gridSize);
      newSequencePositions.add(newPos);
    }
    setState(() {
      sequencePositions = newSequencePositions.toList();
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize the game with a new level
    newLevel();
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
            Container(
              height: 600,
              width: 600,
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
                          color: sequencePositions.contains(i)
                              ? (correct <= sequencePositions.indexOf(i)
                                    ? Colors.red
                                    : Colors.green)
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            '${sequencePositions.contains(i) && (correct == 0 || sequenceLength == initialSequenceLength) ? sequencePositions.indexOf(i) + 1 : ''}',
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
          ],
        ),
      ),
    );
  }
}
