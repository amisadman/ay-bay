import 'package:flutter/material.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';

class MultiColorBrandLoader extends StatefulWidget {
  final double size;
  final double strokeWidth;

  const MultiColorBrandLoader({
    super.key,
    this.size = 40.0,
    this.strokeWidth = 4.0,
  });

  @override
  State<MultiColorBrandLoader> createState() => _MultiColorBrandLoaderState();
}

class _MultiColorBrandLoaderState extends State<MultiColorBrandLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _colorIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _controller.addListener(() {
      final newIndex = (_controller.value * AppColors.brandSpinnerColors.length).floor() %
          AppColors.brandSpinnerColors.length;
      if (newIndex != _colorIndex) {
        setState(() {
          _colorIndex = newIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          AppColors.brandSpinnerColors[_colorIndex],
        ),
        strokeWidth: widget.strokeWidth,
      ),
    );
  }
}
