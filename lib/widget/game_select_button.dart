import 'package:flutter/material.dart';
import 'package:human_benchmark/data/model/game_select_option.dart';

class GameSelectButton extends StatelessWidget {
  // final String gameName;
  final void Function()? onTap;
  final bool isHovered;
  final GameSelectOption option;

  const GameSelectButton({
    super.key,
    required this.onTap,
    // required this.gameName,
    required this.isHovered,
    required this.option,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: isHovered
              ? Border.all(
                  color: Colors.black,
                  width: 4,
                )
              : null,
          color: Colors.blue,
        ),
        padding: EdgeInsets.all(10),
        child: Text(
          option.gameName,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
