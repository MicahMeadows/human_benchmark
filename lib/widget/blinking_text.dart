import 'package:flutter/material.dart';

class BlinkingText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const BlinkingText({
    Key? key,
    required this.text,
    this.style,
  }) : super(key: key);

  @override
  _BlinkingTextState createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<BlinkingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Text(
        widget.text,
        style:
            widget.style ??
            const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
