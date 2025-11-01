// lib/goal_history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; // Import the chart library
import 'database_helper.dart' as db;
import 'app_colors.dart'; // Import main.dart for color constants

class GoalHistoryScreen extends StatefulWidget {
  final db.User user;
  const GoalHistoryScreen({super.key, required this.user});

  @override
  State<GoalHistoryScreen> createState() => _GoalHistoryScreenState();
}

class _GoalHistoryScreenState extends State<GoalHistoryScreen> {
  late Future<List<db.Goal>> _completedGoalsFuture;
  final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

  @override
  void initState() {
    super.initState();
    _completedGoalsFuture =
        db.DatabaseHelper().getGoals(widget.user.id!, status: 'completed');
  }

  String _formatCompletionDate(String? dateString) {
    if (dateString == null) return 'Achieved on: Unknown';
    try {
      final date = DateTime.parse(dateString);
      return 'Achieved on ${DateFormat.yMMMMd().format(date)}'; // e.g., March 3, 2025
    } catch (e) {
      return 'Achieved on: Invalid Date';
    }
  }

  Widget _buildHistoryCard(db.Goal goal) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: primaryGreen, // Changed to dark green
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
            _formatCompletionDate(goal.completionDate),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // --- New Timeline Chart Widget ---
  Widget _buildTimelineChart(List<db.Goal> goals) {
    // 1. Process data: Group completed goals by month for the current year
    Map<int, int> monthlyCounts = { for (int i = 1; i <= 12; i++) i: 0 };
    int maxCount = 0;
    final int currentYear = DateTime.now().year;

    for (final goal in goals) {
      if (goal.completionDate != null) {
        try {
          final completionDate = DateTime.parse(goal.completionDate!);
          // Only count goals completed in the current year
          if (completionDate.year == currentYear) {
            final month = completionDate.month;
            monthlyCounts[month] = (monthlyCounts[month] ?? 0) + 1;
            if (monthlyCounts[month]! > maxCount) {
              maxCount = monthlyCounts[month]!;
            }
          }
        } catch (e) { /* Ignore invalid dates */ }
      }
    }
    
    // Set Y-axis max value
    final double maxY = maxCount == 0 ? 5 : (maxCount + 1).toDouble();

    // 2. Create Bar Groups
    final List<BarChartGroupData> barGroups = [];
    for (int i = 1; i <= 12; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: monthlyCounts[i]!.toDouble(),
              color: primaryAppGreen,
              width: 14,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    // 3. Build the Chart
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      height: 250,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Divider(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: _bottomTitles,
                      reservedSize: 22,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: _leftTitles,
                      reservedSize: 28,
                      interval: (maxY / 4).ceilToDouble(),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY / 4).ceilToDouble(),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                barTouchData: BarTouchData(enabled: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Bottom Axis (X-axis) labels
  Widget _bottomTitles(double value, TitleMeta meta) {
    final style = TextStyle(color: Colors.grey[700], fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 1: text = 'Jan'; break;
      case 2: text = 'Feb'; break;
      case 3: text = 'Mar'; break;
      case 4: text = 'Apr'; break;
      case 5: text = 'May'; break;
      case 6: text = 'Jun'; break;
      case 7: text = 'Jul'; break;
      case 8: text = 'Aug'; break;
      case 9: text = 'Sep'; break;
      case 10: text = 'Oct'; break;
      case 11: text = 'Nov'; break;
      case 12: text = 'Dec'; break;
      default: text = ''; break;
    }
    // --- FIX IS HERE ---
    return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text(text, style: style));
  }

  // Helper for Left Axis (Y-axis) labels
  Widget _leftTitles(double value, TitleMeta meta) {
    if (value == meta.max || value == 0) return Container(); // Hide max and 0
    final style = TextStyle(color: Colors.grey[700], fontSize: 10);
    // The 'axisSide' property is required here.
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(value.toInt().toString(), style: style),
    );
  }

  // Helper for empty state
  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No completed goals found.',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
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
                        const Text(
                          'Goal History',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // === Content ===
                  FutureBuilder<List<db.Goal>>(
                    future: _completedGoalsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState();
                      }

                      final goals = snapshot.data!;
                      
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8.0),
                        itemCount: goals.length + 1, // Add 1 for the chart
                        itemBuilder: (context, index) {
                          if (index == goals.length) {
                            // This is the last item, show the chart
                            return _buildTimelineChart(goals);
                          }
                          // Otherwise, show the goal card
                          final goal = goals[index];
                          return _buildHistoryCard(goal);
                        },
                      );
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