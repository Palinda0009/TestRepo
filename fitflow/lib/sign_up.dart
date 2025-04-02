import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitflow/home.dart'; // ✅ Import Home Screen

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _acceptPolicy = false;
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptPolicy) {
      _showSnackBar("You must accept the Privacy Policy", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (userCredential.user != null) {
        await _firestore.collection("users").doc(userCredential.user!.uid).set({
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "phone": _phoneController.text.trim(),
          "uid": userCredential.user!.uid,
          "createdAt": FieldValue.serverTimestamp(),
        });

        _showSnackBar("Sign Up Successful!", Colors.green);

        // ✅ Navigate to Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String errorMessage = "Sign up failed. Please try again.";

      if (e.code == 'email-already-in-use') {
        errorMessage = "Email is already in use. Try logging in.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password is too weak. Use at least 6 characters.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format.";
      }

      _showSnackBar(errorMessage, Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/bg_image.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.5)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Sign Up',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create an account to get started.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 40),
                    _buildNameField(),
                    const SizedBox(height: 20),
                    _buildEmailField(),
                    const SizedBox(height: 20),
                    _buildPhoneField(),
                    const SizedBox(height: 20),
                    _buildPasswordField(),
                    const SizedBox(height: 20),
                    _buildPolicyCheckbox(),
                    const SizedBox(height: 24),
                    _buildSignUpButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return _buildTextField(_nameController, "Full Name", Icons.person);
  }

  Widget _buildEmailField() {
    return _buildTextField(_emailController, "Email", Icons.email);
  }

  Widget _buildPhoneField() {
    return _buildTextField(_phoneController, "Phone", Icons.phone);
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: _inputDecoration("Password", Icons.lock),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your password';
        if (value.length < 6)
          return 'Password must be at least 6 characters long';
        return null;
      },
    );
  }

  Widget _buildPolicyCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _acceptPolicy,
          onChanged: (value) => setState(() => _acceptPolicy = value ?? false),
          fillColor: WidgetStateProperty.resolveWith<Color>(
            (states) => _acceptPolicy ? Colors.green : Colors.white,
          ),
        ),
        const Text(
          'By continuing you accept our Privacy Policy',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _acceptPolicy && !_isLoading ? _signUp : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child:
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label, icon),
      style: const TextStyle(color: Colors.white),
      validator:
          (value) =>
              value == null || value.isEmpty
                  ? 'Please enter your $label'
                  : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      prefixIcon: IconTheme(
        data: const IconThemeData(color: Colors.white),
        child: Icon(icon),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.2),
    );
  }
}
