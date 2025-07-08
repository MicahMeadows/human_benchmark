import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamepads/gamepads.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:human_benchmark/data/cubit/credit_bank/credit_bank_cubit.dart';
import 'package:human_benchmark/data/cubit/game_result/game_result_cubit.dart';
import 'package:human_benchmark/data/cubit/records/records_cubit.dart';
import 'package:human_benchmark/data/model/game_select_option.dart';
import 'package:human_benchmark/widget/game_select_button.dart';

class GameSelectPage extends StatefulWidget {
  const GameSelectPage({super.key});

  @override
  State<GameSelectPage> createState() => _GameSelectPageState();
}

class _GameSelectPageState extends State<GameSelectPage> {
  final recordsCubit = GetIt.I<RecordsCubit>();
  final gameResultCubit = GetIt.I<GameResultCubit>();
  final creditBankCubit = GetIt.I<CreditBankCubit>();
  StreamSubscription<GamepadEvent>? gamepadSubscription;

  final gameOptions = [
    GameSelectOption(
      gameName: 'Visual Memory',
      route: '/visual_memory_game',
    ),
    GameSelectOption(
      gameName: 'Chimp Game',
      route: '/chimp_game',
    ),
    GameSelectOption(
      gameName: 'Reaction Test',
      route: '/reaction_game',
    ),
  ];

  int selectionIndex = 0;
  int maxSelectionIndex = 2; // Adjust based on the number of games

  @override
  void dispose() {
    gamepadSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    gamepadSubscription = Gamepads.events.listen(handleGamepadEvent);
    super.initState();
  }

  void handleGamepadEvent(GamepadEvent event) {
    if (event.type == KeyType.button) {
      // if (event.key == 'y.circle') {
      if (['y.circle', 'l1.rectangle.roundedbottom'].contains(event.key)) {
        if (event.value == 0) {
          confirmSelection();
        }
      }
    }
    if (event.type == KeyType.analog) {
      if (event.key == 'l.joystick - yAxis') {
        handleJoyYMove(event.value);
      } else if (event.key == 'l.joystick - xAxis') {
        // handle joy x
      }
    }
  }

  void handleJoyYMove(double value) {
    int newValue = selectionIndex;
    if (value < -.1) {
      newValue--;
    } else if (value > .1) {
      newValue++;
    }

    setState(() {
      selectionIndex = newValue.clamp(0, maxSelectionIndex);
    });
  }

  void confirmSelection() {
    print('Confirming selection: $selectionIndex');
    selectOption(selectionIndex);
  }

  void selectOption(int idx) {
    if (idx < 0 || idx >= gameOptions.length) return;

    final option = gameOptions[idx];
    context.go(option.route);
    creditBankCubit.subtractCredits(option.cost);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RecordsCubit, RecordsState>(
        bloc: recordsCubit,
        builder: (context, recordsState) {
          return BlocBuilder<CreditBankCubit, int>(
            bloc: creditBankCubit,
            builder: (context, coins) {
              return Center(
                child: Column(
                  spacing: 4,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    recordsCubit.state.when(
                      initial: () {
                        return Text('no records loaded');
                      },
                      loaded: (records) {
                        return Column(
                          children: [
                            Text(
                              'Fastest Reaction Time: ${records.fastestReactionTime} ms',
                            ),
                            Text(
                              'Longest Visual Memory Sequence: ${records.longestVisualMemorySequence}',
                            ),
                            Text(
                              'Longest Chimp Test Sequence: ${records.longestChimpTestSequence}',
                            ),
                          ],
                        );
                      },
                    ),

                    Row(
                      children: [
                        Text('Credits: $coins'),
                        Spacer(),
                      ],
                    ),
                    Container(
                      color: Colors.green,
                      height: 300,
                      width: 600,
                      child: BlocBuilder<GameResultCubit, GameResultState>(
                        bloc: gameResultCubit,
                        builder: (context, state) {
                          return state.when(
                            initial: () =>
                                Center(child: Text('no game played')),
                            chimpTest: (result) => Center(
                              child: Text(
                                'sequence length: ${result.sequenceLength}',
                              ),
                            ),
                            visualMemoryTest: (result) => Center(
                              child: Text('tile count: ${result.tileCount}'),
                            ),
                            reactionTest: (reactionTime) => Center(
                              child: Text('reaction time: $reactionTime ms'),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 30),
                    for (var option in gameOptions)
                      GameSelectButton(
                        isHovered:
                            selectionIndex == gameOptions.indexOf(option),
                        option: option,
                        onTap: coins >= option.cost
                            ? () {
                                selectOption(gameOptions.indexOf(option));
                              }
                            : null,
                      ),
                    // GameSelectButton(
                    //   isHovered: selectionIndex == 0,
                    //   gameName: 'Visual Memory',
                    //   onTap: coins > 0
                    //       ? () {
                    //           context.go('/visual_memory_game');
                    //           creditBankCubit.subtractCredits(1);
                    //         }
                    //       : null,
                    // ),
                    // GameSelectButton(
                    //   isHovered: selectionIndex == 1,
                    //   gameName: 'Chimp Game',
                    //   onTap: coins > 0
                    //       ? () {
                    //           context.go('/chimp_game');
                    //           creditBankCubit.subtractCredits(1);
                    //         }
                    //       : null,
                    // ),
                    // GameSelectButton(
                    //   isHovered: selectionIndex == 2,
                    //   gameName: 'Reaction Test',
                    //   onTap: coins > 0
                    //       ? () {
                    //           context.go('/reaction_game');
                    //           creditBankCubit.subtractCredits(1);
                    //         }
                    //       : null,
                    // ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
