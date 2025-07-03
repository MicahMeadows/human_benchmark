import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:human_benchmark/data/cubit/game_result_cubit.dart';

class GameSelectPage extends StatefulWidget {
  const GameSelectPage({super.key});

  @override
  State<GameSelectPage> createState() => _GameSelectPageState();
}

class _GameSelectPageState extends State<GameSelectPage> {
  final gameResultCubit = GetIt.I<GameResultCubit>();
  Widget buildGameButton(String label, String route) {
    return InkWell(
      onTap: () {
        context.go(route);
      },
      child: Container(
        padding: EdgeInsets.all(10),
        color: Colors.blue,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          spacing: 4,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.green,
              height: 300,
              width: 600,
              child: BlocBuilder<GameResultCubit, GameResultState>(
                bloc: gameResultCubit,
                builder: (context, state) {
                  return state.when(
                    initial: () => Center(child: Text('no game played')),
                    chimpResult: (result) => Center(
                      child: Text('sequence length: ${result.sequenceLength}'),
                    ),
                    visualMemoryResult: (result) => Center(
                      child: Text('tile count: ${result.tileCount}'),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 30),
            buildGameButton('Visual Memory', '/visual_memory_game'),
            buildGameButton('Chimp Game', '/chimp_game'),
            buildGameButton('Reaction Test', '/reaction_game'),
          ],
        ),
      ),
    );
  }
}
