import 'package:flutter/material.dart';

class AnimatedScore extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final String scoreText;
  final VoidCallback onComplete;

  const AnimatedScore({
    required this.startPosition,
    required this.endPosition,
    required this.scoreText,
    required this.onComplete,
    super.key,
  });

  @override
  State<AnimatedScore> createState() => _AnimatedScoreState();
}

class _AnimatedScoreState extends State<AnimatedScore>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _position =
        Tween<Offset>(
            begin: widget.startPosition,
            end: widget.endPosition,
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.onComplete();
            }
          });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _position,
      builder: (context, child) {
        return Positioned(
          left: _position.value.dx,
          top: _position.value.dy,
          child: Text(
            widget.scoreText,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
              shadows: [Shadow(blurRadius: 4, color: Colors.black26)],
            ),
          ),
        );
      },
    );
  }
}
