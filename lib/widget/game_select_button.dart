import 'package:flutter/material.dart';
import 'package:human_benchmark/colors.dart';

class GameSelectButton extends StatelessWidget {
  // final String gameName;
  final void Function()? onTap;
  final bool isHovered;
  final String gameName;
  final String backgroundImage;
  final double imageScale;
  final int lastScore;
  final int highScore;

  const GameSelectButton({
    super.key,
    required this.lastScore,
    required this.highScore,
    required this.imageScale,
    required this.onTap,
    // required this.gameName,
    required this.isHovered,
    required this.gameName,
    required this.backgroundImage,
  });

  Widget getScoreSquare(String text, int value) {
    return Stack(
      children: [
        Container(
          height: 100,
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            // color: Color(0xff151515),
            color: Color(0xff1e1e1e),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: .07),
              width: 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  '$value',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Top inner shadow (darker, taller)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 9, // increased height
          child: Container(
            margin: EdgeInsets.only(top: 2, right: 2, left: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: .75), // darker shadow
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Bottom inner shadow (darker, taller)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 9, // increased height
          child: Container(
            margin: EdgeInsets.only(bottom: 2, right: 2, left: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  // Color(0xff2e2e2e).withValues(alpha: .3), // darker shadow
                  Colors.white.withValues(alpha: .1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: isHovered
                ? Colors.white
                // : Colors.white.withValues(alpha: .1),
                : Colors.transparent,
          ),
          // padding: EdgeInsets.all(isHovered ? 8 : 2),
          padding: EdgeInsets.all(8),
          child: Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isHovered ? 5 : 10),
              // color: Colors.green,
              color: background.withValues(),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Rotated image, scaled larger to prevent cropping
                Positioned.fill(
                  child: Transform.rotate(
                    angle: -0.1, // ~ -5.7 degrees
                    child: Transform.scale(
                      scale: imageScale,
                      child: Image.asset(
                        backgroundImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Spacer(),
                      Text(
                        gameName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                      getScoreSquare('High Score', highScore),
                      const SizedBox(width: 20),
                      getScoreSquare('Last Score', lastScore),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
