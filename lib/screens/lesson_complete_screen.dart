import 'package:chasham_fyp/major_app_bar.dart';
import 'package:chasham_fyp/min_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'home_screen.dart';
import 'letter_lesson_screen.dart';

class LessonCompleteScreen extends StatelessWidget {
  const LessonCompleteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MinAppBar(title: 'Compolete'),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'یہ سبق مکمل ہوا',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NastaliqKasheeda'),
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
                    },
                    child: const Text('اگلا سبق',
                        style: TextStyle(
                            fontFamily: 'NastaliqKasheeda',
                            fontSize: 18,
                            color: Colors.white)),
                  ),
                ),
                SizedBox(
                  width: 160,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/dashboard');
                    },
                    child: const Text('ڈیش بورڈ پر جائیں',
                        style: TextStyle(
                            fontFamily: 'NastaliqKasheeda',
                            fontSize: 18,
                            color: Colors.white)),
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
