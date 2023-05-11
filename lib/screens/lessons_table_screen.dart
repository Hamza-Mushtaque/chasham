import 'package:chasham_fyp/min_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../components/lesson_card_widget.dart';
import '../models/lesson_model.dart';

class LessonTableScreen extends StatefulWidget {
  @override
  _LessonTableScreenState createState() => _LessonTableScreenState();
}

class _LessonTableScreenState extends State<LessonTableScreen> {
  final PageController _pageController = PageController();
  String? _loadingMsg = 'Fetching Lessons  ... ';
  bool _isError = false;

  List<LessonModel> lessons =
      []; // Populate this list with your fetched lessons

  Future<void> _fetchLessons() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('lessons').get();
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
    } catch (error) {
      print('Error fetching lessons: $error');
      setState(() {
        _loadingMsg = error as String?;
        _isError = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLessons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MinAppBar(title: 'Lessons'),
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
                                itemCount: lessons.length,
                                itemBuilder: (context, index) {
                                  LessonModel lesson = lessons[index];

                                  return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: LessonCardWidget(
                                      title: lesson.title,
                                      brailleImgPath: lesson.brailleImg,
                                      letterImgPath: lesson.letterImg,
                                      description: lesson.description,
                                      lessonId: lesson.lessonId!,
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
                            Positioned(
                              right: 16,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios),
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
                          ],
                        ),
                      ],
                    ))),
        ),
      ),
    );
  }
}
