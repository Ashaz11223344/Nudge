import 'package:flutter/material.dart';

class VerticalSpacing extends StatelessWidget {
  final double height;

  const VerticalSpacing({super.key, this.height = 16});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

class HorizontalSpacing extends StatelessWidget {
  final double width;

  const HorizontalSpacing({super.key, this.width = 16});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width);
  }
}
