import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamepads/gamepads.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:human_benchmark/colors.dart';
import 'package:human_benchmark/data/cubit/credit_bank/credit_bank_cubit.dart';
import 'package:human_benchmark/data/cubit/records/records_cubit.dart';
import 'package:human_benchmark/widget/blinking_text.dart';
import 'package:human_benchmark/widget/game_select_button.dart';
import 'package:particles_flutter/component/particle/particle.dart';
import 'package:particles_flutter/particles_engine.dart';

class GameSelectPage extends StatefulWidget {
  const GameSelectPage({super.key});

  @override
  State<GameSelectPage> createState() => _GameSelectPageState();
}

class _GameSelectPageState extends State<GameSelectPage> {
  bool _canSelect = false;
  final recordsCubit = GetIt.I<RecordsCubit>();
  // final gameResultCubit = GetIt.I<GameResultCubit>();
  final creditBankCubit = GetIt.I<CreditBankCubit>();
  StreamSubscription<GamepadEvent>? gamepadSubscription;

  int selectionIndex = 0;

  @override
  void dispose() {
    gamepadSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    gamepadSubscription = Gamepads.events.listen(handleGamepadEvent);

    // Disable input for 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _canSelect = true;
      });
    });
  }

  void acceptCoin() {
    setState(() {
      creditBankCubit.addCredits(1);
    });
  }

  double randomSign() {
    var rng = Random();
    return rng.nextBool() ? 1 : -1;
  }

  List<Particle> createParticles() {
    var rng = Random();
    List<Particle> particles = [];
    for (int i = 0; i < 70; i++) {
      // random opactiy between .2 and .6
      final randomOpacity = rng.nextDouble() * 0.4 + 0.2;
      particles.add(
        Particle(
          color: Colors.white.withValues(alpha: randomOpacity),
          size: rng.nextDouble() * 10,
          velocity: Offset(
            rng.nextDouble() * 200 * randomSign(),
            rng.nextDouble() * 200 * randomSign(),
          ),
        ),
      );
    }
    return particles;
  }

  Widget buildRecentResultBanner(bool hasCoins, RecordsState recordsState) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top:
              200, // gross hack but puts the particles somewhere behind the game result hiding them from top of screen.
          bottom: 0,
          child: Particles(
            particles: createParticles(),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            connectDots: true,
          ),
        ),

        Container(
          color: Color(0xff141414),
          height: 500,
          // width: 600,
          // child: BlocBuilder<GameResultCubit, GameResultState>(
          //   bloc: gameResultCubit,
          //   builder: (context, state) {
          child: recordsState.when(
            // initial: () => Center(child: Text('no game played')),
            initial: () {
              return Center(
                child: BlinkingText(
                  text: hasCoins
                      ? 'SELECT GAME TO PLAY!'
                      : 'INSERT CREDITS TO PLAY',
                ),
              );
            },
            loaded: (records) {
              if (records.lastWasChimp) {
                return Center(
                  child: Row(
                    children: [
                      Spacer(),
                      Spacer(),
                      Image.asset(
                        'assets/image/chimpicon.png',
                        height: 300,
                      ),
                      Spacer(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'NEW SCORE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 60,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${records.lastChimpScore}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 60,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Spacer(),
                    ],
                  ),
                );
              } else if (records.lastWasReaction) {
                return Center(
                  child: Row(
                    children: [
                      Spacer(),
                      Spacer(),
                      Image.asset(
                        'assets/image/eyecon.png',
                        height: 300,
                      ),
                      Spacer(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'NEW SCORE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 60,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${records.lastReactionScore}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 60,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Spacer(),
                    ],
                  ),
                );
              } else if (records.lastWasReactionQueue) {
                return Center(
                  child: Row(
                    children: [
                      Spacer(),
                      Spacer(),
                      Image.asset(
                        'assets/image/eyecon.png',
                        height: 300,
                      ),
                      Spacer(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'NEW SCORE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 60,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${records.reactionQueueHighScore}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 60,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Spacer(),
                    ],
                  ),
                );
              } else if (records.lastWasVisualMemory) {
                return Center(
                  child: Row(
                    children: [
                      Spacer(),
                      Spacer(),
                      Image.asset(
                        'assets/image/brainicon.png',
                        height: 300,
                      ),
                      Spacer(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'NEW SCORE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 60,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${records.lastVisualMemoryScore}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 60,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Spacer(),
                    ],
                  ),
                );
              }
              return Center(
                child: Text('No last game found.'),
              );
            },
          ),
        ),
      ],
    );
  }

  void handleGamepadEvent(GamepadEvent event) {
    if (event.type == KeyType.button) {
      print('Button event: ${event.key} - ${event.value}');

      // handle select button
      if (['y.circle', 'l1.rectangle.roundedbottom'].contains(event.key)) {
        if (event.value == 0) {
          confirmSelection(selectionIndex);
        }
      }

      // handle coin button
      if (['r2.rectangle.roundedtop'].contains(event.key)) {
        if (event.value == 1) {
          acceptCoin();
        }
      }
    }

    // handle joystick movement
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
      selectionIndex = newValue.clamp(0, 2);
    });
  }

  void confirmSelection(int index) {
    if (!_canSelect) {
      return;
    }
    // selectOption(selectionIndex);
    switch (index) {
      case 0:
        context.go('/visual_memory_game');
        creditBankCubit.subtractCredits(1);
        break;
      case 1:
        context.go('/chimp_game');
        creditBankCubit.subtractCredits(1);
        break;
      case 2:
        // context.go('/reaction_game');
        context.go('/reaction_queue_game');
        creditBankCubit.subtractCredits(1);
        break;
      default:
        print('Invalid selection index: $index');
    }
  }

  // void selectOption(int idx) {
  //   if (creditBankCubit.state >= gameOptions[idx].cost) {
  //     if (idx < 0 || idx >= gameOptions.length) return;

  //     final option = gameOptions[idx];
  //     context.go(option.route);
  //     creditBankCubit.subtractCredits(option.cost);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // color: background,
        color: Color(0xff1e1e1e),
        child: BlocBuilder<RecordsCubit, RecordsState>(
          bloc: recordsCubit,
          builder: (context, recordsState) {
            return BlocBuilder<CreditBankCubit, int>(
              bloc: creditBankCubit,
              builder: (context, coins) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 5),
                        Text(
                          'CREDITS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 25),
                        Text(
                          '$coins',
                          style: TextStyle(
                            color: secondary,
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Text('Credits: $coins'),
                        Spacer(),
                      ],
                    ),

                    buildRecentResultBanner(coins > 0, recordsState),
                    SizedBox(height: 30),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final records = recordsState.whenOrNull(
                            loaded: (records) => records,
                          );
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 200),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              spacing: 60,
                              children: [
                                const SizedBox(height: 0),
                                GameSelectButton(
                                  spacing: 5,
                                  highScore:
                                      records?.longestVisualMemorySequence ?? 0,
                                  lastScore:
                                      records?.lastVisualMemoryScore ?? 0,
                                  imageScale: 1.8,
                                  backgroundImage: 'assets/image/brainicon.png',
                                  onTap: coins >= 1
                                      ? () {
                                          confirmSelection(0);
                                        }
                                      : null,
                                  isHovered: selectionIndex == 0,
                                  gameName: 'MEMORY\nTEST',
                                ),
                                GameSelectButton(
                                  spacing: 5,
                                  imageScale: 1.8,
                                  highScore: records?.chimpHighScore ?? 0,
                                  lastScore: records?.lastChimpScore ?? 0,
                                  backgroundImage:
                                      // 'assets/image/chimp_background.png',
                                      'assets/image/chimpicon.png',
                                  onTap: coins >= 1
                                      ? () {
                                          confirmSelection(1);
                                        }
                                      : null,
                                  isHovered: selectionIndex == 1,
                                  gameName: 'CHIMP\nTEST',
                                ),
                                GameSelectButton(
                                  spacing: 5,
                                  imageScale: 1.8,
                                  highScore:
                                      records?.reactionQueueHighScore ?? 0,
                                  lastScore:
                                      records?.lastReactionQueueScore ?? 0,
                                  backgroundImage:
                                      // 'assets/image/chimp_background.png',
                                      'assets/image/eyecon.png',
                                  onTap: coins >= 1
                                      ? () {
                                          confirmSelection(2);
                                        }
                                      : null,
                                  isHovered: selectionIndex == 2,
                                  gameName: 'SPEED\nTEST',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
