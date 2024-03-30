import 'package:beatflow/screens/homescreen.dart';
import 'package:beatflow/utis/color_utils.dart';
import 'package:beatflow/utis/text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                hexStringToColor("340925"),
                hexStringToColor("9546C4"),
                hexStringToColor("5E61F4"),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              reuableTextField(
                  "Enter Email Id", Icons.person_outline, false, _emailTextController),
              const SizedBox(
                height: 20,
              ),
              reuableTextField(
                  "Enter Password", Icons.lock_outlined, true, _passwordTextController),
              const SizedBox(
                height: 20,
              ),
              signinSignupButton(context, false, () {
                FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailTextController.text, password: _passwordTextController.text).then((value) {
                  print("login");
                Navigator.push(context, 
                MaterialPageRoute(builder: (context) => const HomeScreen()));
                }).onError((error, stackTrace) {
                  print("Error ${error.toString()}");
                });
                
              })
            ],
          ),
        ),
      ),
    );
  }
}
