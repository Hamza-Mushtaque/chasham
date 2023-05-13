import 'dart:typed_data';

// import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:chasham_fyp/min_app_bar.dart';
import 'package:chasham_fyp/models/lesson_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

import '../components/letter_card_widget.dart';

class LetterLessonScreen extends StatefulWidget {
  final String? lessonId;

  LetterLessonScreen({required this.lessonId});

  @override
  _LetterLessonScreenState createState() => _LetterLessonScreenState();
}

class _LetterLessonScreenState extends State<LetterLessonScreen> {
  final PageController _pageController = PageController();

  final player = AudioPlayer();
  int _currentPage = 0;
  String? _loadingMsg = 'Fetching Lesson Data  ... ';
  bool _isError = false;
  bool _lessonBegan = false;
  LessonModel? _currentLesson;

  Future<void> _fetchCurrentLesson() async {
    if (widget.lessonId == null) {
      // Handle error case where lessonId is not provided
      setState(() {
        _isError = true;
        _loadingMsg = 'Error in Fetching LEsson !!!';
      });
      return;
    }

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('lessons')
          .doc(widget.lessonId)
          .get();

      if (snapshot.exists) {
        setState(() {
          _currentLesson =
              LessonModel.fromJson(snapshot.data() as Map<String, dynamic>);
          _loadingMsg = null;
        });
      } else {
        // Handle case where lesson with the given lessonId does not exist
        setState(() {
          _isError = true;
          _loadingMsg = 'Lesson Does Not Found';
        });
      }
    } catch (error) {
      // Handle error case while fetching the lesson
      setState(() {
        _loadingMsg = error as String;
        _isError = true;
      });
    }
  }

  void _handlePageChange(int index) {
    setState(() {
      _currentPage = index;
    });
    _passLetterToDevice(index);
    // playAudio();
  }

  void _passLetterToDevice(int index) {
    playAudio(_currentLesson!.letters[index].lessonAudioPath);
  }

  void playAudio(String lessonAudioPath) async {
    print('PLAYING ');
    // final duration = await player.setAsset(
    //     'assets/audios/letter-1.wav');
    final duration = await player.setUrl(lessonAudioPath);
    await player.play();
    print('DONE');
  }

  @override
  void initState() {
    super.initState();
    // _fetchLesson(ModalRoute.of(context)!.settings.arguments as String);
    print(widget.lessonId);
    _fetchCurrentLesson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MinAppBar(title: 'Lesson'),
      body: SafeArea(
          child: Container(
              padding: const EdgeInsets.all(16),
              child: _loadingMsg != null
                  ? Container(
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
                    )
                  : Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(height: 48),
                          Text(
                            _currentLesson!.title,
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
                              itemCount: _currentLesson!.letters.length,
                              itemBuilder: (context, index) {
                                final letter = _currentLesson!.letters[index];
                                return Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    LetterCardWidget(
                                      letter: letter.letter,
                                      braille: letter.braille,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 32),
                                      child: Text(
                                        letter.description,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'NooriNastaliq',
                                            fontSize: 24),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (_currentPage ==
                                          _currentLesson!.letters.length - 1 ||
                                      _lessonBegan == false) {
                                    null;
                                  } else {
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                icon: Icon(
                                  Icons.arrow_left_rounded,
                                  color: _currentPage ==
                                              _currentLesson!.letters.length -
                                                  1 ||
                                          _lessonBegan == false
                                      ? Colors.grey
                                      : Theme.of(context).colorScheme.primary,
                                ),
                                disabledColor: Colors.grey,
                                iconSize: 84,
                              ),
                              if (_currentPage == 0)
                                ElevatedButton(
                                    onPressed: _lessonBegan
                                        ? null
                                        : () {
                                            setState(() {
                                              _lessonBegan = true;
                                            });
                                            _passLetterToDevice(0);
                                          },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
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
                                          'سبق کا آغاز کریں',
                                          style: TextStyle(
                                              fontFamily: 'NastaliqKasheeda',
                                              fontSize: 18,
                                              color: Colors.white),
                                        ))),
                              if (_currentPage ==
                                  _currentLesson!.letters.length - 1)
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
                                      duration:
                                          const Duration(milliseconds: 400),
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
                                iconSize: 84,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ))),
    );
  }
}
