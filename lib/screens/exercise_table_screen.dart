import 'package:chasham_fyp/components/exercise_card_widget.dart';
import 'package:chasham_fyp/models/exercise_model.dart';
import 'package:chasham_fyp/models/progress_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExerciseTableScreen extends StatefulWidget {
  @override
  _ExerciseTableScreenState createState() => _ExerciseTableScreenState();
}

class _ExerciseTableScreenState extends State<ExerciseTableScreen> {
  List<ExerciseModel> availableExercises = [];
  List<int> completedLessons = [];

  String? _loadingMsg = 'Fetching Exercises  ... ';
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchAvailableExercises();
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
