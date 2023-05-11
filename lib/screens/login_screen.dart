import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen();

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<void> _signInWithGoogle() async {
    try {
      // Trigger the Google Authentication flow.
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        // Obtain the GoogleAuthentication object.
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new Firebase credential with the Google tokens.
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credential.
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        print(user);

        // Check if this is the first time the user is logging in
        final bool isNewUser =
            userCredential.additionalUserInfo?.isNewUser ?? false;

        print("NEW: $isNewUser");
        if (isNewUser) {
          print("Inside New User");
          // Create a new instance of the User model with data from the Google account
          final UserModel newUser = UserModel(
            name: user?.displayName ?? '',
            profileImage: user?.photoURL ?? '',
          );

          print(newUser);

          // Save the new user instance to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .set(newUser.toJson());

          // Navigate to the first time screen after successful login.
          Navigator.pushNamed(context, '/doashboard');
        } else {
          // Navigate to dashboard screen as user is already signed in.
          // Navigator.pushReplacementNamed(context, '/dashboard');
          Navigator.pushNamed(context, '/dashboard');
        }
      }
    } catch (error) {
      print(error);
      // Handle sign-in errors such as user canceling the sign-in flow
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(
          'Error signing in with Google: $error',
          style: TextStyle(color: Colors.black),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          // decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo and label at the top
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/svgs/logo-color.svg',
                      width: 150,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    // Welcome label
                    const Text(
                      'چشم میں خوش آمدید',
                      style: TextStyle(
                        fontSize: 32,
                        fontFamily: 'Aasar',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Google sign-in button
                    GestureDetector(
                      onTap: _signInWithGoogle,
                      child: Container(
                        width: 284,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'اپنے گوگل اکاوئنٹ کے ذریعے لاگ اِن کریں',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'NastaliqKasheeda'),
                            ),
                            const SizedBox(height: 16),
                            Image.asset(
                              'assets/images/google-icon.png',
                              width: 100,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                'یہاں سے لاگ اِن کریں',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'NastaliqKasheeda'),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
