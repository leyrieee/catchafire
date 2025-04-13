import 'package:catchafire/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cause_skills.dart';
import '../services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState(); // ✅
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  String _errorMessage = ''; //✅ Added variable to handle errors

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 242, 230, 1),
      body: SingleChildScrollView(
        child: Padding(
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
                'Ready to change the world, Volunteer?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'GT Ultra',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Create an account to get started',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),

              // New Fields
              buildTextField('Full Name', controller: _nameController),
              const SizedBox(height: 10),
              buildTextField('Email', controller: _emailController),
              const SizedBox(height: 10),
              buildTextField('Phone Number', controller: _phoneController),
              const SizedBox(height: 10),
              buildTextField('City/Location', controller: _cityController),
              const SizedBox(height: 10),
              buildTextField('Password',
                  controller: _passwordController, obscureText: true),
              const SizedBox(height: 10),
              buildTextField('Confirm Password',
                  controller: _confirmPasswordController, obscureText: true),

              const SizedBox(height: 20),
              // Sign Up Button
              buildPrimaryButton('Sign Up', () async {
                if (_passwordController.text !=
                    _confirmPasswordController.text) {
                  setState(() {
                    _errorMessage = 'Passwords do not match';
                  });
                  return;
                }

                final user = await _authService.registerWithEmail(
                  _emailController.text.trim(),
                  _passwordController.text.trim(),
                );

                if (user != null) {
                  await _firestoreService.createUser(user.uid, {
                    'fullName': _nameController.text.trim(),
                    'email': _emailController.text.trim(),
                    'phone': _phoneController.text.trim(),
                    'city': _cityController.text.trim(),
                    'skills': [],
                    'causes': [],
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CauseAndSkillsPage()),
                  );
                } else {
                  setState(() {
                    _errorMessage = 'Failed to sign up. Please try again.';
                  });
                }
              }),
              // Error message display
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 20),

              // Log-in Option with Clickable "Log in" Link
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(fontFamily: "GT Ultra", fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Log in",
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
      ),
    );
  }

  Widget buildTextField(String hint,
      {bool obscureText = false, TextEditingController? controller}) {
    //✅ Added controller parameter
    return TextField(
      controller: controller, //✅ Set controller for text field
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color.fromRGBO(41, 37, 37, 1)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color.fromRGBO(200, 196, 180, 1),
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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
