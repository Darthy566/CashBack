// lib/transaction_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart' as db;
import 'app_colors.dart'; // Import app colors

// Assuming a secondary green for gradient
const secondaryAppGreen = Color(0xFF388E3C);
const darkGreenCard = Color(0xFF2E7D32); // For the cards

// --- Edit Transaction Screen ---
class TransactionEditScreen extends StatefulWidget {
  final db.User user;
  final db.Transaction transaction;

  const TransactionEditScreen({
    super.key,
    required this.user,
    required this.transaction,
  });

  @override
  State<TransactionEditScreen> createState() => _TransactionEditScreenState();
}

class _TransactionEditScreenState extends State<TransactionEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late db.Transaction _tempTransaction;
  
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  
  final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: ''); // No symbol

  @override
  void initState() {
    super.initState();
    _tempTransaction = db.Transaction.fromMap(widget.transaction.toMap());
    
    // Note: The Figma shows "Expense Name" which maps to our 'title'
    _nameController = TextEditingController(text: _tempTransaction.title);
    _amountController = TextEditingController(text: _tempTransaction.amount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      _tempTransaction.title = _nameController.text;
      _tempTransaction.amount = double.tryParse(_amountController.text) ?? 0.0;
      
      // The design doesn't show category editing, but our old code did.
      // We'll update the title instead of category as per the form field "Expense Name"
      // If you want to edit category, you'd add another field.

      try {
        await db.DatabaseHelper().updateTransaction(_tempTransaction);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.transaction.type} updated!'),
              backgroundColor: primaryAppGreen,
            ),
          );
          Navigator.pop(context, true); // Pop with 'true' to refresh
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red),
          );
        }
      }
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
        foregroundColor: Colors.black, // Black arrow on light gradient
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
                'Edit ${widget.transaction.type}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              
              // Top Green Display Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: darkGreenCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tempTransaction.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(_tempTransaction.amount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.transaction.type} Information',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Field 1: Name
                      _buildTextField(
                        label: '${widget.transaction.type} Name',
                        controller: _nameController,
                        validator: (val) => (val == null || val.isEmpty) ? 'Name is required' : null,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Field 2: Amount
                      _buildTextField(
                        label: 'Amount per month',
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Amount is required';
                          if (double.tryParse(val) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // === Save Button ===
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryAppGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for text fields
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
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
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: '',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryAppGreen, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}