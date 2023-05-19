import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chasham_fyp/models/exercise_model.dart';

class CreateExercisePage extends StatefulWidget {
  @override
  _CreateExercisePageState createState() => _CreateExercisePageState();
}

class _CreateExercisePageState extends State<CreateExercisePage> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  int _serialNo = 0;
  String _description = '';
  int _lastLetter = 0;
  int _firstLetter = 0;
  int _noOfQs = 0;
  File? _exerciseAudioFile;
  late String _selectedDropDownOption;

  final List<String> _dropDownOptions = ['Normal', 'Advanced'];

  String? _loadingMsg = null;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _selectedDropDownOption = _dropDownOptions[0];
  }

  void _handleCreateExercise() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _loadingMsg = 'Creating Exercise';
      });

      try {
        // Create the ExerciseModel object
        final exercise = ExerciseModel(
          serialNo: _serialNo,
          title: _title,
          description: _description,
          firstLetter: _firstLetter,
          lastLetter: _lastLetter,
          noOfQs: _noOfQs,
          exerciseAudioPath: _exerciseAudioFile != null
              ? await uploadFile(_exerciseAudioFile!)
              : "",
          exerciseType: _selectedDropDownOption,
        );

        // Add the exercise to Firebase Firestore
        await FirebaseFirestore.instance
            .collection('exercises')
            .add(exercise.toJson());

        // Display a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Exercise created successfully!',
              style: TextStyle(color: Colors.green),
            ),
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          _loadingMsg = null;
        });
      } catch (error) {
        // Display an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create exercise. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          _loadingMsg = error.toString();
          _isError = true;
        });
      }
    }
  }

  Future<void> _handleExerciseAudioFileSelection() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _exerciseAudioFile = File(result.files.single.path!);
      });
    }
  }

  Future<String> uploadFile(File file) async {
    try {
      String fileName = path.basename(file.path);
      Reference ref =
          FirebaseStorage.instance.ref().child("exercises/$fileName");
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
          title: const Text('Create Exercise'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
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
                  ))))
                : Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Exercise Details',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Title',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the exercise title';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _title = value!;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Serial Number',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the serial number';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter a valid serial number';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _serialNo = int.parse(value!);
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the exercise description';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _description = value!;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'First Letter',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the first letter';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter a valid First letter';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _firstLetter = int.parse(value!);
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Last Letter',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the last letter';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter a valid last letter';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _lastLetter = int.parse(value!);
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    flex: 2,
                                    child: Text('Exercise Audio'),
                                  ),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    flex: 3,
                                    child: ElevatedButton(
                                      onPressed:
                                          _handleExerciseAudioFileSelection,
                                      child: Text('Select File'),
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      _exerciseAudioFile?.path ??
                                          'No file selected',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedDropDownOption,
                                decoration: const InputDecoration(
                                  labelText: 'Select letter type',
                                  hintText: 'Select letter type',
                                ),
                                items: _dropDownOptions
                                    .map((option) => DropdownMenuItem<String>(
                                          value: option,
                                          child: Text(option),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDropDownOption = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Number of Questions',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the number of questions';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter a valid number of questions';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _noOfQs = int.parse(value!);
                                },
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    print(_formKey.currentState!);
                                    // TODO: Save or upload the new lesson to the database
                                    _handleCreateExercise();
                                    // Navigator.pop(context); // Navigate back after saving
                                  }
                                },
                                child: const Text('Create Exercise'),
                              ),
                            ]))),
          ),
        ));
  }
}
