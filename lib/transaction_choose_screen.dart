// lib/transaction_choose_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart' as db;
import 'app_colors.dart';

// Assuming a secondary green for gradient
const secondaryAppGreen = Color(0xFF388E3C);
const darkGreenCard = Color(0xFF2E7D32); // For the cards

class TransactionChooseScreen extends StatefulWidget {
  final db.User user;
  final String type; // 'Income' or 'Expense'

  const TransactionChooseScreen({
    super.key,
    required this.user,
    required this.type,
  });

  @override
  State<TransactionChooseScreen> createState() => _TransactionChooseScreenState();
}

class _TransactionChooseScreenState extends State<TransactionChooseScreen> {
  late Future<List<db.Transaction>> _transactionsFuture;
  final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: ''); // No symbol

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    setState(() {
      // We load all transactions, then filter in the builder
      _transactionsFuture = db.DatabaseHelper().getTransactions(widget.user.id!);
    });
  }

  void _navigateToAddTransaction() async {
    final result = await Navigator.pushNamed(
      context,
      '/transactionAdd',
      arguments: {'user': widget.user, 'type': widget.type},
    );
    
    if (result == true && mounted) {
      _loadTransactions(); // Refresh the list
    }
  }
  
  void _navigateToEditTransaction(db.Transaction transaction) async {
     final result = await Navigator.pushNamed(
      context,
      '/transactionEdit',
      arguments: {'transaction': transaction, 'user': widget.user},
    );
    
    if (result == true && mounted) {
      _loadTransactions(); // Refresh if edit happened
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
        child: Column(
          children: [
            SizedBox(height: topPadding + kToolbarHeight), // Space for app bar
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Choose ${widget.type} to Edit',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: primaryAppGreen, size: 30),
                    onPressed: _navigateToAddTransaction,
                  ),
                ],
              ),
            ),
            // List
            Expanded(
              child: FutureBuilder<List<db.Transaction>>(
                future: _transactionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: primaryAppGreen));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No transactions found.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  // Filter transactions by type
                  final transactions = snapshot.data!
                      .where((t) => t.type == widget.type)
                      .toList();
                      
                  if (transactions.isEmpty) {
                    return Center(
                      child: Text(
                        'No ${widget.type.toLowerCase()} transactions found.',
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      // Use the new green card widget
                      return _buildTransactionCard(
                        transaction: transaction,
                        onTap: () => _navigateToEditTransaction(transaction),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New widget for the green transaction card
  Widget _buildTransactionCard({required db.Transaction transaction, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: darkGreenCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.title, // e.g., "Bills"
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(transaction.amount), // e.g., "3,000.00"
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}