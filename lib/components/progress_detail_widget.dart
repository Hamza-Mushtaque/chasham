import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ProgressDetailWidget extends StatefulWidget {
  final String iconPath;
  final String title;
  final Color color;
  final int value;

  ProgressDetailWidget({
    required this.iconPath,
    required this.title,
    required this.color,
    required this.value,
  });

  @override
  _ProgressDetailWidgetState createState() => _ProgressDetailWidgetState();
}

class _ProgressDetailWidgetState extends State<ProgressDetailWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.value / 10,
    ).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${widget.value}/10 مکمل',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NooriNastaliq'),
                ),
                const SizedBox(height: 4),
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                  child: LinearProgressIndicator(
                    value: 0.5,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                    backgroundColor: Color(0xFFEAEEFD),
                    minHeight: 8,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFEAEEFD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: SvgPicture.asset(
                widget.iconPath,
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
