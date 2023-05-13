import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:chasham_fyp/models/lesson_model.dart';
import 'package:chasham_fyp/models/letter_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class CreateLessonScreen extends StatefulWidget {
  const CreateLessonScreen({Key? key}) : super(key: key);

  @override
  _CreateLessonScreenState createState() => _CreateLessonScreenState();
}

class _CreateLessonScreenState extends State<CreateLessonScreen> {
  String? _loadingMsg = 'Creating Environemt for Form ... ';
  bool _isError = false;
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late int _serialNo;
  File? _brailleImgFile;
  File? _titleImgFile;
  List<int> _selectedSerialNos = [];
  List<LetterModel> _letters = [];

  // Example list of available serial numbers
  final List<int> _availableSerialNos = [1, 2, 3, 4, 5, 6];

  Future<void> _handleBrailleImgFileSelection() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _brailleImgFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _handleTitleImgFileSelection() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _titleImgFile = File(result.files.single.path!);
      });
    }
  }

  void _handleCreateLesson() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _loadingMsg = 'Creating Lesson in Firebase ... ';
      });

      // Create a list of selected letter models
      List<LetterModel> selectedLetters = _selectedSerialNos
          .map((serialNo) => _letters.firstWhere(
                (letter) => letter.serialNo == serialNo,
              ))
          .toList();

      final lessonModel = LessonModel(
        serialNo: _serialNo,
        title: _title,
        description: _description,
        letterImg:
            _titleImgFile != null ? await uploadFile(_titleImgFile!) : "",
        brailleImg:
            _brailleImgFile != null ? await uploadFile(_brailleImgFile!) : "",
        letters: selectedLetters,
      );

      try {
        await FirebaseFirestore.instance
            .collection('lessons')
            .add(lessonModel.toJson());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lesson created successfully!',
              style: TextStyle(color: Colors.green),
            ),
          ),
        );

        setState(() {
          _loadingMsg = null;
          _isError = true;
        });
      } catch (error) {
        setState(() {
          _loadingMsg = error as String?;
          _isError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error creating lesson: $error',
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      }
    }
  }

  void _fetchLetters() {
    // Fetch the letters from Firestore or any other data source
    // and assign them to the _letters list.
    // Example:
    FirebaseFirestore.instance
        .collection('letters')
        .orderBy('serialNo')
        .get()
        .then((QuerySnapshot snapshot) {
      List<LetterModel> fetchedLetters = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return LetterModel.fromJson(data);
      }).toList();

      setState(() {
        _letters = fetchedLetters;
        _loadingMsg = null;
      });
    }).catchError((error) {
      print('Error fetching letters: $error');
      setState(() {
        _isError = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchLetters();
  }

  Future<String> uploadFile(File file) async {
    try {
      String fileName = path.basename(file.path);
      Reference ref = FirebaseStorage.instance.ref().child("lessons/$fileName");
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading letter: $e')),
      );
      throw Exception('Failed to upload file.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create Lesson'),
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _loadingMsg != null
                ? (Center(
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
                  )))
                : (Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Serial No.'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a letter';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _serialNo = int.parse(value!);
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Title'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _title = value!;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Description'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _description = value!;
                          },
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text('Title Image'),
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              flex: 3,
                              child: ElevatedButton(
                                onPressed: _handleTitleImgFileSelection,
                                child: Text('Select File'),
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              flex: 5,
                              child: Text(
                                _titleImgFile?.path ?? 'No file selected',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text('Braille Image'),
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              flex: 3,
                              child: ElevatedButton(
                                onPressed: _handleBrailleImgFileSelection,
                                child: Text('Select File'),
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              flex: 5,
                              child: Text(
                                _brailleImgFile?.path ?? 'No file selected',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Select Serial Numbers for Letters'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _letters.map((letter) {
                            return ChoiceChip(
                              label: Text(letter.serialNo.toString()),
                              selected:
                                  _selectedSerialNos.contains(letter.serialNo),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected &&
                                      _selectedSerialNos.length < 3) {
                                    _selectedSerialNos.add(letter.serialNo);
                                  } else if (!selected) {
                                    _selectedSerialNos.remove(letter.serialNo);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              print(_formKey.currentState!);
                              _handleCreateLesson();
                              // TODO: Save or upload the new lesson to the database

                              // Navigator.pop(context); // Navigate back after saving
                            }
                          },
                          child: const Text('Save Lesson'),
                        ),
                      ],
                    )))));
  }
}
