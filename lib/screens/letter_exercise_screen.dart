import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:chasham_fyp/components/exercise_complete_widget.dart';
import 'package:chasham_fyp/min_app_bar.dart';
import 'package:chasham_fyp/models/exercise_model.dart';
import 'package:chasham_fyp/models/letter_model.dart';
import 'package:chasham_fyp/models/progress_model.dart';
import 'package:chasham_fyp/services/bluetooth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
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

  BluetoothConnection? connection;

  void _connectToBluetooth() async {
    try {
      if (selectedDevice != null) {
        // Connect to the selected device
        BluetoothConnection connection =
            await BluetoothConnection.toAddress(selectedDevice!.address);
        setState(() {
          this.connection = connection;
        });
        _showSnackBar("Connected to ${selectedDevice!.name}", true);
        _receiveData();
      } else {
        _showSnackBar("No device selected", false);
      }
    } catch (exception) {
      // _showSnackBar("Error connecting to Bluetooth device: $exception", false);
      _connectToBluetooth();
    }
  }

  void _receiveData() {
    if (connection != null) {
      connection!.input!.listen((Uint8List data) {
        String incomingMessage = utf8.decode(data);
        print("Received message: $incomingMessage");
        setState(() {
          receiveText = incomingMessage;
        });
        _showSnackBar("Message Received: $incomingMessage", true);
        // Do something with the incoming message...

        if(receiveText.trim() == "NEXT".trim() && _canGoToNext){
          if(_currentPage < (_testLetters.length -1)){
              _handlePageChange(_currentPage+1);
              _pageController.nextPage(
              duration:
                  const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
          else if(_currentPage == (_testLetters.length-1)){
            setState(() {
              _exerciseComplete = true;     
            });
            
          }
          else if(_exerciseComplete){
            con_cancel();
            Navigator.pushReplacementNamed(context, '/lesson',
            arguments: {'id': (_currenExercise!.serialNo + 1).toString()});
          }
        }
        else if(receiveText.trim() == "PREVIOUS".trim() && _exerciseComplete){
          con_cancel();
          Navigator.pushReplacementNamed(context, '/exercises');
        }
        else if(!_canGoToNext){
            setState(() {
              _currentAns = receiveText.trim();
            });
            _checkAnswer();
        }
        else{
          con_cancel();
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }).onDone(() {
        print("Disconnected from device");
        // Do something when the device is disconnected...
      });
    }
  }

  void _showSnackBar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
    ));
  }

  Future<void> test_func(String data) async {
    BL instan = BL(context: context, connection: connection);
    await instan.sendData(data);
    print(connection);
  }

  Future<void> con_cancel() async {
    await connection!.finish();
  }

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
        final int firstLetter = exercise.firstLetter;

        if (lastLetter <= 1 || firstLetter >= 30) {
          print('Error: Invalid lastLetter value');
          return;
        }

        final List<int> randomIndices = [];
        final List<LetterModel> fetchedLetters = [];
        // final String userId = FirebaseAuth.instance.currentUser!.uid;

        while (randomIndices.length < exercise.noOfQs) {
          final int randomIndex =
              Random().nextInt(lastLetter - firstLetter + 1) + firstLetter;

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
          playAudio(_testLetters[0].testAudioPath);
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
    playAudio(_testLetters[_currentPage].testAudioPath);
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
    _connectToBluetooth();
  }

  void playAudio(String audioPath) async {
    print('PLAYING ');
    // final duration = await player.setAsset(
    //     'assets/audios/letter-1.wav');
    final duration = await player.setUrl(audioPath);
    await player.play();
    print('DONE');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MinAppBar(title: 'Practice', connection: connection),
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
                                            _testLetters.length - 1) {
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
                                                    _testLetters.length - 1 ||
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
