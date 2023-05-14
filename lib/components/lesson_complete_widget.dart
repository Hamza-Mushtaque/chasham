import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LessonCompleteWidget extends StatelessWidget {
  final nextLessonSerialNo;

  const LessonCompleteWidget({super.key, required this.nextLessonSerialNo});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'یہ سبق مکمل ہوا',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'NastaliqKasheeda',
              ),
            ),
            const SizedBox(height: 32),
            SvgPicture.asset(
              'assets/svgs/complete-img.svg',
              width: 280,
            ),
            const SizedBox(height: 64),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 160,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to the next lesson screen.
                      Navigator.pushReplacementNamed(context, '/lesson',
                          arguments: {'id': nextLessonSerialNo.toString()});
                    },
                    child: const Text(
                      'اگلا سبق',
                      style: TextStyle(
                        fontFamily: 'NastaliqKasheeda',
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 160,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                    child: const Text(
                      'مشق حل کریں',
                      style: TextStyle(
                        fontFamily: 'NastaliqKasheeda',
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                    child: const Text(
                      'ڈیش بورڈ پر جائیں',
                      style: TextStyle(
                        fontFamily: 'NastaliqKasheeda',
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
