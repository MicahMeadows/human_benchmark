import 'package:flutter/material.dart';
import 'dart:math';

class FlipTile extends StatefulWidget {
  final bool isRevealed;
  final void Function()? onTap;
  final Color frontColor;
  final Color backColor;
  final bool isHovered;

  const FlipTile({
    super.key,
    required this.isHovered,
    required this.isRevealed,
    required this.onTap,
    required this.frontColor,
    required this.backColor,
  });

  @override
  State<FlipTile> createState() => _FlipTileState();
}

class _FlipTileState extends State<FlipTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      value: widget.isRevealed ? 1.0 : 0.0, // Set initial position
    );

    _animation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant FlipTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isRevealed != oldWidget.isRevealed) {
      var randomDuration = Random().nextInt(300) + 200;
      _controller.duration = Duration(milliseconds: randomDuration);
      if (widget.isRevealed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isUnder = _animation.value >= pi / 2;
          final displayColor = isUnder ? widget.backColor : widget.frontColor;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(_animation.value),
            child: Container(
              // margin: widget.isHovered
              //     ? const EdgeInsets.all(20)
              //     : EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: displayColor,
                border: widget.isHovered
                    ? Border.all(
                        color: Colors.white,
                        width: 4,
                      )
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(6),
            ),
          );
        },
      ),
    );
  }
}
