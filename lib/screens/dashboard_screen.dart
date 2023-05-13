import 'package:chasham_fyp/major_app_bar.dart';
import 'package:chasham_fyp/components/component_btn_widget.dart';
import 'package:chasham_fyp/components/progress_detail_widget.dart';
import 'package:chasham_fyp/models/progress_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MajorAppBar(title: 'ڈیش بورڈ'),
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
                                    iconPath: 'assets/svgs/test-icon.svg',
                                    title: 'ٹیسٹ',
                                    color: Colors.lightBlue,
                                    value: _userProgress!
                                        .exercisesCompleted.length),
                                ProgressDetailWidget(
                                    iconPath: 'assets/svgs/exercise-icon.svg',
                                    title: 'مشق',
                                    color: Colors.green,
                                    value: _userProgress!
                                        .exercisesCompleted.length),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: const [
                                ComponentBtnWidget(
                                    label: 'سبق سیکھیں',
                                    svgIconPath: 'assets/svgs/lesson-icon.svg',
                                    link: '/lessons'),
                                ComponentBtnWidget(
                                    label: 'مشق حل کریں',
                                    svgIconPath: 'assets/svgs/test-icon.svg',
                                    link: '/practice')
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
