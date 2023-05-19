import 'dart:convert';
import 'dart:typed_data';

import 'package:chasham_fyp/min_app_bar.dart';
import 'package:chasham_fyp/services/bluetooth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:just_audio/just_audio.dart';

import '../components/lesson_card_widget.dart';
import '../models/lesson_model.dart';

class LessonTableScreen extends StatefulWidget {
  @override
  _LessonTableScreenState createState() => _LessonTableScreenState();
}

class _LessonTableScreenState extends State<LessonTableScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _loadingMsg = 'Fetching Lessons  ... ';
  bool _isError = false;
  final player = AudioPlayer();

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

        if (receiveText.trim() == "NEXT".trim()) {
          if (_currentPage < (lessons.length - 1)) {
            _handlePageChange(_currentPage + 1);
            _pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        } else if (receiveText.trim() == "PREVIOUS".trim()) {
          if (_currentPage > 0) {
            _handlePageChange(_currentPage - 1);
            _pageController.previousPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        } else {
          con_cancel();
          Navigator.pushReplacementNamed(context, '/lesson',
              arguments: {'id': lessons[_currentPage].serialNo.toString()});
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

  List<LessonModel> lessons =
      []; // Populate this list with your fetched lessons

  Future<void> _fetchLessons() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('lessons')
          .orderBy('serialNo')
          .get();
      print('Waiting');
      List<LessonModel> fetchedLessons = snapshot.docs.map((doc) {
        LessonModel lesson =
            LessonModel.fromJson(doc.data() as Map<String, dynamic>);
        lesson.lessonId = doc.id; // Assign the document ID to the lesson model
        return lesson;
      }).toList();
      print('Fetched');
      setState(() {
        lessons = fetchedLessons;
        _loadingMsg = null;
      });
      playAudio(lessons[0].lessonAudioPath);
    } catch (error) {
      print('Error fetching lessons: $error');
      setState(() {
        _loadingMsg = error.toString();
        _isError = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLessons();
    _connectToBluetooth();
  }

  void _handlePageChange(int index) {
    setState(() {
      _currentPage = index;
    });

    print(_currentPage);
    playAudio(lessons[_currentPage].lessonAudioPath);
    // _passLetterToDevice(index);
    // playAudio();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MinAppBar(title: 'Lessons', connection: connection),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(16),
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
                  : (Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(height: 48),
                        Text(
                          'سبق کا انتخاب کریں',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NooriNastaliq',
                          ),
                        ),
                        SizedBox(height: 16),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 300,
                              child: PageView.builder(
                                controller: _pageController,
                                reverse: true,
                                itemCount: lessons.length,
                                onPageChanged: _handlePageChange,
                                itemBuilder: (context, index) {
                                  LessonModel lesson = lessons[index];

                                  return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: LessonCardWidget(
                                      lessonSerial: lesson.serialNo.toString(),
                                      title: lesson.title,
                                      brailleImgPath: lesson.brailleImg,
                                      letterImgPath: lesson.letterImg,
                                      description: lesson.description,
                                      lessonId: lesson.lessonId!,
                                      connection: connection,
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
                                  if (_pageController.hasClients) {
                                    if (_pageController.page! <
                                        lessons.length - 1) {
                                      _pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                            Positioned(
                              right: 16,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios),
                                onPressed: () {
                                  if (_pageController.hasClients) {
                                    if (_pageController.page! > 0) {
                                      _pageController.previousPage(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ))),
        ),
      ),
    );
  }
}
