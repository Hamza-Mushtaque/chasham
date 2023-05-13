import 'package:chasham_fyp/models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class FirstTimeScreen extends StatefulWidget {
  @override
  _FirstTimeScreenState createState() => _FirstTimeScreenState();
}

class _FirstTimeScreenState extends State<FirstTimeScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  TextEditingController _dateController = TextEditingController();
  UserModel? _user = null;
  String _userName = '';
  DateTime? _userDob;
  String _profileImgUrl = '';
  bool _imgUpdated = false;

  Future<void> _get_user() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    print(userDoc.data());
    setState(() {
      _user = UserModel.fromJson(userDoc.data()!);
      _userName = _user!.name;
      _userDob = _user!.dateOfBirth;
      _profileImgUrl = _user!.profileImage;
    });
    print('After User Setting');
  }

  Future<void> _uploadImageFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        final file = File(result.files.single.path!);
        String fileName = path.basename(file.path);
        Reference ref = FirebaseStorage.instance.ref().child(
            "profile-pics/${FirebaseAuth.instance.currentUser!.uid}/$fileName");
        UploadTask uploadTask = ref.putFile(file);
        TaskSnapshot taskSnapshot = await uploadTask;

        setState(() {
          _imgUpdated = true;
        });

        String imageUrl = await taskSnapshot.ref.getDownloadURL();
        setState(() {
          _profileImgUrl = imageUrl;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'File Uploaded Successfully',
            style: TextStyle(color: Colors.greenAccent),
          ),
        ),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error uploading Files: $e',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _user!.dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _userDob = picked;
        _dateController.text = _userDob!
            .toString(); // Update the text field with the selected date
      });
    } else {
      setState(() {
        _userDob = DateTime.now();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _get_user();
  }

  Future<void> _saveUserData() async {
    try {
      // Update name
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'name': _userName});

      // Update profile image URL
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'profileImage': _profileImgUrl});

      // Update date of birth
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'dateOfBirth': _userDob});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User data saved successfully',
            style: TextStyle(color: Colors.greenAccent),
          ),
        ),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving user data: $e',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("in build");
    return Scaffold(
      appBar: AppBar(
        title: Text('First Time Screen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                _uploadImageFile();
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(_profileImgUrl),
                radius: 50,
              ),
            ),
            _imgUpdated ? const Text('* New Image Uploaded') : const Text(''),
            SizedBox(height: 16.0),
            TextFormField(
              initialValue: _user!.name,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
              onChanged: (value) => {
                setState(() {
                  _userName = value;
                })
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              readOnly: true,
              onTap: () {
                _selectDate(context);
              },
              decoration: InputDecoration(
                labelText: 'Date of Birth',
              ),
              initialValue: _userDob != null
                  ? DateFormat('yyyy-MM-dd').format(_userDob!)
                  : '',
            ),
            SizedBox(height: 32.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _saveUserData();
                  // Navigator.pushReplacementNamed(context, '/dashboard');
                },
                child: Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}