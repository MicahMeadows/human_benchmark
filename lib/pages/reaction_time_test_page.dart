import 'dart:math';

import 'package:flutter/material.dart';

class ReactionTimeTestPage extends StatefulWidget {
  const ReactionTimeTestPage({super.key});

  @override
  State<ReactionTimeTestPage> createState() => _ReactionTimeTestPageState();
}

enum TestState {
  notStarted,
  started,
  ready,
  early,
  finished,
}

class _ReactionTimeTestPageState extends State<ReactionTimeTestPage> {
  TestState testState = TestState.notStarted;
  int startTimeMs = 0;
  int randomDelayMs = 0;
  int lastReactionMs = 0;
  static const numTestsToComplete = 5;
  int testsCompleted = 0;
  int totalReactionTimeMs = 0;

  void startTest() async {
    lastReactionMs = 0;
    startTimeMs = 0;
    int randomDelayMax = 7000;
    int randomDelayMin = 2000;
    randomDelayMs =
        Random().nextInt(randomDelayMax - randomDelayMin) + randomDelayMin;
    setState(() {
      testState = TestState.started;
    });
    startTimeMs = DateTime.now().millisecondsSinceEpoch;

    await Future.delayed(Duration(milliseconds: randomDelayMs));

    if (testState == TestState.started) {
      // only change state if still started, if already failed this will not change
      setState(() {
        testState = TestState.ready;
      });
    }
  }

  void registerCorrectClick() {
    setState(() {
      int nowMs = DateTime.now().millisecondsSinceEpoch;
      lastReactionMs = nowMs - (startTimeMs + randomDelayMs);
      totalReactionTimeMs += lastReactionMs;
      testsCompleted++;
      testState = TestState.finished;
    });
  }

  void registerEarlyClick() {
    print('early click...');
    setState(() {
      testState = TestState.early;
    });
  }

  Color getBackgroundColor() {
    switch (testState) {
      case TestState.notStarted:
        return Colors.blue;
      case TestState.started:
        return Colors.red;
      case TestState.ready:
        return Colors.lightGreen;
      case TestState.early:
        return Colors.orange;
      case TestState.finished:
        return Colors.blue;
    }
  }

  Widget getCenterWidget() {
    switch (testState) {
      case TestState.notStarted:
        return Text('Click to start');
      case TestState.started:
        return Text('Wait for green...');
      case TestState.ready:
        return Text('Click now!');
      case TestState.early:
        return Text('Too early!');
      case TestState.finished:
        {
          if (testsCompleted == numTestsToComplete) {
            return Text(
              'Average reaction time: ${totalReactionTimeMs ~/ testsCompleted}ms',
            );
          }
          return Text('${lastReactionMs}ms');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () {
            if (testState == TestState.notStarted ||
                testState == TestState.early ||
                testState == TestState.finished) {
              startTest();
            } else if (testState == TestState.ready) {
              registerCorrectClick();
            } else if (testState == TestState.started) {
              registerEarlyClick();
            }
          },
          child: Container(
            alignment: Alignment.center,
            height: double.infinity,
            width: double.infinity,
            color: getBackgroundColor(),
            child: getCenterWidget(),
          ),
        ),
      ),
    );
  }
}
