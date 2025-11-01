// lib/goal_management_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart' as db;
import 'app_colors.dart'; // Import main.dart for color constants
import 'goal_history_screen.dart'; // Import history screen for navigation

class GoalManagementScreen extends StatefulWidget {
  final db.User user;
  const GoalManagementScreen({super.key, required this.user});

  @override
  State<GoalManagementScreen> createState() => _GoalManagementScreenState();
}

class _GoalManagementScreenState extends State<GoalManagementScreen> {
  late Future<List<db.Goal>> _activeGoalsFuture;
  
  final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }
  
  void _loadGoals() {
    setState(() {
      _activeGoalsFuture = db.DatabaseHelper().getGoals(widget.user.id!, status: 'active');
    });
  }

  void _navigateToAddGoal() async {
    final result = await Navigator.pushNamed(
      context,
      '/goalAddEdit',
      arguments: {'user': widget.user, 'goal': null},
    );
    if (result == true) {
      _loadGoals(); // Refresh lists
    }
  }
  
  void _navigateToEditGoal(db.Goal goal) async {
    final result = await Navigator.pushNamed(
      context,
      '/goalAddEdit',
      arguments: {'user': widget.user, 'goal': goal},
    );
    if (result == true) {
      _loadGoals(); // Refresh lists
    }
  }
  
  void _navigateToGoalHistory() {
     Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalHistoryScreen(user: widget.user),
      ),
    );
  }
  
  Widget _buildGoalList(List<db.Goal> goals) {
    if (goals.isEmpty) {
      return const Center(
        child: Text(
          'No active goals found. Tap "+" to add one!',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // Changed padding to only be on the bottom
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return _buildGoalCard(goal);
      },
    );
  }

  Widget _buildGoalCard(db.Goal goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(20.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goal.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(goal.amount),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Estimated Time: ${goal.timeToAchieveMonths ?? 0} months',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const Divider(height: 24, color: Colors.white30),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: const Text('Mark as Completed', style: TextStyle(color: Colors.white)),
                onPressed: () => _markAsCompleted(goal),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => _navigateToEditGoal(goal),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () => _deleteGoal(goal.id!),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Future<void> _markAsCompleted(db.Goal goal) async {
    goal.status = 'completed';
    // Set the completion date
    goal.completionDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await db.DatabaseHelper().updateGoal(goal);
    _loadGoals(); // Refresh lists
  }

  Future<void> _deleteGoal(int id) async {
     final bool? shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
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
    
    if (shouldDelete == true) {
      await db.DatabaseHelper().deleteGoal(id);
      _loadGoals(); // Refresh lists
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Goal Management',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.white, size: 30),
                              tooltip: 'Add Goal',
                              onPressed: _navigateToAddGoal,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // === Content ===
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), // Adjusted padding
                    child: ElevatedButton(
                      onPressed: _navigateToGoalHistory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('View goal history', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  FutureBuilder<List<db.Goal>>(
                    future: _activeGoalsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final goals = snapshot.data ?? [];
                      return _buildGoalList(goals);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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