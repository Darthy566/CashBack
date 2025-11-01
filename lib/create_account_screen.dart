// lib/create_account_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'database_helper.dart' as db;
import 'app_colors.dart'; // Import main.dart for color constants

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _occupationController = TextEditingController(); // New
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _hasNoMiddleName = false;
  DateTime? _selectedDate; // New
  bool _obscurePassword = true; // New
  bool _obscureConfirmPassword = true; // New

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _occupationController.dispose(); // New
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- New Function: Show Date Picker ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _formKey.currentState?.validate(); // Re-validate the form
    }
  }

  // --- New Function: 18+ Age Validation ---
  String? _validateAge(DateTime? date) {
    if (date == null) {
      return 'Please select your date of birth';
    }
    
    final DateTime today = DateTime.now();
    // Calculate the date 18 years ago from today
    final DateTime eighteenYearsAgo = DateTime(today.year - 18, today.month, today.day);
    
    // If the selected date is *after* the 18th birthday, they are not 18 yet
    if (date.isAfter(eighteenYearsAgo)) {
      return 'You must be at least 18 years old';
    }
    return null; // Valid
  }

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
        );
        return;
      }
      
      final existingUser = await db.DatabaseHelper().getUserByEmail(_emailController.text);
      if (existingUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email already in use'), backgroundColor: Colors.red),
        );
        return;
      }
      
      // --- Updated User object creation ---
      final newUser = db.User(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        contactNumber: _mobileNumberController.text, // Now saving this
        dateOfBirth: _selectedDate?.toIso8601String(), // Now saving this
        occupation: _occupationController.text, // Now saving this
      );
      
      await db.DatabaseHelper().addUser(newUser);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created successfully!'), backgroundColor: primaryAppGreen),
        );
        Navigator.pop(context); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      body: Stack(
        children: [
          // Green gradient at the top right
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
          SafeArea( // Ensures content starts below status bar
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
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
                      'Create Account', // Title
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: _buildInputDecoration(label: 'First Name', icon: Icons.person_outline),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your first name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _middleNameController,
                      decoration: _buildInputDecoration(label: 'Middle Name', icon: Icons.person_outline),
                      enabled: !_hasNoMiddleName, // Enable/disable based on checkbox
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: _hasNoMiddleName,
                          onChanged: (bool? value) {
                            setState(() {
                              _hasNoMiddleName = value!;
                              if (_hasNoMiddleName) {
                                _middleNameController.clear(); // Clear if no middle name
                              }
                            });
                          },
                          activeColor: primaryAppGreen,
                        ),
                        const Text('I have no legal middle name', style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: _buildInputDecoration(label: 'Last Name', icon: Icons.person_outline),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your last name' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // --- New Date of Birth Field ---
                    TextFormField(
                      readOnly: true, // Makes it not editable
                      decoration: _buildInputDecoration(
                        label: 'Date of Birth',
                        icon: Icons.calendar_today_outlined,
                      ),
                      onTap: () => _selectDate(context),
                      // Show the formatted date or a placeholder
                      controller: TextEditingController(
                        text: _selectedDate == null 
                            ? '' 
                            : DateFormat('MMMM dd, yyyy').format(_selectedDate!),
                      ),
                      validator: (value) => _validateAge(_selectedDate),
                    ),
                    const SizedBox(height: 16),

                    // --- New Occupation Field ---
                    TextFormField(
                      controller: _occupationController,
                      decoration: _buildInputDecoration(label: 'Occupation', icon: Icons.work_outline),
                      // You can add a validator if needed
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: _buildInputDecoration(label: 'Email Address', icon: Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value == null || value.isEmpty || !value.contains('@') ? 'Please enter a valid email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mobileNumberController,
                      decoration: _buildInputDecoration(
                        label: 'Mobile Number', 
                        icon: Icons.phone_android_outlined,
                        prefixText: '+63 ' // As per screenshot
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter your mobile number';
                        if (value.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(value)) return 'Enter a 10-digit number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // --- Updated Password Field ---
                    TextFormField(
                      controller: _passwordController,
                      decoration: _buildInputDecoration(
                        label: 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        obscureState: _obscurePassword,
                        onToggleObscure: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        }
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                    ),
                    const SizedBox(height: 16),

                    // --- Updated Confirm Password Field ---
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: _buildInputDecoration(
                        label: 'Confirm Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        obscureState: _obscureConfirmPassword,
                        onToggleObscure: () {
                          setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                        }
                      ),
      
                      obscureText: _obscureConfirmPassword,
                      validator: (value) => value == null || value.isEmpty ? 'Please confirm your password' : null,
                    ),
                    
                    const SizedBox(height: 32),
                    // Custom button with arrow
                    GestureDetector(
                      onTap: _createAccount,
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
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
                              'Sign Up',
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Updated _buildInputDecoration ---
  InputDecoration _buildInputDecoration({
    required String label, 
    required IconData icon, 
    String? prefixText,
    bool isPassword = false,
    bool obscureState = false,
    VoidCallback? onToggleObscure,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      prefixIcon: Icon(icon, color: primaryAppGreen),
      prefixText: prefixText,
      prefixStyle: const TextStyle(color: Colors.black, fontSize: 16),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscureState ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey[600],
              ),
              onPressed: onToggleObscure,
            )
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
        borderSide: BorderSide(color: primaryAppGreen, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
    );
  }
}