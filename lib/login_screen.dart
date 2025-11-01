// lib/login_screen.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'database_helper.dart' as db;
import 'main.dart'; // Import for color constants
import 'app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final user = await db.DatabaseHelper().getUser(
        _emailController.text,
        _passwordController.text,
      );
      
      setState(() => _isLoading = false);

      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home', arguments: user);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      //
      // =================== FIX IS HERE ===================
      //
      // Removed the AppBar
      body: Stack(
        children: [
          // Gradient background
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryAppGreen.withOpacity(0.8), primaryAppGreen.withOpacity(0.2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(300),
                ),
              ),
            ),
          ),
          //
          // =================== END OF FIX ===================
          //
          SafeArea( // Ensures content starts below status bar
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Custom Back Button
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Login',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Welcome Back',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: _emailController,
                        decoration: _buildInputDecoration(label: 'Email or mobile number', icon: Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your email or number'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: _buildInputDecoration(label: 'Password', icon: Icons.lock_outline),
                        obscureText: true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your password'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Implement forgot password logic
                          },
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(color: primaryAppGreen, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator(color: primaryAppGreen))
                          : GestureDetector(
                              onTap: _login,
                              child: Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [lightGreen, primaryAppGreen],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryAppGreen.withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                                  ],
                                ),
                              ),
                            ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/createAccount');
                        },
                        child: const Text(
                          'Don\'t have an account? Sign Up',
                          style: TextStyle(color: primaryAppGreen, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      prefixIcon: Icon(icon, color: primaryAppGreen),
      suffixIcon: label == 'Password' 
          ? Icon(Icons.remove_red_eye_outlined, color: Colors.grey[600]) // Eye icon for password
          : null,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // No border by default for filled style
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryAppGreen, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
    );
  }
}