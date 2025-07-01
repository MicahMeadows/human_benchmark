import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int sequenceLength = 3;
  List<int> sequencePositions = [];
  // List<int> sequencePositions = [21, 4, 8];
  int gridSize = 5;
  int correct = 0;

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
          sequenceLength++;
          newLevel();
        }
      });
    } else {
      if (correct > 0) {
        // dont fail if click wrong tile first
        newLevel();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          height: 600,
          width: 600,
          color: Colors.green,
          child: GridView.count(
            crossAxisCount: gridSize,
            children: [
              for (int i = 0; i < gridSize * gridSize; i++)
                InkWell(
                  onTap: () {
                    selectTile(i);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: sequencePositions.contains(i)
                          ? (correct <= sequencePositions.indexOf(i)
                                ? Colors.red
                                : Colors.green)
                          : Colors.blue,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        '${sequencePositions.contains(i) && correct == 0 ? sequencePositions.indexOf(i) + 1 : ''}',
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
      ),
    );
  }
}
