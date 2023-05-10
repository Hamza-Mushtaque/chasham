import 'package:chasham_fyp/components/letter_card_widget.dart';
import 'package:chasham_fyp/min_app_bar.dart';
import 'package:flutter/material.dart';

import '../components/practice_card_widget.dart';

class PracticeTableScreen extends StatelessWidget {
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MinAppBar(title: 'Practice'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 48),
                const Text(
                  'مشق کا انتخاب کریں',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NooriNastaliq'),
                ),
                SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 300,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: PracticeCardWidget(
                              title: 'Practice ${index + 1}',
                              brailleImgPath: 'assets/images/braille-1.png',
                              letterImgPath: 'assets/images/lesson-1.png',
                              description: 'اس مشق میں ہم الف، ب، پ، ت اور کی پریکٹس کرینگے۔',
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      left: 16,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                    Positioned(
                      right: 16,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
