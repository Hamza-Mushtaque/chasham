import 'package:chasham_fyp/min_app_bar.dart';
import 'package:flutter/material.dart';

import '../components/letter_card_widget.dart';

class LetterLessonScreen extends StatefulWidget {
  const LetterLessonScreen({Key? key}) : super(key: key);

  @override
  _LetterLessonScreenState createState() => _LetterLessonScreenState();
}

class _LetterLessonScreenState extends State<LetterLessonScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<Map<String, String>> _lessons = [
    {
      'letter': 'ا',
      'braille': '100000',
      'description': 'یہ ہے ا۔',
    },
    {
      'letter': 'ب',
      'braille': '110000',
      'description': 'یہ ہے ب۔',
    },
    {
      'letter': 'پ',
      'braille': '100100',
      'description': 'یہ ہے پ',
    },
  ];

  void _handlePageChange(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MinAppBar(title: 'Lesson'),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 48),
            const Text(
              'سبق نمبر 1',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NastaliqKasheeda'),
            ),
            SizedBox(
              height: 300,
              child: PageView.builder(
                reverse: true,
                controller: _pageController,
                onPageChanged: _handlePageChange,
                itemCount: _lessons.length,
                itemBuilder: (context, index) {
                  final lesson = _lessons[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      LetterCardWidget(
                        letter: lesson['letter']!,
                        braille: lesson['braille']!,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          lesson['description']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'NooriNastaliq', fontSize: 24),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    if (_currentPage == _lessons.length - 1) {
                      null;
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  icon: Icon(
                    Icons.arrow_left_rounded,
                    color: _currentPage == _lessons.length - 1
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                  ),
                  disabledColor: Colors.grey,
                  iconSize: 96,
                ),
                if (_currentPage == _lessons.length - 1)
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/complete');
                      },
                      child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'سبق مکمل',
                            style: TextStyle(
                                fontFamily: 'NastaliqKasheeda',
                                fontSize: 18,
                                color: Colors.white),
                          ))),
                IconButton(
                  onPressed: () {
                    if (_currentPage == 0) {
                      null;
                    } else {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  icon: Icon(
                    Icons.arrow_right_rounded,
                    color: _currentPage == 0
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                  ),
                  disabledColor: Colors.grey,
                  color: Theme.of(context).primaryColor,
                  iconSize: 96,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      )),
    );
  }
}
