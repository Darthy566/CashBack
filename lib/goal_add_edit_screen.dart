// lib/goal_add_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for formatting
import 'database_helper.dart' as db;
import 'app_colors.dart'; // Import main.dart for color constants

class GoalAddEditScreen extends StatefulWidget {
  final db.User user;
  final db.Goal? goal; // Null if adding, non-null if editing

  const GoalAddEditScreen({super.key, required this.user, this.goal});

  @override
  State<GoalAddEditScreen> createState() => _GoalAddEditScreenState();
}

class _GoalAddEditScreenState extends State<GoalAddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late double _timeInMonths; // State for the slider
  
  bool get _isEditing => widget.goal != null;

  // --- State Variables ---
  bool _isLoadingFinancials = true;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  final _currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
  
  final _percentFormat = NumberFormat.percentPattern()
    ..maximumFractionDigits = 0
    ..minimumFractionDigits = 0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal?.title ?? '');
    _amountController = TextEditingController(text: widget.goal?.amount.toString() ?? '');
    _timeInMonths = widget.goal?.timeToAchieveMonths?.toDouble() ?? 0;

    // Only fetch if we are adding a new goal
    if (!_isEditing) {
      _amountController.addListener(_updateRecommendation);
      _fetchFinancials();
    } else {
      _isLoadingFinancials = false; // Not needed for editing
    }
  }
  
  // Listener for text field
  void _updateRecommendation() {
    // Just call setState to rebuild the recommendation widget
    setState(() {});
  }

  // Data Fetching Method
  Future<void> _fetchFinancials() async {
    if (widget.user.id == null) {
      setState(() => _isLoadingFinancials = false);
      return;
    }
    _totalIncome = await db.DatabaseHelper().getTotalAmount(widget.user.id!, 'Income');
    _totalExpense = await db.DatabaseHelper().getTotalAmount(widget.user.id!, 'Expense');
    if (mounted) {
      setState(() => _isLoadingFinancials = false);
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _amountController.removeListener(_updateRecommendation); 
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final title = _titleController.text;
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final timeToAchieve = _timeInMonths.round();

      if (_isEditing) {
        // Update existing goal
        final updatedGoal = widget.goal!;
        updatedGoal.title = title;
        updatedGoal.amount = amount;
        updatedGoal.timeToAchieveMonths = timeToAchieve;
        
        await db.DatabaseHelper().updateGoal(updatedGoal);
      } else {
        // Add new goal
        final newGoal = db.Goal(
          userId: widget.user.id!,
          title: title,
          amount: amount,
          timeToAchieveMonths: timeToAchieve,
          status: 'active',
        );
        await db.DatabaseHelper().addGoal(newGoal);
      }
      
      if (mounted) {
        Navigator.pop(context, true); // Return true to refresh list
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 200;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Full-screen green gradient background (top part)
          Container(
            height: headerHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [lightGreen, primaryGreen],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 2. Decorative Concentric Circles
          Positioned(
            top: -100,
            right: -100,
            child: CustomPaint(
              size: const Size(200, 200),
              painter: _FinanceCirclePainter(),
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // === Header (Back button and Title) ===
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                        ),
                        const SizedBox(height: 16),
                        // Title
                        Text(
                          _isEditing ? 'Edit Current Goal' : 'Add New Goal',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // === Form ===
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: primaryGreen,
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
                          _buildFormSection(
                            label: 'Goal Title',
                            field: TextFormField(
                              controller: _titleController,
                              decoration: _buildInputDecoration(),
                              validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildFormSection(
                            label: 'Goal Amount',
                            field: TextFormField(
                              controller: _amountController,
                              decoration: _buildInputDecoration(isAmount: true),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter an amount';
                                if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Please enter a valid amount';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildFormSection(
                            label: 'Time to achieve',
                            field: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_timeInMonths.round()} Months',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Slider(
                                  value: _timeInMonths,
                                  min: 0,
                                  max: 60, // 5 years
                                  divisions: 60,
                                  label: _timeInMonths.round().toString(),
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white30,
                                  onChanged: (double value) {
                                    // Add listener call here too
                                    setState(() { 
                                      _timeInMonths = value;
                                      _updateRecommendation(); 
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16), 
                          
                          // --- Recommendation Widget ---
                          _buildRecommendationWidget(),
                          // --- End of Widget ---

                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _saveGoal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, // White button
                              foregroundColor: primaryGreen, // Green text
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: Text(
                              _isEditing ? 'Edit now' : 'Add now',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        ],
      ),
    );
  }

  // --- Updated Recommendation Builder ---
  Widget _buildRecommendationWidget() {
    // Don't show if editing or loading
    if (_isEditing || _isLoadingFinancials) {
      return const SizedBox.shrink();
    }

    final double goalAmount = double.tryParse(_amountController.text) ?? 0.0;

    // Show this first if no income is logged
    if (_totalIncome <= 0) {
      return _buildInfoCard(
        "Add your income in 'Personal Finance' to get savings recommendations.",
        isWarning: true,
      );
    }
    
    //
    // =================== NEW LOGIC IS HERE ===================
    //
    // New check: Warn if goal amount is greater than total income
    if (goalAmount > _totalIncome) {
      return _buildInfoCard(
        "Your goal of ${_currencyFormat.format(goalAmount)} is greater than your total monthly income of ${_currencyFormat.format(_totalIncome)}.",
        isWarning: true,
      );
    }
    //
    // =================== END OF NEW LOGIC ===================
    //
    
    final double disposableIncome = _totalIncome - _totalExpense;
    final int months = _timeInMonths.round();

    // Don't show if no amount or time is set
    if (goalAmount == 0 || months == 0) {
      return const SizedBox.shrink();
    }

    final double monthlySavingsNeeded = goalAmount / months;
    
    // Check if it's affordable monthly
    if (disposableIncome > 0 && monthlySavingsNeeded > disposableIncome) {
      return _buildInfoCard(
        "This goal requires ${_currencyFormat.format(monthlySavingsNeeded)}/month, "
        "which is more than your disposable income of ${_currencyFormat.format(disposableIncome)}.",
        isWarning: true,
      );
    }

    // Calculate percentage of *total* income
    final double percentOfIncome = monthlySavingsNeeded / _totalIncome;

    // Default recommendation message
    return _buildInfoCard(
      "You should save ${_percentFormat.format(percentOfIncome)} "
      "or ${_currencyFormat.format(monthlySavingsNeeded)} of your income "
      "to reach your goal in $months months.",
    );
  }
  // --- End of Updated Builder ---

  // Helper for Info Card
  Widget _buildInfoCard(String text, {bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isWarning ? Colors.red[100] : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isWarning ? Icons.warning_amber_rounded : Icons.lightbulb_outline, 
            color: isWarning ? Colors.red[700] : primaryAppDarkGreen,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isWarning ? Colors.red[900] : primaryAppDarkGreen,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection({required String label, required Widget field}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  InputDecoration _buildInputDecoration({bool isAmount = false}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: isAmount ? const Icon(Icons.currency_ruble_rounded, color: Colors.grey) : null, // Using Ruble sign as '₱' is not a standard icon
      hintText: isAmount ? '0.00' : 'Enter title',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }
}

// Circle Painter (reused design, defined locally for independence)
class _FinanceCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final paint2 = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final center = Offset(size.width * 0.5, size.height * 0.5);
    canvas.drawCircle(center, size.width * 0.45, paint1);
    canvas.drawCircle(center, size.width * 0.35, paint2);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}