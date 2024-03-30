import 'package:beatflow/firebase_options.dart';
import 'package:beatflow/screens/signin.dart';
import 'package:beatflow/screens/homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Check if the user is already logged in
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;

  runApp(MaterialApp(
    title: 'BeatFlow',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: user != null ? const HomeScreen() : const SignInScreen(),  // Choose HomeScreen or SignInScreen based on user login
  ));
}
