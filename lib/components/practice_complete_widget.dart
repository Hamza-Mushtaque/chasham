import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PracticeCompleteWidget extends StatelessWidget {
  // final nextLessonSerialNo;

  // const ExerciseCompleteWidget({super.key, required this.nextLessonSerialNo});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'یہ پریکٹس مکمل ہوئی',
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
