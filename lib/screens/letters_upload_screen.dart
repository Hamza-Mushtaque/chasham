import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class LetterUploadScreen extends StatefulWidget {
  const LetterUploadScreen({Key? key}) : super(key: key);

  @override
  _LetterUploadScreenState createState() => _LetterUploadScreenState();
}

class _LetterUploadScreenState extends State<LetterUploadScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _letterController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _brailleController = TextEditingController();
  PlatformFile? _audioFile;
  String? _selectedDropdownOption;
  String? _selectedFile;

  void _handleFilePicker() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _audioFile = result.files.single;
      });
    }
  }

  List<String> _dropdownOptions = ['1 letter', '2 letters'];

  @override
  void dispose() {
    _letterController.dispose();
    _descriptionController.dispose();
    _brailleController.dispose();
    super.dispose();
  }

  void _onFormSubmitted() {
    if (_formKey.currentState!.validate()) {
      final letter = _letterController.text;
      final description = _descriptionController.text;
      final braille = _brailleController.text;
      final option = _selectedDropdownOption;
      final audioPath = _audioFile;

      print('Letter: $letter');
      print('Description: $description');
      print('Braille: $braille');
      print('Option: $option');
      print('Audio Path: $audioPath');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Letter'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _letterController,
                  decoration: const InputDecoration(
                    labelText: 'Letter',
                    hintText: 'Enter letter',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a letter.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter description',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _brailleController,
                  decoration: const InputDecoration(
                    labelText: 'Braille',
                    hintText: 'Enter braille',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a braille.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedDropdownOption,
                  decoration: const InputDecoration(
                    labelText: 'Select letter type',
                    hintText: 'Select letter type',
                  ),
                  items: _dropdownOptions
                      .map((option) => DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDropdownOption = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _handleFilePicker();
                  },
                  child: const Text('Upload Audio File'),
                ),
                const SizedBox(height: 16),
                if (_selectedFile != null)
                  Text(
                    'Selected file: $_selectedFile',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _onFormSubmitted,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
