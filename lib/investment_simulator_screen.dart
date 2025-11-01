// investment_simulator_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // For financial calculations
import 'database_helper.dart' as db; // Use alias
import 'app_colors.dart';

// --- Color Palette Constants ---
const Color primaryGreen = Color(0xFF4CAF50);
const Color lightGreen = Color(0xFF8BC34A);
const Color primaryAppDarkGreen = Color(0xFF2E7D32);

// --- Investment Simulator Screen ---
class InvestmentSimulatorScreen extends StatefulWidget {
  final db.User user;
  const InvestmentSimulatorScreen({super.key, required this.user});

  @override
  State<InvestmentSimulatorScreen> createState() => _InvestmentSimulatorScreenState();
}

class _InvestmentSimulatorScreenState extends State<InvestmentSimulatorScreen> {
  // State
  List<db.Simulation> _savedSimulations = [];
  db.Simulation? _currentSimulation;
  // List<FlSpot> _chartData = []; // <-- No longer needed, chart data is generated in PageView
  bool _isLoading = true;
  int _currentPage = 0;
  late PageController _pageController;
  bool _isEditing = false; // State for edit mode
  
  // Formatters
  final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
  final percentFormat = NumberFormat.percentPattern()..minimumFractionDigits = 2;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadSimulations();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- Data & Logic ---

  Future<void> _loadSimulations() async {
    if (widget.user.id == null) return;
    final simulations = await db.DatabaseHelper().getSimulations(widget.user.id!);
    setState(() {
      _savedSimulations = simulations;
      if (_savedSimulations.isNotEmpty) {
        _selectSimulation(_savedSimulations.first);
      }
      _isLoading = false;
    });
  }

  // Updated: Now only sets the current simulation for edit/delete logic
  void _selectSimulation(db.Simulation sim) {
    setState(() {
      _currentSimulation = sim;
      // _chartData = _generateChartData(sim); // <-- No longer needed here
      _isEditing = false; // Reset edit state on page change
    });
  }

  Future<void> _navigateToCreate() async {
    final newSimulation = await Navigator.pushNamed(
      context, 
      '/createSimulation',
      arguments: widget.user
    ) as db.Simulation?;
    
    if (newSimulation != null) {
      setState(() {
        _savedSimulations.add(newSimulation);
        _selectSimulation(newSimulation);
        _isEditing = true; // Show save/delete for new item
      });
      if (_savedSimulations.length > 1) {
         _pageController.animateToPage(
          _savedSimulations.length - 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> _deleteCurrentSimulation() async {
    if (_currentSimulation == null || _currentSimulation!.id == null) return;

    await db.DatabaseHelper().deleteSimulation(_currentSimulation!.id!);
    
    _savedSimulations.removeWhere((s) => s.id == _currentSimulation!.id);
    
    setState(() {
      if (_savedSimulations.isNotEmpty) {
        // Select the previous item or first item
        _currentPage = max(0, _currentPage - 1);
        _selectSimulation(_savedSimulations[_currentPage]);
      } else {
        // List is empty
        _currentSimulation = null;
        // _chartData = []; // <-- No longer needed
      }
      _isEditing = false; // Hide buttons after delete
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simulation deleted'), backgroundColor: Colors.red),
    );
  }
  
  // --- Chart Data Generation ---
  List<FlSpot> _generateChartData(db.Simulation sim) {
    List<FlSpot> spots = [];
    final int totalMonths = sim.years * 12;
    final double monthlyRate = pow(1 + sim.cagr, 1 / 12) - 1;

    for (int month = 0; month <= totalMonths; month++) {
      double totalValue;
      if (monthlyRate == 0) {
        totalValue = sim.initialInvestment + (sim.monthlyContribution * month);
      } else {
        totalValue = sim.initialInvestment * pow(1 + monthlyRate, month) +
                     sim.monthlyContribution * ((pow(1 + monthlyRate, month) - 1) / monthlyRate);
      }
      spots.add(FlSpot(month.toDouble(), totalValue));
    }
    return spots;
  }


  @override
  Widget build(BuildContext context) {
    const double headerHeight = 200;

    return Scaffold(
      backgroundColor: Colors.white, // Set scaffold background to white
      body: Stack(
        children: [
          // 1. Background Gradient
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
          // 2. Decorative Circles
          Positioned(
            top: -100,
            right: -100,
            child: CustomPaint(
              size: const Size(200, 200),
              painter: _SimulatorCirclePainter(),
            ),
          ),
          // 3. Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // === Header ===
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0), // Reduced bottom padding
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
      
                      Expanded(
                        child: Text(
                          'Investment Simulator',
                          textAlign: TextAlign.center, // Center the title
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22, // Reduced font size
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1, // Ensure one line
                        ),
                      ),
                      
                      Row(
                        children: [
                          // Show Edit button ONLY if not editing and a sim exists
                          if (_currentSimulation != null && !_isEditing)
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white, size: 26),
                              onPressed: () {
                                setState(() {
                                  _isEditing = true;
                                });
                              },
                            ),
                          
                          // Show Add button
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white, size: 30),
                            onPressed: _navigateToCreate,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // --- STOCK SYMBOL & CHART MOVED from here ---
                
                // === Body Content ===
                Expanded(
                  child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: primaryGreen))
                    : _buildBody(), // <-- This now just points to _buildResultsArea
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Main Body Widget ---
  // Updated: This widget now just returns the results area
  Widget _buildBody() {
    return _buildResultsArea();
  }

  // --- Empty Chart Placeholder ---
  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline, size: 50, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No data to display.\nTap the + to create a simulation.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // --- Line Chart Widget ---
  // Updated: Now accepts chartData as a parameter
  Widget _buildLineChart(List<FlSpot> chartData) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles:false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 12,
              getTitlesWidget: (value, meta) {
                // Show year labels
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text('Yr ${value.toInt() ~/ 12}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: primaryGreen,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                return LineTooltipItem(
                  '${currencyFormat.format(flSpot.y)}\n', 
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: 'Month ${flSpot.x.toInt()}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                    ),
                  ]
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: chartData, // <-- Use passed-in chartData
            isCurved: true,
            color: primaryGreen,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [lightGreen.withOpacity(0.5), lightGreen.withOpacity(0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // --- Results Area (Bottom Cards) ---
  Widget _buildResultsArea() {
    // If no simulations exist, show an empty state
    if (_savedSimulations.isEmpty) {
      return Column( // <-- Changed from Expanded
        children: [
          // Stock Symbol
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'No Simulation',
              style: const TextStyle(
                fontSize: 20, 
                color: Colors.white,
                fontWeight: FontWeight.bold, 
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Chart Area
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0), 
            child: Container(
              height: 200,
              padding: const EdgeInsets.only(top: 16, right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: _buildEmptyChart(),
            ),
          ),
          // Cards Area
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
            child: Column(
              children: [
                _buildResultCard('Projected Value', '---'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildResultCard('CAGR', '---', isSmall: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildResultCard('Avg Return', '---', isSmall: true)),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    // If simulations exist, show the PageView
    return Column( // <-- Changed from Expanded
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _savedSimulations.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                _currentSimulation = _savedSimulations[index]; // Set for edit/delete
                _isEditing = false;
              });
            },
            itemBuilder: (context, index) {
              final sim = _savedSimulations[index];
              final totalContribution = sim.initialInvestment + (sim.monthlyContribution * sim.years * 12);
              final profit = sim.projectedValue - totalContribution;
              // --- Generate chart data for *this* page ---
              final chartData = _generateChartData(sim);

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //
                    // =================== STOCK SYMBOL & CHART MOVED HERE ===================
                    //
                    // --- Stock Symbol ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 8.0),
                      child: Text(
                        sim.stockSymbol,
                        style: const TextStyle(
                          fontSize: 20, 
                          color: Colors.white, // Title is white
                          fontWeight: FontWeight.bold, 
                        ),
                      ),
                    ),
                    // --- Chart Area ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0), 
                      child: Container(
                        height: 200,
                        padding: const EdgeInsets.only(top: 16, right: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: chartData.isEmpty ? _buildEmptyChart() : _buildLineChart(chartData),
                      ),
                    ),
                    //
                    // =================== END OF MOVE ===================
                    //

                    // --- Results Cards ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
                      child: Column(
                        children: [
                          // Projected Value (Primary Card)
                          _buildResultCard(
                            'Projected Value After ${sim.years} Years',
                            currencyFormat.format(sim.projectedValue),
                            isSmall: false, // This is the big green card
                          ),
                          const SizedBox(height: 16),
                          // CAGR & Avg Return (Secondary Cards)
                          Row(
                            children: [
                              Expanded(child: _buildResultCard('CAGR', percentFormat.format(sim.cagr), isSmall: true)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildResultCard('Avg Return', percentFormat.format(sim.avgReturn), isSmall: true)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Total Contribution & Profit (Secondary Cards)
                          Row(
                            children: [
                              Expanded(child: _buildResultCard('Total Contribution', currencyFormat.format(totalContribution), isSmall: true)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildResultCard('Profit', currencyFormat.format(profit), isSmall: true)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Input Parameters (Styled as a white card)
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white, // CHANGED
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [ // ADDED
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildParameterDisplay('Initial Investment', currencyFormat.format(sim.initialInvestment)),
                                _buildParameterDisplay('Monthly Contribution', currencyFormat.format(sim.monthlyContribution)),
                                _buildParameterDisplay('Years', sim.years.toString()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Page Indicator
        if (_savedSimulations.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0), // Give buttons some space
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_savedSimulations.length, (index) {
                return Container(
                  width: 8.0, height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? primaryAppDarkGreen : Colors.grey.shade300,
                  ),
                );
              }),
            ),
          ),

        // Show Save/Delete buttons ONLY if a sim exists AND we are in edit mode
        if (_currentSimulation != null && _isEditing)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false; // <-- Hide buttons on save
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Simulation already saved!'), backgroundColor: Colors.blue),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _deleteCurrentSimulation, // Already handles state
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appBackgroundColor,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('Delete', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }


  Widget _buildParameterDisplay(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Helper for results cards
  Widget _buildResultCard(String title, String value, {bool isSmall = false}) {
    // Use 'isSmall' to determine the style
    final Color backgroundColor = isSmall ? Colors.white : primaryGreen;
    final Color titleColor = isSmall ? Colors.black54 : Colors.white.withOpacity(0.9);
    final Color valueColor = isSmall ? primaryGreen : Colors.white;
    
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isSmall ? [ // <-- ADDED Shadow to white cards
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ] : [], // No shadow for the main green card
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: isSmall ? 14 : 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: isSmall ? 22 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Circle Painter
class _SimulatorCirclePainter extends CustomPainter {
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