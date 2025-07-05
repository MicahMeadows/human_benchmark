import 'package:flutter/material.dart';

class GameSelectButton extends StatelessWidget {
  final String gameName;
  final void Function()? onTap;

  const GameSelectButton({
    super.key,
    required this.onTap,
    required this.gameName,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        color: Colors.blue,
        child: Text(
          gameName,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
