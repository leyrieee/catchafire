import 'package:flutter/material.dart';
import 'cause_skills.dart';
import '../services/auth_service.dart'; //✅ Importing AuthService for Firebase Auth
class SignUpPage extends StatefulWidget {  //✅ Changed to StatefulWidget to manage form state
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState(); // ✅
}

class _SignUpPageState extends State<SignUpPage> { //✅ Used _SignUpPageState to manage user input
  final _emailController = TextEditingController(); //✅ Added controllers for text fields
  final _passwordController = TextEditingController(); //✅ Added controllers for text fields
  final _confirmPasswordController = TextEditingController(); //✅ Added controllers for confirm password
  final _authService = AuthService(); //✅ Created AuthService instance for Firebase Auth

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
              buildTextField('Full Name'),
              const SizedBox(height: 10),
              buildTextField('Email', controller: _emailController), //✅ Added controller for email
              const SizedBox(height: 10),
              buildTextField('Phone Number'),
              const SizedBox(height: 10),
              buildTextField('City/Location'),
              const SizedBox(height: 10),
              buildTextField('Password', controller: _passwordController, obscureText: true), //✅ Added controller for password
              const SizedBox(height: 10),
              buildTextField('Confirm Password', controller: _confirmPasswordController, obscureText: true), //✅ Added controller for confirm password

              const SizedBox(height: 20),
              // Sign Up Button
              buildPrimaryButton('Sign Up', () async {
                if (_passwordController.text != _confirmPasswordController.text) {
                  setState(() {
                    _errorMessage = 'Passwords do not match'; //✅ Added password matching logic
                  });
                  return;
                }

                final user = await _authService.registerWithEmail(
                  _emailController.text,
                  _passwordController.text,
                );

                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CauseAndSkillsPage()),
                  );
                } else {
                  setState(() {
                    _errorMessage = 'Failed to sign up. Please try again.'; //✅ Show error message if signup fails
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

  Widget buildTextField(String hint, {bool obscureText = false, TextEditingController? controller}) { //✅ Added controller parameter
    return TextField(
      controller: controller,  //✅ Set controller for text field
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
}
