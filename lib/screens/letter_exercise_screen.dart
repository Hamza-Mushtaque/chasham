import 'dart:math';

import 'package:chasham_fyp/components/exercise_complete_widget.dart';
import 'package:chasham_fyp/min_app_bar.dart';
import 'package:chasham_fyp/models/exercise_model.dart';
import 'package:chasham_fyp/models/letter_model.dart';
import 'package:chasham_fyp/models/progress_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:chasham_fyp/components/letter_card_widget.dart';

class LetterExerciseScreen extends StatefulWidget {
  final String? exerciseSerial;
  const LetterExerciseScreen({Key? key, required this.exerciseSerial})
      : super(key: key);

  @override
  _LetterExerciseScreenState createState() => _LetterExerciseScreenState();
}

class _LetterExerciseScreenState extends State<LetterExerciseScreen> {
  final PageController _pageController = PageController();
  final player = AudioPlayer();
  String? _loadingMsg = 'Fetching Exercise Data  ... ';
  bool _isError = false;
  int _currentPage = 0;
  bool _canGoToNext = false;
  String _answerRemarks = '';
  String _currentAns = '000000';
  bool _exerciseComplete = false;
  List<LetterModel> _testLetters = [];
  ExerciseModel? _currenExercise;
  final List<Map<String, String>> testLetters = [
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

  void _fetchTestLetters() {
    // Get the current exercise serial number from the widget argument
    final exerciseSerialNo = int.tryParse(widget.exerciseSerial ?? '');

    setState(() {
      _loadingMsg = 'Fetching Exercise Data  ... ';
    });

    if (exerciseSerialNo == null) {
      print('Invalid exercise serial number');
      return;
    }

    FirebaseFirestore.instance
        .collection('exercises')
        .where('serialNo', isEqualTo: exerciseSerialNo)
        .limit(1)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.size > 0) {
        final exerciseData = querySnapshot.docs.first.data();

        final ExerciseModel exercise = ExerciseModel.fromJson(
          exerciseData as Map<String, dynamic>,
        );

        final int lastLetter = exercise.lastLetter;

        if (lastLetter <= 1) {
          print('Error: Invalid lastLetter value');
          return;
        }

        final List<int> randomIndices = [];
        final List<LetterModel> fetchedLetters = [];
        // final String userId = FirebaseAuth.instance.currentUser!.uid;

        while (randomIndices.length < 2) {
          final int randomIndex = Random().nextInt(lastLetter - 1) + 1;

          if (!randomIndices.contains(randomIndex)) {
            randomIndices.add(randomIndex);
          }
        }

        FirebaseFirestore.instance
            .collection('letters')
            .where('serialNo', whereIn: randomIndices)
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            fetchedLetters.add(LetterModel.fromJson(doc.data()));
          });

          setState(() {
            _currenExercise = exercise;
            _testLetters = fetchedLetters;
            _loadingMsg = null;
          });
          print(_testLetters);
        }).catchError((error) {
          print('Error fetching test letters: $error');
          setState(() {
            _loadingMsg = error.toString();
            _isError = true;
          });
        });
      } else {
        print('Exercise not found');
        setState(() {
          _loadingMsg = 'Exercise not found';
          _isError = true;
        });
      }
    }).catchError((error) {
      print('Error fetching exercise: $error');
      setState(() {
        _loadingMsg = error.toString();
        _isError = true;
      });
    });
  }

  void _handlePageChange(int index) {
    setState(() {
      _currentPage = index;
      _answerRemarks = '';
      _canGoToNext = false;
      _currentAns = '000000';
    });
  }

  void _checkAnswer() {
    if (_currentAns == _testLetters[_currentPage].braille) {
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

  void _updateExerciseProgress() async {
    try {
      setState(() {
        _loadingMsg = 'Updating Progress ... ';
      });
      String userId = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot progressSnapshot = await FirebaseFirestore.instance
          .collection('progress')
          .doc(userId)
          .get();

      if (progressSnapshot.exists) {
        ProgressModel progress = ProgressModel.fromJson(
            progressSnapshot.data() as Map<String, dynamic>);

        // Check if the current lesson is already completed
        if (progress.exercisesCompleted.contains(_currenExercise!.serialNo)) {
          // Lesson already completed, show a message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'You have already completed this Exercise.',
                style: TextStyle(color: Colors.green),
              ),
            ),
          );
        } else {
          // Lesson not completed, update the progress
          progress.exercisesCompleted.add(_currenExercise!.serialNo);

          await FirebaseFirestore.instance
              .collection('progress')
              .doc(userId)
              .update(progress.toJson());
        }
        setState(() {
          _exerciseComplete = true;
          _loadingMsg = null;
        });
        // playLessonComplete();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sorry, there is an error.',
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
        setState(() {
          _loadingMsg = null;
        });
      }
    } catch (error) {
      print('Error updating lesson progress: $error');
      setState(() {
        _loadingMsg = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$error', style: TextStyle(color: Colors.red)),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // _fetchLesson(ModalRoute.of(context)!.settings.arguments as String);
    print(widget.exerciseSerial);
    print("Serial No");
    _fetchTestLetters();
    // _fetchCurrentLesson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MinAppBar(title: 'Practice'),
      body: SafeArea(
          child: _loadingMsg != null
              ? (Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isError == false
                            ? const CircularProgressIndicator()
                            : const SizedBox(
                                height: 4,
                              ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(_loadingMsg!)
                      ],
                    ),
                  ),
                ))
              : (SingleChildScrollView(
                  child: Container(
                      padding: const EdgeInsets.all(16),
                      child: _exerciseComplete == false
                          ? (Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const SizedBox(height: 48),
                                Text(
                                  _currenExercise!.title,
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
                                      final letter = _testLetters[index];
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          LetterCardWidget(
                                            letter: letter.letter,
                                            braille: letter.braille,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (_currentPage ==
                                            testLetters.length - 1) {
                                          null;
                                        } else if (_canGoToNext == false) {
                                          null;
                                        } else {
                                          _pageController.nextPage(
                                            duration: const Duration(
                                                milliseconds: 400),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      },
                                      icon: Icon(
                                        Icons.arrow_left_rounded,
                                        color: _currentPage ==
                                                    testLetters.length - 1 ||
                                                _canGoToNext == false
                                            ? Colors.grey
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                      ),
                                      disabledColor: Colors.grey,
                                      iconSize: 96,
                                    ),
                                    (_canGoToNext == false ||
                                            _currentPage !=
                                                _testLetters.length - 1)
                                        ? (const Text(''))
                                        : ElevatedButton(
                                            onPressed: () {
                                              if (_canGoToNext == false ||
                                                  _currentPage !=
                                                      _testLetters.length - 1) {
                                                return;
                                              } else {
                                                _updateExerciseProgress();
                                              }
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty
                                                      .resolveWith<Color>(
                                                (Set<MaterialState> states) {
                                                  if (states.contains(
                                                      MaterialState.disabled)) {
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
                                                  fontFamily:
                                                      'NastaliqKasheeda',
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),

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
                                            _currentAns =
                                                _currentAns.replaceRange(
                                                    index,
                                                    index + 1,
                                                    selected ? '1' : '0');
                                          });
                                        },
                                      );
                                    }),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
                            ))
                          : (ExerciseCompleteWidget(nextLessonSerialNo: 2))),
                ))),
    );
  }
}
