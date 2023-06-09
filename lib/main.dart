import 'package:chasham_fyp/screens/create_exercise.dart';
import 'package:chasham_fyp/screens/create_lesson_screen.dart';
import 'package:chasham_fyp/screens/dashboard_screen.dart';
import 'package:chasham_fyp/screens/exercise_table_screen.dart';
import 'package:chasham_fyp/screens/first_time_screen.dart';
import 'package:chasham_fyp/screens/home_screen.dart';

import 'package:chasham_fyp/screens/lessons_table_screen.dart';
import 'package:chasham_fyp/screens/letter_exercise_screen.dart';
import 'package:chasham_fyp/screens/letter_lesson_screen.dart';
import 'package:chasham_fyp/screens/letter_practice_screen.dart';
import 'package:chasham_fyp/screens/letters_upload_screen.dart';
import 'package:chasham_fyp/screens/login_screen.dart';
import 'package:chasham_fyp/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/lessons': (context) => LessonTableScreen(),
        '/lesson': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final lessonSerial = args?['id'] as String?;
          return LetterLessonScreen(lessonSerial: lessonSerial);
        },
        '/exercises': (context) => ExerciseTableScreen(),
        '/exercise': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final exerciseSerial = args?['id'] as String?;
          return LetterExerciseScreen(exerciseSerial: exerciseSerial);
        },
        '/letter-upload': (context) => LetterUploadScreen(),
        '/exercise-create': (context) => CreateExercisePage(),
        '/lesson-create': (context) => CreateLessonScreen(),
        '/firsttimescreen': (context) => FirstTimeScreen(),
        '/practice': (context) => LetterPracticeScreen()
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/lesson') {
          // Extract the lesson ID from settings.arguments
          final String? lessonSerial = settings.arguments as String?;

          // Pass the lesson ID to LetterLessonScreen
          return MaterialPageRoute(
            builder: (context) =>
                LetterLessonScreen(lessonSerial: lessonSerial),
          );
        }
        return null;
      },

      theme: ThemeData(
        colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFFF77524),
            onPrimary: Color.fromARGB(255, 74, 33, 8),
            secondary: Color(0xFFF9CF98),
            onSecondary: Color.fromARGB(255, 150, 108, 53),
            error: Colors.redAccent,
            onError: Color(0xFF9C4343),
            background: Colors.white,
            onBackground: Colors.white,
            surface: Colors.white,
            onSurface: Colors.white),
      ),
      // home: HomeScreen(),
    );
  }
}
