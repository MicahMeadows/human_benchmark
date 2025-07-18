import 'package:flutter/material.dart';
import 'package:human_benchmark/colors.dart';

Widget getScoreSquare(String text, int value) {
  return Stack(
    children: [
      Container(
        height: 100,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
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
        height: 9,
        child: Container(
          margin: EdgeInsets.only(top: 2, right: 2, left: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: .75),
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
        height: 9,
        child: Container(
          margin: EdgeInsets.only(bottom: 2, right: 2, left: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
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

class GameSelectButton extends StatefulWidget {
  final void Function()? onTap;
  final bool isHovered;
  final String gameName;
  final String backgroundImage;
  final double imageScale;
  final int lastScore;
  final int highScore;

  final double spacing;

  const GameSelectButton({
    super.key,
    required this.lastScore,
    required this.highScore,
    required this.imageScale,
    required this.onTap,
    required this.isHovered,
    required this.gameName,
    required this.backgroundImage,
    this.spacing = 12, // default spacing value
  });

  @override
  State<GameSelectButton> createState() => _GameSelectButtonState();
}

class _GameSelectButtonState extends State<GameSelectButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildImageGrid() {
    const double iconSize = 40;
    final double spacing = widget.spacing; // use param

    final int columns = 12;
    final int rows = 8;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(rows, (row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(columns, (col) {
            return Padding(
              padding: EdgeInsets.all(spacing / 2),
              child: Image.asset(
                widget.backgroundImage,
                width: iconSize,
                height: iconSize,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            );
          }),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          // White border when hovered
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // border: widget.isHovered
            //     ? Border.all(color: Colors.white, width: 3)
            //     : null,
            border: Border.all(
              color: widget.isHovered
                  ? Colors.white
                  : Colors.white.withValues(alpha: .1),
              width: 3,
            ),
          ),
          // padding: EdgeInsets.all(3),
          child: Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.isHovered ? 7 : 10),
              color: background.withValues(alpha: 1),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final curved = Curves.easeInOut.transform(
                      _controller.value,
                    );
                    final dx = -curved * 100;
                    final dy = curved * 40;
                    return Transform.translate(
                      offset: Offset(dx, dy),
                      child: Transform.scale(
                        scale: widget.imageScale,
                        child: _buildImageGrid(),
                      ),
                    );
                  },
                ),

                Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Spacer(),
                      Text(
                        widget.gameName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                      getScoreSquare('High Score', widget.highScore),
                      const SizedBox(width: 20),
                      getScoreSquare('Last Score', widget.lastScore),
                      const SizedBox(width: 20),
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
