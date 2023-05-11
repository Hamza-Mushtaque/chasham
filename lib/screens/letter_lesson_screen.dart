import 'dart:typed_data';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:chasham_fyp/min_app_bar.dart';
import 'package:chasham_fyp/models/lesson_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../components/letter_card_widget.dart';

class LetterLessonScreen extends StatefulWidget {
  final String? lessonId;

  LetterLessonScreen({required this.lessonId});

  @override
  _LetterLessonScreenState createState() => _LetterLessonScreenState();
}

class _LetterLessonScreenState extends State<LetterLessonScreen> {
  final PageController _pageController = PageController();
  // AudioPlayer player = AudioPlayer();
  AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
  final AudioCache audioCache = AudioCache();
  int _currentPage = 0;
  String? _loadingMsg = 'Fetching Lesson Data  ... ';
  bool _isError = false;
  LessonModel? _currentLesson;

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
    playAudioNetwork(_currentLesson!.letters[_currentPage].lessonAudioPath);
  }

  // void playAudio(String audioFilePath) async {
  //   ByteData bytes =
  //       await rootBundle.load(audioFilePath); //load audio from assets
  //   Uint8List audioBytes =
  //       bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  //   int result = await player.playBytes(audiobytes);
  //   if (result == 1) {
  //     //play success
  //     print("audio is playing.");
  //   } else {
  //     print("Error while playing audio.");
  //   }
  // }

  void playAudioNetwork(String audioPath) async {
    try {
      print('PLAYING >>> ');
      await audioPlayer.open(Audio.network(audioPath));
      print('PLAYING >>> DONE');
    } catch (t) {
      print(t as String);
    }
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (_currentPage == _lessons.length - 1) {
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
                                iconSize: 96,
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
