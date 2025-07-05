import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:human_benchmark/data/cubit/credit_bank/credit_bank_cubit.dart';
import 'package:human_benchmark/data/cubit/game_result/game_result_cubit.dart';
import 'package:human_benchmark/widget/game_select_button.dart';

class GameSelectPage extends StatefulWidget {
  const GameSelectPage({super.key});

  @override
  State<GameSelectPage> createState() => _GameSelectPageState();
}

class _GameSelectPageState extends State<GameSelectPage> {
  final gameResultCubit = GetIt.I<GameResultCubit>();
  final creditBankCubit = GetIt.I<CreditBankCubit>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CreditBankCubit, int>(
        bloc: creditBankCubit,
        builder: (context, coins) {
          return Center(
            child: Column(
              spacing: 4,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                        initial: () => Center(child: Text('no game played')),
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
                GameSelectButton(
                  gameName: 'Visual Memory',
                  onTap: coins > 0
                      ? () {
                          context.go('/visual_memory_game');
                          creditBankCubit.subtractCredits(1);
                        }
                      : null,
                ),
                GameSelectButton(
                  gameName: 'Chimp Game',
                  onTap: coins > 0
                      ? () {
                          context.go('/chimp_test');
                          creditBankCubit.subtractCredits(1);
                        }
                      : null,
                ),
                GameSelectButton(
                  gameName: 'Reaction Test',
                  onTap: coins > 0
                      ? () {
                          context.go('/reaction_game');
                          creditBankCubit.subtractCredits(1);
                        }
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
