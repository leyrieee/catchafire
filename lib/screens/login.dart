import "package:flutter/material.dart";
import '../services/auth_service.dart';
import 'signup.dart';
import 'home.dart';

AuthService authService = AuthService();

class LoginPage extends StatefulWidget { // ✅ Changed to StatefulWidget
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState(); // ✅
}

class _LoginPageState extends State<LoginPage> { // ✅
  final TextEditingController emailController = TextEditingController(); // ✅
  final TextEditingController passwordController = TextEditingController(); // ✅

  void _login() async { // ✅
    String email = emailController.text.trim(); // ✅
    String password = passwordController.text.trim(); // ✅

    try {
      await authService.signIn(email, password); // ✅
      Navigator.pushReplacement( // ✅
        context,
        MaterialPageRoute(builder: (context) => const HomePage()), // ✅
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar( // ✅
        SnackBar(content: Text("Login failed: $e")), // ✅
      );
    }
  } // ✅

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 242, 230, 1),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/logo.png',
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'GT Ultra',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Log into your account',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            buildTextField('Email', controller: emailController), // ✅
            const SizedBox(height: 10),
            buildTextField('Password', obscureText: true, controller: passwordController), // ✅
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {}, //define later
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 10),
            buildPrimaryButton('Login', _login), // ✅
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "New to Catchafire? ",
                    style: TextStyle(fontFamily: "GT Ultra", fontSize: 12),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        fontFamily: "GT Ultra",
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String hint, {bool obscureText = false, TextEditingController? controller}) { // ✅
    return TextField(
      controller: controller, // ✅
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color.fromRGBO(41, 37, 37, 1)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Color.fromRGBO(200, 196, 180, 1),
      ),
    );
  }

  Widget buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: const BorderSide(color: Color(0xFF6FE6FF)),
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget buildSecondaryButton(String text, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.black, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
