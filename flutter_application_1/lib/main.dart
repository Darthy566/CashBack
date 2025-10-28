import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'services/api_service.dart';

// Define custom colors based on the prototype
const Color _primaryGreen = Color(0xFF4CD964); // Bright Green
const Color _darkGreen = Color(0xFF00A347);   // Darker green
const Color _lightGrey = Color(0xFFE0E0E0);  // Light grey for Login button background
const Color _inputFillColor = Color(0xFFF0FFF0); // Very light green for input fields
const Color _inputBorderColor = Color(0xFFC0E0C0); // Light green border
const Color _regulatoryTextColor = Color(0xFF6C6C6C); // Darker grey for regulatory text

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CashBack App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      // Define routes for the main screens
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/createAccount': (context) => const CreateAccountScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(), // New Home Screen route
        '/profile': (context) => const ProfileScreen(), // New Profile Screen route
      },
    );
  }
}

// --- WELCOME SCREEN (from previous step, now with navigation) ---
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // --- 1. Logo and Graphic Section ---
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40.0, left: 32.0, right: 32.0),
                  child: LogoAndCircles(),
                ),
              ),
            ),

            // --- 2. Buttons Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              child: Column(
                children: [
                  PrimaryButton(
                    text: 'Create an Account',
                    onPressed: () => Navigator.pushNamed(context, '/createAccount'),
                  ),
                  const SizedBox(height: 16.0),
                  SecondaryButton(
                    text: 'Login',
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
                ],
              ),
            ),

            // --- 3. Regulatory Text ---
            const Padding(
              padding: EdgeInsets.only(bottom: 24.0, top: 16.0),
              child: Text(
                'Regulated by the Bangko Sentral ng Pilipinas',
                style: TextStyle(
                  color: _regulatoryTextColor,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reused Logo and Circles Widget (unchanged)
class LogoAndCircles extends StatelessWidget {
  const LogoAndCircles({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.8;
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        _buildCircle(size * 1.0, _primaryGreen.withOpacity(0.1), 0.0),
        _buildCircle(size * 0.9, _primaryGreen.withOpacity(0.15), 0.0),
        _buildCircle(size * 0.85, Colors.transparent, 2.0, _primaryGreen),
        _buildCircle(size * 0.78, Colors.transparent, 2.0, _darkGreen.withOpacity(0.8)),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Cash',
                    style: TextStyle(
                      color: _darkGreen,
                      fontSize: 42.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.0,
                    ),
                  ),
                  TextSpan(
                    text: 'Back',
                    style: TextStyle(
                      color: _primaryGreen,
                      fontSize: 42.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Smart savings. Brighter future.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircle(double size, Color color, double borderWidth, [Color? borderColor]) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? color,
                width: borderWidth,
              )
            : null,
      ),
    );
  }
}


// --- WIDGETS FOR BUTTONS (Now accept an onPressed callback) ---
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const PrimaryButton({required this.text, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          textStyle: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text(text),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const SecondaryButton({required this.text, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightGrey,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          textStyle: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
        child: Text(text),
      ),
    );
  }
}


// --- CUSTOM FORM FIELD WIDGET ---
class CustomInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final Widget? suffixIcon;
  final bool isPassword;
  final Widget? prefix;

  const CustomInputField({
    required this.label,
    required this.hintText,
    this.suffixIcon,
    this.isPassword = false,
    this.prefix,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefix: prefix,
            filled: true,
            fillColor: _inputFillColor,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none, // Hide default border
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: _inputBorderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: _primaryGreen, width: 2.0),
            ),
          ),
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}


// --- CREATE ACCOUNT SCREEN ---
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _hasNoMiddleName = false;
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    try {
      final response = await _apiService.registerUser(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        mobile: _mobileController.text,
        password: _passwordController.text,
      );
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
      // Navigate to home on success
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background gradient from the prototype
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF86F8A8), // Lighter green start
              Color(0xFF50EE8B), // Middle green
              Color(0xFF4CD964), // Darker green end
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar area (Back button and Title)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8.0),
                    const Text('Create Account', style: TextStyle(color: Colors.black, fontSize: 16.0)),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Create an account',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Form Fields
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          hintText: 'Your first name',
                          filled: true,
                          fillColor: _inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: _inputBorderColor, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: _primaryGreen, width: 2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _middleNameController,
                        decoration: const InputDecoration(
                          labelText: 'Middle Name',
                          hintText: 'Your middle name',
                          filled: true,
                          fillColor: _inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: _inputBorderColor, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: _primaryGreen, width: 2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Checkbox for 'No Legal Middle Name'
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _hasNoMiddleName,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _hasNoMiddleName = newValue ?? false;
                                });
                              },
                              activeColor: _primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          const Text('I have no legal middle name', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                      const SizedBox(height: 20.0), // Extra space after checkbox

                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          hintText: 'Your last name',
                          filled: true,
                          fillColor: _inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: _inputBorderColor, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: _primaryGreen, width: 2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'Your email address',
                          filled: true,
                          fillColor: _inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: _inputBorderColor, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: _primaryGreen, width: 2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _mobileController,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                          hintText: '9** **** ****',
                          prefixText: '+63',
                          filled: true,
                          fillColor: _inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: _inputBorderColor, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: _primaryGreen, width: 2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Create a password',
                          filled: true,
                          fillColor: _inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: _inputBorderColor, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: _primaryGreen, width: 2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Submission Button
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0, bottom: 40.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FloatingActionButton(
                            onPressed: _registerUser,
                            backgroundColor: _primaryGreen,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: const Icon(Icons.arrow_forward, color: Colors.white, size: 30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// --- LOGIN SCREEN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    try {
      final response = await _apiService.loginUser(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
      // Navigate to home on success
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background gradient from the prototype
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF86F8A8), // Lighter green start
              Color(0xFF50EE8B), // Middle green
              Color(0xFF4CD964), // Darker green end
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar area (Back button)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    // Adding a title for consistency, though not in the prototype's top-left
                    const SizedBox(width: 8.0),
                    const Text('Login', style: TextStyle(color: Colors.black, fontSize: 16.0)),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email or mobile number',
                          hintText: 'Enter your email or mobile number',
                          filled: true,
                          fillColor: _inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: _inputBorderColor, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: _primaryGreen, width: 2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          filled: true,
                          fillColor: _inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: _inputBorderColor, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: _primaryGreen, width: 2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Forgot Password Link and Login Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              debugPrint('Forgot Password tapped');
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          // Submit Button (Floating Action Button style)
                          FloatingActionButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                            backgroundColor: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: const Icon(Icons.arrow_forward, color: _primaryGreen, size: 30),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Link for Sign Up
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.black),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/createAccount');
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
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
}
