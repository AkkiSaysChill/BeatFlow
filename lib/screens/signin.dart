import 'package:beatflow/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:beatflow/screens/homescreen.dart';
import 'package:beatflow/screens/signup.dart';
import 'package:beatflow/screens/psswdreset.dart';
import 'package:beatflow/utis/color_utils.dart';
import 'package:beatflow/utis/text.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _passwdTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  bool _showError = false; // Flag to control error popup visibility

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                logoWidget("assets/beatflow.png"),
                const SizedBox(height: 30),
                reuableTextField(
                    "Enter Email", Icons.person_outline, false, _emailTextController),
                const SizedBox(height: 30),
                reuableTextField(
                    "Password", Icons.lock_outline, true, _passwdTextController),
                const SizedBox(
                  height: 20,
                ),
                signinSignupButton(context, true, () async {
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _emailTextController.text,
                        password: _passwdTextController.text);

                    // Navigate to HomeScreen on successful login
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  } on FirebaseAuthException catch (error) {
                    // Show error popup if login fails
                    setState(() {
                      _showError = true;
                    });
                    print("Error: ${error.message}");
                    _showErrorPopup(context);
                  }
                }),
                signUpOption(),
                passwdReset(),

                // Show error popup if _showError is true
                _showError ? const SizedBox.shrink() : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Image logoWidget(String imageName) {
    return Image.asset(imageName, fit: BoxFit.fitWidth, width: 240, height: 240);
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("don't have an account?", style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
          },
          child: const Text(
            "  Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Row passwdReset() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Forgot Your Password?", style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PasswordResetScreen()));
          },
          child: const Text(
            "  Reset Password",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  void _showErrorPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Error'),
          content: const Text('Incorrect email or password. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                // Close the popup
                setState(() {
                  _showError = false;
                });
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,);
  
  runApp(const MaterialApp(
    home: SignInScreen(),
  ));
}
