import 'package:flutter/material.dart';

class LetterCardWidget extends StatelessWidget {
  final String letter;
  final String braille;

  const LetterCardWidget({
    Key? key,
    required this.letter,
    required this.braille,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Color> dotColors = _getDotColors();

    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(4, 4),
              ),
            ],
            border: Border.all(color: Colors.black.withOpacity(0.2))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'بریل',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NastaliqKasheeda'),
                      ),
                      const SizedBox(height: 8),
                      Divider(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'حرفِ تہجی',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NastaliqKasheeda'),
                      ),
                      const SizedBox(height: 8),
                      Divider(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      _buildBraille(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        letter,
                        style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'NooriNastaliq'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                )
              ],
            )
          ],
        ));
  }

  Widget _buildBraille() {
    final List<Color> dotColors = _getDotColors();

    return SizedBox(
      width: 56,
      height: 72,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDot(dotColors[0]),
              _buildDot(dotColors[1]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDot(dotColors[2]),
              _buildDot(dotColors[3]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDot(dotColors[4]),
              _buildDot(dotColors[5]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  List<Color> _getDotColors() {
    final List<Color> dotColors = List.filled(6, Colors.grey);

    for (int i = 0; i < 6; i++) {
      if (braille[i] == '1') {
        dotColors[i] = Colors.black;
      }
    }

    return dotColors;
  }
}
