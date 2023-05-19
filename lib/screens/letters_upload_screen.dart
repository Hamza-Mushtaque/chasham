import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:chasham_fyp/models/letter_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class LetterUploadScreen extends StatefulWidget {
  @override
  _LetterUploadScreenState createState() => _LetterUploadScreenState();
}

class _LetterUploadScreenState extends State<LetterUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _loadingMsg = null;
  bool _isError = false;
  late int _serialNo;
  late String _letter;
  late String _braille;
  late String _description;
  File? _testAudioFile;
  File? _lessonAudioFile;
  late String _selectedDropDownOption;

  final List<String> _dropDownOptions = ['1 letter', '2 letter'];

  @override
  void initState() {
    super.initState();
    _selectedDropDownOption = _dropDownOptions[0];
  }

  Future<void> _handleTestAudioFileSelection() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _testAudioFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _handleLessonAudioFileSelection() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _lessonAudioFile = File(result.files.single.path!);
      });
    }
  }

  void _onFormSubmitted() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _loadingMsg = 'Saving Letter ... ';
      });

      final letterModel = LetterModel(
        serialNo: _serialNo,
        letter: _letter,
        braille: _braille,
        description: _description,
        testAudioPath:
            _testAudioFile != null ? await uploadFile(_testAudioFile!) : "",
        lessonAudioPath:
            _lessonAudioFile != null ? await uploadFile(_lessonAudioFile!) : "",
        letterType: _selectedDropDownOption,
      );

      try {
        await FirebaseFirestore.instance
            .collection('letters')
            .add(letterModel.toJson());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'Letter uploaded successfully!',
            style: TextStyle(color: Colors.green),
          )),
        );
        setState(() {
          _loadingMsg = null;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error uploading letter: $error',
                  style: TextStyle(color: Colors.red))),
        );
        setState(() {
          _loadingMsg = error.toString();
          _isError = true;
        });
      }
    }
  }

  Future<String> uploadFile(File file) async {
    try {
      String fileName = path.basename(file.path);
      Reference ref =
          FirebaseStorage.instance.ref().child("letters/$_serialNo/$fileName");
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
          title: Text('Letter Upload'),
        ),
        body: SingleChildScrollView(
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
                    )),
                  ))
                : (Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Serial No.'),
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
                              SizedBox(height: 16.0),
                              TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Letter'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a letter';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _letter = value!;
                                },
                              ),
                              SizedBox(height: 16.0),
                              TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Braille'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter braille';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _braille = value!;
                                },
                              ),
                              SizedBox(height: 16.0),
                              TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Description'),
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
                              SizedBox(height: 16.0),
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
                              SizedBox(height: 16.0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text('Test Audio'),
                                  ),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    flex: 3,
                                    child: ElevatedButton(
                                      onPressed: _handleTestAudioFileSelection,
                                      child: Text('Select File'),
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      _testAudioFile?.path ??
                                          'No file selected',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text('Lesson Audio'),
                                  ),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    flex: 3,
                                    child: ElevatedButton(
                                      onPressed:
                                          _handleLessonAudioFileSelection,
                                      child: Text('Select File'),
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      _lessonAudioFile?.path ??
                                          'No file selected',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  _onFormSubmitted();
                                },
                                child: const Text('Submit'),
                              ),
                            ]))))));
  }
}
