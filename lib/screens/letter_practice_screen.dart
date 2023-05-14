import 'package:chasham_fyp/min_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../components/letter_card_widget.dart';

class LetterPracticeScreen extends StatefulWidget {
  const LetterPracticeScreen({Key? key}) : super(key: key);

  @override
  _LetterPracticeScreenState createState() => _LetterPracticeScreenState();
}

class _LetterPracticeScreenState extends State<LetterPracticeScreen> {
  final PageController _pageController = PageController();
  final player = AudioPlayer();
  int _currentPage = 0;
  bool _canGoToNext = false;
  String _answerRemarks = '';
  String _currentAns = '000000';
  final List<Map<String, String>> _testLetters = [
    {
      'letter': 'ا',
      'braille': '100000',
      'description': 'بریل میں الف لکھ کر دکھائیں',
    },
    {
      'letter': 'ب',
      'braille': '110000',
      'description': 'بریل میں ب لکھ کر دکھائیں',
    },
    {
      'letter': 'پ',
      'braille': '100100',
      'description': 'بریل میں پ لکھ کر دکھائیں',
    },
  ];

  void _handlePageChange(int index) {
    setState(() {
      _currentPage = index;
      _answerRemarks = '';
      _canGoToNext = false;
      _currentAns = '000000';
    });
  }

  void _checkAnswer() {
    if (_currentAns == _testLetters[_currentPage]['braille']) {
      playRemarksAudio('correct');
      setState(() {
        _answerRemarks = ' جواب درست ہے';
        _canGoToNext = true;
      });
    } else {
      playRemarksAudio('wrong');
      setState(() {
        _answerRemarks = ' جواب غلط ہے';
      });
    }
  }

  void playRemarksAudio(String remarks) async {
    print('PLAYING ');
    // final duration = await player.setAsset(
    //     'assets/audios/letter-1.wav');
    if (remarks == 'correct') {
      final duration =
          await player.setAsset('assets/audios/correct-answer.wav');
      await player.play();
    } else {
      final duration = await player.setAsset('assets/audios/wrong-answer.wav');
      await player.play();
    }
    print('DONE');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MinAppBar(title: 'Practice'),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 48),
              const Text(
                'مشق نمبر ١',
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
                  itemCount: _testLetters.length,
                  itemBuilder: (context, index) {
                    final lesson = _testLetters[index];
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
                      if (_currentPage == _testLetters.length - 1) {
                        null;
                      } else if (_canGoToNext == false) {
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
                      color: _currentPage == _testLetters.length - 1 ||
                              _canGoToNext == false
                          ? Colors.grey
                          : Theme.of(context).colorScheme.primary,
                    ),
                    disabledColor: Colors.grey,
                    iconSize: 96,
                  ),
                  if (_currentPage == _testLetters.length - 1)
                    ElevatedButton(
                        onPressed: () {
                          if (_canGoToNext == false) {
                            null;
                          } else {
                            Navigator.pushNamed(context, '/complete');
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.disabled)) {
                                return Colors
                                    .grey; // Set the background color when disabled
                              }
                              return Theme.of(context)
                                  .colorScheme
                                  .primary; // Set the default background color
                            },
                          ),
                        ),
                        child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'مشق مکمل',
                              style: TextStyle(
                                  fontFamily: 'NastaliqKasheeda',
                                  fontSize: 18,
                                  color: Colors.white),
                            ))),
                  // IconButton(
                  //   onPressed: () {
                  //     if (_currentPage == 0) {
                  //       null;
                  //     } else {
                  //       _pageController.previousPage(
                  //         duration: const Duration(milliseconds: 400),
                  //         curve: Curves.easeInOut,
                  //       );
                  //     }
                  //   },
                  //   icon: Icon(
                  //     Icons.arrow_right_rounded,
                  //     color: _currentPage == 0
                  //         ? Colors.grey
                  //         : Theme.of(context).colorScheme.primary,
                  //   ),
                  //   disabledColor: Colors.grey,
                  //   color: Theme.of(context).primaryColor,
                  //   iconSize: 96,
                  // ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'آپ کا جواب',
                textAlign: TextAlign.center,
              ),
              Container(
                height: 200,
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 4,
                  children: List.generate(6, (index) {
                    String chipValue = _currentAns[index];

                    return ChoiceChip(
                      label: Text(chipValue),
                      selected: chipValue == '1',
                      onSelected: (selected) {
                        setState(() {
                          _currentAns = _currentAns.replaceRange(
                              index, index + 1, selected ? '1' : '0');
                        });
                      },
                    );
                  }),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(_answerRemarks,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NastaliqKasheeda')),
                  ElevatedButton(
                    onPressed: () {
                      _checkAnswer();
                    },
                    child: const Text('Give Answer'),
                  ),
                ],
              )
            ],
          ),
        ),
      )),
    );
  }
}
