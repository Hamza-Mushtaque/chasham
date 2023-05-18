import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:chasham_fyp/components/exercise_complete_widget.dart';
import 'package:chasham_fyp/components/practice_complete_widget.dart';
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

class LetterPracticeScreen extends StatefulWidget {
  // final String? exerciseSerial;

  @override
  _LetterPracticeScreenState createState() => _LetterPracticeScreenState();
}

class _LetterPracticeScreenState extends State<LetterPracticeScreen> {
  final PageController _pageController = PageController();
  final player = AudioPlayer();
  String? _loadingMsg = 'Fetching Practice Data  ... ';
  bool _isError = false;
  int _currentPage = 0;
  bool _canGoToNext = false;
  bool _practiceComplete = false;
  String _currentAns = '000000';
  String _answerRemarks = '';
  List<LetterModel> _practiceLetters = [];

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
      _showSnackBar("Error connecting to Bluetooth device: $exception", false);
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
        if (flag) {
          con_cancel();
          flag = false;
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

  void _fetchPracticeLetters() {
    setState(() {
      _loadingMsg = 'Fetching Exercise Data  ... ';
    });

    final List<int> randomIndices = [];
    final List<LetterModel> fetchedLetters = [];

    while (randomIndices.length < 10) {
      final int randomIndex = Random().nextInt(30) + 1;

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
        _practiceLetters = fetchedLetters;
        _loadingMsg = null;
      });
      print(_practiceLetters);
    }).catchError((error) {
      print('Error fetching practice letters: $error');
      setState(() {
        _loadingMsg = error.toString();
        _isError = true;
      });
    });
  }

  void _handlePageChange(int index) {
    setState(() {
      _currentPage = index;
      _canGoToNext = false;
      _currentAns = '000000';
    });
    playAudio(_practiceLetters[_currentPage].testAudioPath);
  }

  void _checkAnswer() {
    if (_currentAns == _practiceLetters[_currentPage].braille) {
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
  void initState() {
    super.initState();
    // _fetchLesson(ModalRoute.of(context)!.settings.arguments as String);

    print("Serial No");
    _fetchPracticeLetters();
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
                      child: _practiceComplete == false
                          ? (Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const SizedBox(height: 48),
                                SizedBox(
                                  height: 300,
                                  child: PageView.builder(
                                    reverse: true,
                                    controller: _pageController,
                                    onPageChanged: _handlePageChange,
                                    itemCount: _practiceLetters.length,
                                    itemBuilder: (context, index) {
                                      final letter = _practiceLetters[index];
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
                                            _practiceLetters.length - 1) {
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
                                                    _practiceLetters.length -
                                                        1 ||
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
                                                _practiceLetters.length - 1)
                                        ? (const Text(''))
                                        : ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                _practiceComplete = true;
                                              });
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
                                                'تیاری مکمل',
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
                          : PracticeCompleteWidget()),
                ))),
    );
  }
}
