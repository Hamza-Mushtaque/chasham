import 'dart:convert';
import 'dart:typed_data';

import 'package:chasham_fyp/drawer_main.dart';
import 'package:chasham_fyp/components/component_btn_widget.dart';
import 'package:chasham_fyp/components/progress_detail_widget.dart';
import 'package:chasham_fyp/models/progress_model.dart';
import 'package:chasham_fyp/services/bluetooth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  double progress = 0.9;
  late AnimationController _controller;
  late Animation<double> _animation;
  int lessonProg = 9;
  ProgressModel? _userProgress;
  String? _loadingMsg = null;
  bool _isError = false;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  BluetoothConnection? connection;

  void _connectToBluetooth() async {
    try {
      // Get a list of all available Bluetooth devices
      List<BluetoothDevice> devices =
          await FlutterBluetoothSerial.instance.getBondedDevices();

      // Display a dialog with the list of devices to choose from
      selectedDevice = await showDialog<BluetoothDevice>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Select a device to connect"),
            content: SingleChildScrollView(
              child: ListBody(
                children: devices.map((device) {
                  return ListTile(
                    title: Text(device.name!),
                    subtitle: Text(device.address),
                    onTap: () {
                      Navigator.of(context).pop(device);
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      );

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
        if (receiveText.trim() == "NEXT".trim()) {
          con_cancel();
          Navigator.pushNamed(context, '/lessons');
        } else if (receiveText.trim() == "PREVIOUS".trim()) {
          con_cancel();
          Navigator.pushNamed(context, '/exercises');
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
  }

  Future<void> con_cancel() async {
    await connection!.finish();
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProgress();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();
    _animation = Tween<double>(
      begin: 0.0,
      end: progress,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fetchUserProgress() async {
    try {
      setState(() {
        _loadingMsg = 'Fetching User Progress ... ';
      });
      print('FETCHING - - - ');
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userProgressDoc =
          FirebaseFirestore.instance.collection('progress').doc(userId);
      final progressSnapshot = await userProgressDoc.get();

      if (progressSnapshot.exists) {
        // Progress document exists, fetch and set the progress state variable
        final progressData = progressSnapshot.data() as Map<String, dynamic>;
        final progress = ProgressModel.fromJson(progressData);
        setState(() {
          _userProgress = progress;
        });
        print('EXISTS - - - ');
      } else {
        // Progress document doesn't exist, create a new document and set the progress state variable
        final newProgress = ProgressModel(
            userId: userId,
            lessonCompleted: [],
            exercisesCompleted: [],
            rank: 'Beginner');
        await userProgressDoc.set(newProgress.toJson());
        setState(() {
          _userProgress = newProgress;
        });
        print('NOT EXISTS - - - ');
      }
      setState(() {
        _loadingMsg = null;
      });
    } catch (error) {
      // Handle any errors that occurred during the fetch
      print('Error fetching user progress: $error');

      setState(() {
        _loadingMsg = error as String;
        _isError = true;
      });

      // Set an error state or handle the error as per your requirement
    }
  }

  void handleDrawer() {
    // Scaffold.of(_scaffoldkey.currentContext!).openDrawer();
    _scaffoldkey.currentState!.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/svgs/logo-color.svg',
            width: 48,
          ),
          onPressed: () {},
        ),
        title: Text(
          " ڈیش بورڈ",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'NastaliqKasheeda',
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _connectToBluetooth();
            },
            icon: Icon(
              Icons.bluetooth,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () {
              handleDrawer();
            },
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
      drawer: DrawerMain(),
      body: SafeArea(
          child: _loadingMsg == null
              ? (SingleChildScrollView(
                  child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'اسباق',
                            style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'NastaliqKasheeda',
                                fontWeight: FontWeight.w800),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            height: 200,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 148,
                                  height: 148,
                                  child: AnimatedBuilder(
                                    animation: _animation,
                                    builder: (context, child) {
                                      return CircularProgressIndicator(
                                        // value: _animation.value,
                                        value: _userProgress!
                                                .lessonCompleted.length /
                                            10,
                                        strokeWidth: 16,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                Color.fromARGB(
                                                    255, 70, 68, 68)),
                                        backgroundColor: const Color.fromARGB(
                                            255, 206, 204, 204),
                                      );
                                    },
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${_userProgress!.lessonCompleted.length}/10',
                                      style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      'مکمل ہوئے',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'NastaliqKasheeda',
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'پراگریس رپورٹ',
                            style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'NastaliqKasheeda',
                                fontWeight: FontWeight.w800),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ProgressDetailWidget(
                                    iconPath: 'assets/svgs/lesson-icon.svg',
                                    title: 'اسباق',
                                    color: Colors.yellow,
                                    value:
                                        _userProgress!.lessonCompleted.length),
                                ProgressDetailWidget(
                                    iconPath: 'assets/svgs/exercise-icon.svg',
                                    title: 'مشق',
                                    color: Colors.green,
                                    value: _userProgress!
                                        .exercisesCompleted.length),
                                const SizedBox(height: 4),
                                Text(_userProgress!.rank.toUpperCase(),
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontSize: 18))
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                ComponentBtnWidget(
                                  label: 'سبق سیکھیں',
                                  svgIconPath: 'assets/svgs/lesson-icon.svg',
                                  link: '/lessons',
                                  connection: connection,
                                ),
                                ComponentBtnWidget(
                                  label: 'مشق حل کریں',
                                  svgIconPath: 'assets/svgs/test-icon.svg',
                                  link: '/exercises',
                                  connection: connection,
                                ),
                                ComponentBtnWidget(
                                  label: 'تیاری کریں',
                                  svgIconPath: 'assets/svgs/exercise-icon.svg',
                                  link: '/practice',
                                  connection: connection,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/lesson-create');
                              },
                              child: const Text('Create Lesson',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white))),
                          const SizedBox(
                            height: 8,
                            width: 8,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/letter-upload');
                              },
                              child: const Text('Upload Letter',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white))),
                          const SizedBox(
                            height: 8,
                            width: 8,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/exercise-create');
                              },
                              child: const Text('Create Exercie',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)))
                        ],
                      ))))
              : (Container(
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
                ))),
    );
  }
}
