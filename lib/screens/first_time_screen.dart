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
  TextEditingController _dateController = TextEditingController();
  UserModel? _user = null;
  String _userName = '';
  DateTime? _userDob;
  String _profileImgUrl = '';

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
    }
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
            CircleAvatar(
              backgroundImage: NetworkImage(_user!.profileImage),
              radius: 50,
            ),
            SizedBox(height: 16.0),
            TextFormField(
              initialValue: _userName,
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
              controller: _dateController,
              readOnly: true, // Prevents manual editing of the text field
              onTap: () {
                _selectDate(
                    context); // Show the date picker when the text field is tapped
              },
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
