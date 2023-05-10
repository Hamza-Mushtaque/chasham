import 'dart:io';

import 'package:chasham_fyp/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class FirstTimeScreen extends StatefulWidget {
  @override
  _FirstTimeScreenState createState() => _FirstTimeScreenState();
}

class _FirstTimeScreenState extends State<FirstTimeScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  UserModel? user = null;
  String _userName = '';
  DateTime? _userDob;
  String _profileImgUrl = '';
  
  get path => null;

  Future<String> _uploadNewProfileImg() async {

    try {
      final file = File(_profileImgUrl);
      final fileName = path.basename(_profileImgUrl);
      //final destination = 'profile_pics/$_userId/$fileName';

      // Upload image to Firebase storage
  final ref = firebase_storage.FirebaseStorage.instance
      .ref()
      .child('users')
      .child(FirebaseAuth.instance.currentUser!.uid)
      .child(fileName);
    
  // final metadata = firebase_storage.SettableMetadata(
  //   contentType: 'image/jpeg',
  // );

  final uploadTask = ref.putFile(file);

  final snapshot = await uploadTask.whenComplete(() => print('Image uploaded to storage'));

  return await snapshot.ref.getDownloadURL();

    //   // Get download URL of uploaded image
    //   final downloadUrl = await ref.getDownloadURL();

    //   // Save download URL to Firestore
    //   final userRef =
    //       FirebaseFirestore.instance.collection('users').doc(_userId);
    //   await userRef.update({'profileImgUrl': downloadUrl});
     } catch (e) {
       print(e);
       throw Exception("Image not Found");
     }
  }

  Future<void> _pickImage() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
  );
  if (result != null) {
    setState(() {
      _profileImgUrl = result.files.single.path!;
    });
  }

  final imageUrl = await _uploadNewProfileImg();
  setState(() {
    _profileImgUrl =  imageUrl;
  });
  

  }

   Future<void> _get_user() async {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      print("Error in 1");
      print(userDoc.data());

      setState(() {
      print("in set state");
      print(userDoc.data());
      user = UserModel.fromJson(userDoc.data() ?? {} );
      print("in set state");
      _userName = user!.name;
      print("after username");
      _profileImgUrl = user!.profileImage;
      _userDob = user!.dateOfBirth;
        
      });

      print("Error in 1 after");
    }
  

  @override
  void initState() {
    super.initState();
    _get_user();
  }

  

  void _saveUserData() {
    print("error in 3");
    // Save the user data to Firestore.
    _db.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({
      'name': _userName.trim(),
      'dob': _userDob,
      'profileImageUrl': _profileImgUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    print("in build");
    return Scaffold(
      appBar: AppBar(
        title: Text('First Time Screen'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage:  NetworkImage(_profileImgUrl),
              radius: 50,
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              initialValue: _userName,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              initialValue: _userDob.toString(),
              decoration: InputDecoration(
                labelText: 'Date of Birth',
              ),
            ),
            SizedBox(height: 32.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _saveUserData();
                  Navigator.pushReplacementNamed(context, '/dashboard');
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
