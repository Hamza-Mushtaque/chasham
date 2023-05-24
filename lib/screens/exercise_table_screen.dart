import 'dart:convert';
import 'dart:typed_data';

import 'package:chasham_fyp/components/exercise_card_widget.dart';
import 'package:chasham_fyp/models/exercise_model.dart';
import 'package:chasham_fyp/models/progress_model.dart';
import 'package:chasham_fyp/services/bluetooth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:just_audio/just_audio.dart';

class ExerciseTableScreen extends StatefulWidget {
  @override
  _ExerciseTableScreenState createState() => _ExerciseTableScreenState();
}

class _ExerciseTableScreenState extends State<ExerciseTableScreen> {
  List<ExerciseModel> availableExercises = [];
  List<int> completedLessons = [];
  int _currentIndex = 0;
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

        if(receiveText.trim() == "NEXT".trim() ){
          if(_currentIndex < (availableExercises.length -1)){
              _handlePageChange(_currentIndex+1);
          }
        }
        else if(receiveText.trim() == "PREVIOUS".trim()){
          if(_currentIndex > 0){
            _handlePageChange(_currentIndex-1);
          }
        }
        else{
          con_cancel();
        Navigator.pushReplacementNamed(context, '/exercise',
            arguments: {'id': availableExercises[_currentIndex].serialNo.toString()});
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

  String? _loadingMsg = 'Fetching Exercises  ... ';
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchAvailableExercises();
        _connectToBluetooth();
  }

  Future<void> _fetchAvailableExercises() async {
    try {
      setState(() {
        _loadingMsg = 'Fetching Exercises  ... ';
      });
      String userId = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot progressSnapshot = await FirebaseFirestore.instance
          .collection('progress')
          .doc(userId)
          .get();

      ProgressModel progress = ProgressModel.fromJson(
          progressSnapshot.data() as Map<String, dynamic>);
      setState(() {
        completedLessons = progress.lessonCompleted;
      });

      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('exercises').get();

      List<ExerciseModel> fetchedExercises = snapshot.docs
          .map((doc) =>
              ExerciseModel.fromJson(doc.data() as Map<String, dynamic>))
          .where((exercise) => completedLessons.contains(exercise.serialNo))
          .toList();

      setState(() {
        availableExercises = fetchedExercises;
        _loadingMsg = null;
      });
    } catch (error) {
      print('Error fetching exercises: $error');
      setState(() {
        _loadingMsg = error.toString();
        _isError = true;
      });
    }
  }

   void playAudio(String lessonAudioPath) async {
    print('PLAYING ');
    // final duration = await player.setAsset(
    //     'assets/audios/letter-1.wav');
    final duration = await player.setUrl(lessonAudioPath);
    await player.play();
    print('DONE');
  }

  void _handlePageChange(int index) {
    setState(() {
      _currentIndex = index;
    });
    playAudio(availableExercises[_currentIndex].exerciseAudioPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise Table'),
      ),
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
              : (Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'مشق کا انتخاب کریں',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NooriNastaliq',
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: availableExercises.length,
                          itemBuilder: (context, index) {
                            ExerciseModel exercise = availableExercises[index];
                            return ExerciseCardWidget(
                              title: exercise.title,
                              description: exercise.description,
                              serialNo: exercise.serialNo,
                              connection: connection,
                              isActive: _currentIndex == index,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ))),
    );
  }
}
