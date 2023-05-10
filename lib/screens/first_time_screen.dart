import 'package:chasham_fyp/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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


   Future<void> _get_user() async {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      print("Error in 1");
      print(userDoc.data());

      setState(() {
      print("in set state");
      user = UserModel.fromJson(userDoc.data()!);
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

  

  // void _saveUserData() {
  //   print("error in 3");
  //   // Save the user data to Firestore.
  //   _db.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({
  //     'name': _name.trim(),
  //     'dob': _dobController.text.trim(),
  //     'profileImageUrl': user.profileImage,
  //   });
  // }

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
              backgroundImage: NetworkImage(user!.profileImage),
              radius: 50,
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
                  // _saveUserData();
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
