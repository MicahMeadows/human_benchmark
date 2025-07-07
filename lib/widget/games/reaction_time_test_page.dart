import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:human_benchmark/data/cubit/game_result/game_result_cubit.dart';

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
  static const numTestsToComplete = 3;
  int testsCompleted = 0;
  int totalReactionTimeMs = 0;
  int activeTestId = 0;
  StreamSubscription<GamepadEvent>? gamepadSubscription;

  void startTest() async {
    activeTestId++;
    int thisTestId = activeTestId;
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

    if (testState == TestState.started && activeTestId == thisTestId) {
      // the id check ensures that if we started a new test while waiting, we don't change the state of the previous one
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
      if (testsCompleted == numTestsToComplete) {
        GetIt.I<GameResultCubit>().reactionTestOver(
          totalReactionTimeMs ~/ numTestsToComplete,
        );
        context.go('/');
      } else {
        testState = TestState.finished;
      }
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
              'Reaction Time: ${totalReactionTimeMs ~/ numTestsToComplete}ms\n',
            );
          }
          return Text(
            '${lastReactionMs}ms ($testsCompleted/$numTestsToComplete)',
          );
        }
    }
  }

  void exitGame() {
    context.go('/');
  }

  void handleTap() {
    if (testState == TestState.notStarted ||
        testState == TestState.early ||
        testState == TestState.finished) {
      if (testsCompleted >= numTestsToComplete) {
        exitGame();
      } else {
        startTest();
      }
    } else if (testState == TestState.ready) {
      registerCorrectClick();
    } else if (testState == TestState.started) {
      registerEarlyClick();
    }
  }

  @override
  void initState() {
    super.initState();

    gamepadSubscription = Gamepads.events.listen(handleGamepadEvent);
  }

  @override
  void dispose() {
    gamepadSubscription?.cancel();
    super.dispose();
  }

  void handleGamepadEvent(GamepadEvent event) {
    if (event.type == KeyType.button) {
      if (event.key == 'y.circle') {
        if (event.value == 0) {
          handleTap();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () {
            handleTap();
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
