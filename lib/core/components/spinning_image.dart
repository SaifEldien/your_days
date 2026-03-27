import 'package:flutter/material.dart';

class SpinningImage extends StatefulWidget {
  final String imagePath;
  final double size;

  const SpinningImage({super.key, required this.imagePath, this.size = 100.0});

  @override
  State<SpinningImage> createState() => _SpinningImageState();
}

class _SpinningImageState extends State<SpinningImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose(); // حماية الذاكرة (Memory Leak Prevention)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Image.asset(
        widget.imagePath,
        width: widget.size,
        height: widget.size,
        // بنحط BoxFit.contain عشان الصورة ما تتمطش
        fit: BoxFit.contain,
      ),
    );
  }
}
