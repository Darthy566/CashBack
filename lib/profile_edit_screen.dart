// lib/profile_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart' as db;
import 'app_colors.dart'; // Import main.dart for color constants

// Assuming a secondary green for gradient
const secondaryAppGreen = Color(0xFF388E3C);

class ProfileEditScreen extends StatefulWidget {
  final db.User user;
  const ProfileEditScreen({super.key, required this.user});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _ageController;
  late TextEditingController _occupationController;
  late TextEditingController _contactNumberController;
  late TextEditingController _emailController;
  DateTime? _selectedDate;
  
  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: '${widget.user.firstName} ${widget.user.lastName}');
    _ageController = TextEditingController(text: widget.user.age ?? '');
    _occupationController = TextEditingController(text: widget.user.occupation ?? '');
    _contactNumberController = TextEditingController(text: widget.user.contactNumber ?? '');
    _emailController = TextEditingController(text: widget.user.email);
    
    if (widget.user.dateOfBirth != null) {
      try {
        _selectedDate = DateTime.parse(widget.user.dateOfBirth!);
      } catch (e) {
        _selectedDate = null;
      }
    }
  }
  
  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Check for email uniqueness if it was changed
      if (_emailController.text != widget.user.email) {
        final existingUser = await db.DatabaseHelper().getUserByEmail(_emailController.text);
        if (existingUser != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email already in use'), backgroundColor: Colors.red),
          );
          return;
        }
      }

      // Split full name into first and last
      String firstName = widget.user.firstName;
      String lastName = widget.user.lastName;
      final nameParts = _fullNameController.text.split(' ');
      if (nameParts.isNotEmpty) {
        firstName = nameParts[0];
        lastName = nameParts.sublist(1).join(' ');
      }

      final updatedUser = db.User(
        id: widget.user.id,
        firstName: firstName,
        lastName: lastName,
        email: _emailController.text,
        password: widget.user.password, // Password is not changed here
        age: _ageController.text.isNotEmpty ? _ageController.text : null,
        dateOfBirth: _selectedDate?.toIso8601String(),
        occupation: _occupationController.text.isNotEmpty ? _occupationController.text : null,
        contactNumber: _contactNumberController.text.isNotEmpty ? _contactNumberController.text : null,
      );
      
      await db.DatabaseHelper().updateUser(updatedUser);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!'), backgroundColor: primaryAppGreen),
        );
        Navigator.pop(context, updatedUser); // Return the updated user
      }
    }
  }

  String get _formattedDate {
    if (_selectedDate == null) return 'Select Date';
    return DateFormat('MMMM dd, yyyy').format(_selectedDate!);
  }

  @override
  Widget build(BuildContext context) {
    // Get the top padding (status bar height)
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: AppBar(
        // title: const Text('Edit Information', ...), // REMOVED
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        // Added gradient background
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryAppGreen, secondaryAppGreen],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          // Adjusted padding to start below app bar + status bar
          padding: EdgeInsets.fromLTRB(16.0, topPadding + kToolbarHeight + 16, 16.0, 16.0),
          // Wrapped content in a Column
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ADDED: New title widget
              const Text(
                'Edit Information',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24), // Space after title

              // The original white card container
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        controller: _fullNameController,
                        hint: 'Full Name',
                        icon: Icons.edit_outlined,
                        validator: (value) => value == null || value.isEmpty ? 'Please enter your full name' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        controller: _ageController,
                        hint: 'Age',
                        icon: Icons.edit_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildDatePickerField(),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        controller: _occupationController,
                        hint: 'Occupation',
                        icon: Icons.edit_outlined,
                      ),
                      const SizedBox(height: 24),
                      _buildTextFormField(
                        controller: _contactNumberController,
                        hint: 'Contact Number',
                        icon: Icons.edit_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),
                      _buildTextFormField(
                        controller: _emailController,
                        hint: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value == null || value.isEmpty || !value.contains('@') ? 'Please enter a valid email' : null,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // White button
                          foregroundColor: primaryAppGreen, // Green text
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          side: BorderSide(color: primaryAppGreen),
                        ),
                        child: const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(hint: hint, icon: icon),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDatePickerField() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: _buildInputDecoration(hint: 'Date of Birth', icon: Icons.calendar_today_outlined),
        child: Text(
          _formattedDate,
          style: TextStyle(
            color: _selectedDate == null ? Colors.grey[600] : Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
}