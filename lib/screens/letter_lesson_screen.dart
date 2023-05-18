import 'dart:convert';
import 'dart:typed_data';

// import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:chasham_fyp/components/lesson_complete_widget.dart';
import 'package:chasham_fyp/min_app_bar.dart';
import 'package:chasham_fyp/models/lesson_model.dart';
import 'package:chasham_fyp/models/progress_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

import '../components/letter_card_widget.dart';
import '../services/bluetooth_services.dart';

class LetterLessonScreen extends StatefulWidget {
  final String? lessonSerial;

  LetterLessonScreen({required this.lessonSerial});

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
  bool _lessonComplete = false;
  LessonModel? _currentLesson;

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

          if(receiveText.trim() == "NEXT".trim() ){
          if(_currentPage < (_currentLesson!.letters.length - 1)){
              _handlePageChange(_currentPage+1);
              _pageController.nextPage(
              duration:
                  const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
              
          }
          else if(_currentLesson == _currentLesson!.letters.length-1){
            setState(() {
              _lessonComplete = true;
            });
          }
          else if(_lessonComplete == true){
          con_cancel();
          Navigator.pushReplacementNamed(context, '/lesson',
          arguments: {'id': (_currentLesson!.serialNo + 1).toString()});
          }
        }
        else if(receiveText.trim() == "PREVIOUS".trim()){
          if(_currentPage > 0){
            _handlePageChange(_currentPage-1);
            _pageController.previousPage(
              duration:
                  const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
        else if(_lessonComplete){
         Navigator.pushReplacementNamed(context, '/exercises'); 
        }
        else{

          if(_lessonComplete){
            con_cancel();
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
          else{
            playAudio(_currentLesson!.letters[_currentPage].lessonAudioPath);
          }
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
    BL instan = BL(context: context,connection: connection);
    await instan.sendData(data);
     print(connection);
  }

  Future<void> con_cancel() async {
    await connection!.finish();
  }
  

  Future<void> _fetchCurrentLesson() async {
    if (widget.lessonSerial == null) {
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
          .where('serialNo', isEqualTo: int.parse(widget.lessonSerial!))
          .limit(1)
          .get()
          .then((querySnapshot) => querySnapshot.docs.first);

      if (snapshot.exists) {
        setState(() {
          _currentLesson =
              LessonModel.fromJson(snapshot.data() as Map<String, dynamic>)
                ..lessonId = snapshot.id; // set the lesson ID
          _loadingMsg = null;
        });
        print(_currentLesson!.toJson());
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
        _loadingMsg = error.toString();
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
    test_func(_currentLesson!.letters[index].braille);
  }

  void playAudio(String lessonAudioPath) async {
    print('PLAYING ');
    // final duration = await player.setAsset(
    //     'assets/audios/letter-1.wav');
    final duration = await player.setUrl(lessonAudioPath);
    await player.play();
    print('DONE');
  }

  void playLessonComplete() async {
    print('PLAYING ');
    // final duration = await player.setAsset(
    //     'assets/audios/letter-1.wav');
    final duration = await player.setAsset('assets/audios/lesson-complete.wav');
    await player.play();
    print('DONE');
  }

  void _updateLessonProgress() async {
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
        if (progress.lessonCompleted.contains(_currentLesson!.serialNo)) {
          // Lesson already completed, show a message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'You have already completed this lesson.',
                style: TextStyle(color: Colors.green),
              ),
            ),
          );
        } else {
          // Lesson not completed, update the progress
          progress.lessonCompleted.add(_currentLesson!.serialNo);

          await FirebaseFirestore.instance
              .collection('progress')
              .doc(userId)
              .update(progress.toJson());
        }
        setState(() {
          _lessonComplete = true;
          _loadingMsg = null;
        });
        playLessonComplete();
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
    print(widget.lessonSerial);
    _fetchCurrentLesson();
    _connectToBluetooth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MinAppBar(title: 'Lesson', connection: connection),
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
                      child: _lessonComplete == false
                          ? (Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const SizedBox(height: 48),
                                Text(
                                  _currentLesson!.title,
                                  style: const TextStyle(
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
                                      final letter =
                                          _currentLesson!.letters[index];
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (_currentPage ==
                                                _currentLesson!.letters.length -
                                                    1 ||
                                            _lessonBegan == false) {
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
                                                    _currentLesson!
                                                            .letters.length -
                                                        1 ||
                                                _lessonBegan == false
                                            ? Colors.grey
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
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
                                                'سبق کا آغاز کریں',
                                                style: TextStyle(
                                                    fontFamily:
                                                        'NastaliqKasheeda',
                                                    fontSize: 18,
                                                    color: Colors.white),
                                              ))),
                                    if (_currentPage ==
                                        _currentLesson!.letters.length - 1)
                                      ElevatedButton(
                                          onPressed: () {
                                            _updateLessonProgress();
                                          },
                                          child: const Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Text(
                                                'سبق مکمل',
                                                style: TextStyle(
                                                    fontFamily:
                                                        'NastaliqKasheeda',
                                                    fontSize: 18,
                                                    color: Colors.white),
                                              ))),
                                    IconButton(
                                      onPressed: () {
                                        if (_currentPage == 0) {
                                          null;
                                        } else {
                                          _pageController.previousPage(
                                            duration: const Duration(
                                                milliseconds: 400),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      },
                                      icon: Icon(
                                        Icons.arrow_right_rounded,
                                        color: _currentPage == 0
                                            ? Colors.grey
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                      ),
                                      disabledColor: Colors.grey,
                                      color: Theme.of(context).primaryColor,
                                      iconSize: 84,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            ))
                          : (LessonCompleteWidget(
                              nextLessonSerialNo: _currentLesson!.serialNo + 1,
                            ))))),
    );
  }
}
