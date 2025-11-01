// lib/transaction_add_screen.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart' as db;
import 'main.dart'; // Import main.dart for color constants

// Assuming a secondary green for gradient
const secondaryAppGreen = Color(0xFF388E3C);

class TransactionAddScreen extends StatefulWidget {
  final db.User user;
  final String type; // 'Income' or 'Expense'

  const TransactionAddScreen({super.key, required this.user, required this.type});

  @override
  State<TransactionAddScreen> createState() => _TransactionAddScreenState();
}

class _TransactionAddScreenState extends State<TransactionAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  final List<String> _incomeCategories = ['Salary', 'Freelance', 'Investment', 'Other'];
  final List<String> _expenseCategories = [
    'Housing', 'Groceries', 'Transport', 'Utilities', 'Food', 
    'Entertainment', 'Subscriptions', 'Shopping', 'Other'
  ];
  
  List<String> get _categories => widget.type == 'Income' ? _incomeCategories : _expenseCategories;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _selectedCategory = _categories.first;
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _addTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final newTransaction = db.Transaction(
        userId: widget.user.id!,
        title: _titleController.text,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        type: widget.type,
        category: _selectedCategory!,
        date: _dateController.text,
      );

      await db.DatabaseHelper().addTransaction(newTransaction);
      
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Container(
        // Full-screen gradient background
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, primaryAppGreen.withOpacity(0.6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.0, topPadding + kToolbarHeight + 16, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                'Add ${widget.type}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              
              // White Form Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      _buildTextField(
                        controller: _titleController,
                        label: 'Title',
                        icon: Icons.title,
                        validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Amount
                      _buildTextField(
                        controller: _amountController,
                        label: 'Amount',
                        icon: Icons.attach_money,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter an amount';
                          if (double.tryParse(value) == null) return 'Please enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Category
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: _buildInputDecoration(label: 'Category', icon: Icons.category),
                        items: _categories.map((category) {
                          return DropdownMenuItem(value: category, child: Text(category));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                        },
                        validator: (value) => value == null ? 'Please select a category' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Date
                      _buildTextField(
                        controller: _dateController,
                        label: 'Date',
                        icon: Icons.calendar_today,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Submit Button
              ElevatedButton(
                onPressed: _addTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryAppGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Add Transaction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: _buildInputDecoration(label: '', icon: icon), // Label is now on top
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      // labelText: label, // We use a separate Text widget for label
      prefixIcon: Icon(icon, color: primaryAppGreen),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryAppGreen, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}