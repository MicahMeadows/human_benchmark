import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GameSelectPage extends StatefulWidget {
  const GameSelectPage({super.key});

  @override
  State<GameSelectPage> createState() => _GameSelectPageState();
}

class _GameSelectPageState extends State<GameSelectPage> {
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
              height: 300,
              width: 600,
              color: Colors.green,
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
