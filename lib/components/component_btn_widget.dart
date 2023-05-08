import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ComponentBtnWidget extends StatelessWidget {
  final String label;
  final String svgIconPath;
  final String link;

  const ComponentBtnWidget({
    Key? key,
    required this.label,
    required this.svgIconPath,
    required this.link,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.pushNamed(context, link);
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 134,
        height: 144,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgIconPath,
              width: 48,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'NooriNastaliq'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
