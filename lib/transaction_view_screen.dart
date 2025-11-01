// lib/transaction_view_screen.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart' as db;
import 'main.dart'; // Import main.dart for color constants

// Assuming a secondary green for gradient
const secondaryAppGreen = Color(0xFF388E3C);
const darkGreenCard = Color(0xFF2E7D32); // For the cards

class TransactionViewScreen extends StatefulWidget {
  final int transactionId;
  final db.User user;

  const TransactionViewScreen({
    super.key,
    required this.transactionId,
    required this.user,
  });

  @override
  State<TransactionViewScreen> createState() => _TransactionViewScreenState();
}

class _TransactionViewScreenState extends State<TransactionViewScreen> {
  late Future<db.Transaction?> _transactionFuture;
  final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  void _loadTransaction() {
    _transactionFuture = db.DatabaseHelper().getTransaction(widget.transactionId);
  }
  
  void _navigateToEdit(db.Transaction transaction) async {
     final result = await Navigator.pushNamed(
      context,
      '/transactionEdit',
      arguments: {'transaction': transaction, 'user': widget.user},
    );
    
    if (result == true && mounted) {
      setState(() {
         _loadTransaction(); // Refresh data after edit
      });
    }
  }
  
  void _deleteTransaction() async {
    final bool? shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    
    if (shouldDelete == true && mounted) {
      await db.DatabaseHelper().deleteTransaction(widget.transactionId);
      Navigator.pop(context, true); // Return true to refresh previous screen
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
        child: FutureBuilder<db.Transaction?>(
          future: _transactionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: primaryAppGreen));
            } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('Error: Transaction not found.'));
            }

            final transaction = snapshot.data!;
            final isIncome = transaction.type == 'Income';
            final color = isIncome ? darkGreenCard : Colors.red;

            return ListView(
              padding: EdgeInsets.fromLTRB(16.0, topPadding + kToolbarHeight + 16, 16.0, 16.0),
              children: [
                // Title
                const Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),

                // Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: color, // Use red for expense, green for income
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        transaction.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${isIncome ? '+' : '-'}${currencyFormat.format(transaction.amount)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Details Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.category_outlined,
                        title: 'Category',
                        subtitle: transaction.category,
                      ),
                      _buildInfoTile(
                        icon: Icons.calendar_today_outlined,
                        title: 'Date',
                        subtitle: DateFormat('MMMM d, yyyy').format(DateTime.parse(transaction.date)),
                      ),
                      _buildInfoTile(
                        icon: isIncome ? Icons.arrow_downward_outlined : Icons.arrow_upward_outlined,
                        title: 'Type',
                        subtitle: transaction.type,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text('Edit'),
                        onPressed: () => _navigateToEdit(transaction),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryAppGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text('Delete'),
                        onPressed: _deleteTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required String subtitle}) {
    return ListTile(
      leading: Icon(icon, color: primaryAppGreen),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 16)),
    );
  }
}