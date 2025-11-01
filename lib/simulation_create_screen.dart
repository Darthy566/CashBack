// simulation_create_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_helper.dart' as db;
import 'dart:math'; // For calculation
import 'dart:convert'; // For jsonDecode
import 'package:yahoofin/yahoofin.dart';
import 'app_colors.dart';

// --- Color Palette Constants ---
const Color primaryGreen = Color(0xFF4CAF50);
const Color lightGreen = Color(0xFF8BC34A);
const Color primaryAppDarkGreen = Color(0xFF2E7D32);

// --- Create Simulation Screen ---
class SimulationCreateScreen extends StatefulWidget {
  final db.User user;
  const SimulationCreateScreen({super.key, required this.user});

  @override
  State<SimulationCreateScreen> createState() => _SimulationCreateScreenState();
}

class _SimulationCreateScreenState extends State<SimulationCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Controllers
  final _initialInvestmentController = TextEditingController();
  final _monthlyContributionController = TextEditingController();
  
  // Dropdown values
  int _selectedYears = 2;
  String? _selectedStock; // Start as null
  List<String> _stockChoices = [];
  bool _isLoadingStocks = true;
  bool _isSimulating = false;

  @override
  void initState() {
    super.initState();
    _loadStockChoices();
  }

  @override
  void dispose() {
    _initialInvestmentController.dispose();
    _monthlyContributionController.dispose();
    super.dispose();
  }

  // --- Load Stock Choices ---
  Future<void> _loadStockChoices() async {
    // Use actual stock symbols
    setState(() {
      _stockChoices = [
        'AAPL', 'GOOGL', 'MSFT', 'TSLA', 'AMZN',
        'META', 'NVDA', 'NFLX', 'SPY', 'QQQ'
      ];
      _selectedStock = _stockChoices.first;
      _isLoadingStocks = false;
    });
  }

  // --- SIMULATION LOGIC ---
  Future<void> _runSimulation() async {
    if (_formKey.currentState!.validate() == false || _selectedStock == null) {
      return;
    }
    
    setState(() => _isSimulating = true);

    // 1. Get user inputs
    final double initial = double.tryParse(_initialInvestmentController.text) ?? 0;
    final double monthly = double.tryParse(_monthlyContributionController.text) ?? 0;
    final int years = _selectedYears;
    final String stock = _selectedStock!;

    // 2. Get financial data
    final simResult = await _getSimulationDataFromYahooFinance(stock, initial, monthly, years);

    // 3. Create new Simulation object
    final newSimulation = db.Simulation(
      userId: widget.user.id!,
      stockSymbol: stock,
      initialInvestment: initial,
      monthlyContribution: monthly,
      years: years,
      projectedValue: simResult['projectedValue']!,
      cagr: simResult['cagr']!,
      avgReturn: simResult['avgReturn']!,
    );
    
    // 4. Save to database
    final newId = await db.DatabaseHelper().addSimulation(newSimulation);
    
    // 5. Return the new object (with its ID) to the previous screen
    final savedSimulation = db.Simulation.fromMap(newSimulation.toMap()..['id'] = newId);
    
    setState(() => _isSimulating = false);
    
    if (mounted) {
      Navigator.pop(context, savedSimulation);
    }
  }

  // --- *** DATA FUNCTION FOR 'yahoofin: 0.0.8' (CORRECTED) *** ---
  Future<Map<String, double>> _getSimulationDataFromYahooFinance(String stockSymbol, double initial, double monthly, int years) async {
    try {
      // 1. Initialize the package
      final yfin = YahooFin();

      // 2. Initialize StockHistory
      StockHistory hist = yfin.initStockHistory(ticker: stockSymbol);

      // 3. Get chart quotes
      StockChart quotes = await yfin.getChartQuotes(
        stockHistory: hist,
        interval: StockInterval.oneMonth,
        period: StockRange.fiveYear,
      );

      // 4. Check if we have data
      if (quotes.chartQuotes == null ||
          quotes.chartQuotes!.timestamp == null ||
          quotes.chartQuotes!.timestamp!.isEmpty) {
        throw Exception('No historical data found for $stockSymbol.');
      }

      // 5. Create a list of quote objects
      List<Map<String, dynamic>> quoteObjects = [];
      for (int i = 0; i < quotes.chartQuotes!.timestamp!.length; i++) {
        quoteObjects.add({
          'date': DateTime.fromMillisecondsSinceEpoch((quotes.chartQuotes!.timestamp![i] as int) * 1000),
          'adjclose': quotes.chartQuotes!.close![i],
        });
      }

      // 6. Filter out null values and sort
      final validData = quoteObjects
          .where((quote) => quote['adjclose'] != null && quote['adjclose'] > 0 && quote['date'] != null)
          .toList();
      validData.sort((a, b) => a['date'].compareTo(b['date']));

      // 7. Check if we have at least two valid data points
      if (validData.length < 2) {
        throw Exception('Not enough valid historical data to calculate returns for $stockSymbol.');
      }

      // 8. Calculate CAGR and Average Return
      final double firstPrice = validData.first['adjclose'];
      final double lastPrice = validData.last['adjclose'];
      final double totalYears = validData.last['date'].difference(validData.first['date']).inDays / 365.25;

      if (totalYears < 0.001) { // Avoid division by zero or near-zero
        throw Exception('No valid time span in historical data for $stockSymbol');
      }

      final cagr = (pow(lastPrice / firstPrice, 1 / totalYears) - 1);

      // Calculate average daily return
      double totalDailyReturn = 0;
      for (int i = 1; i < validData.length; i++) {
        double previousPrice = validData[i - 1]['adjclose'];
        double currentPrice = validData[i]['adjclose'];
        totalDailyReturn += (currentPrice - previousPrice) / previousPrice;
      }
      final avgReturn = totalDailyReturn / validData.length;

      // 9. Perform financial calculation (Future Value of a Series)
      double projectedValue;
      if (cagr == 0) {
        projectedValue = initial + (monthly * 12 * years);
      } else {
        projectedValue = (initial * pow(1 + cagr, years)) +
                         (monthly * 12) * ((pow(1 + cagr, years) - 1) / cagr);
      }

      return {
        'projectedValue': projectedValue,
        'cagr': cagr.toDouble(),
        'avgReturn': avgReturn.toDouble(),
      };
    } catch (e, stackTrace) {
      // Log the error for debugging
      print('Error in _getSimulationDataFromYahooFinance: $e');
      print('Stack trace: $stackTrace');

      // Fallback to mock data if API fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data for $stockSymbol. Using fallback values.')),
      );

      // Fallback values
      const fallbackCagr = 0.07; // 7% annual growth
      const fallbackAvgReturn = 0.08; // 8% average return

      double projectedValue;
      if (fallbackCagr == 0) {
        projectedValue = initial + (monthly * 12 * years);
      } else {
        projectedValue = (initial * pow(1 + fallbackCagr, years)) +
                         (monthly * 12) * ((pow(1 + fallbackCagr, years) - 1) / fallbackCagr);
      }

      return {
        'projectedValue': projectedValue,
        'cagr': fallbackCagr,
        'avgReturn': fallbackAvgReturn,
      };
    }
  }


  @override
  Widget build(BuildContext context) {
    const double headerHeight = 200;

    return Scaffold(
      backgroundColor: appBackgroundColor,
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
              painter: _CreateSimCirclePainter(), 
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // === Header ===
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'New Simulation', // <-- Changed title
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // === Form Card ===
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white, // <-- CHANGED
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
                          _buildTextField(
                            label: 'Initial Investment',
                            controller: _initialInvestmentController,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Monthly Contribution',
                            controller: _monthlyContributionController,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdownField(
                            label: 'Years',
                            value: _selectedYears.toString(),
                            items: ['1', '2', '3', '5', '10', '20'],
                            onChanged: (val) {
                              setState(() => _selectedYears = int.parse(val!));
                            },
                          ),
                          const SizedBox(height: 16),
                            _buildDropdownField(
                            label: 'Stock Choice',
                            value: _selectedStock,
                            items: _stockChoices,
                            onChanged: (val) {
                              setState(() => _selectedStock = val!);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // === Simulate Button ===
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSimulating ? null : _runSimulation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 2, // <-- Added subtle elevation
                        ),
                        child: _isSimulating
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Simulate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  // Helper widget for text fields
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: primaryGreen, // <-- CHANGED
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (val) {
            if (val == null || val.isEmpty) return 'Value is required';
            if (double.tryParse(val) == null) return 'Enter a valid number';
            return null;
          },
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey.shade100, // <-- CHANGED
            prefixIcon: const Icon(Icons.currency_ruble, color: primaryGreen), // <-- CHANGED
            border: OutlineInputBorder( // <-- CHANGED
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300)
            ),
            focusedBorder: OutlineInputBorder( // <-- ADDED
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryGreen, width: 2)
            ),
            enabledBorder: OutlineInputBorder( // <-- ADDED
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300)
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget for dropdown fields
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: primaryGreen, // <-- CHANGED
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade100, // <-- CHANGED
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300) // <-- ADDED
          ),
          child: _isLoadingStocks
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.arrow_drop_down, color: primaryAppDarkGreen),
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  items: items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
        ),
      ],
    );
  }
}

// Circle Painter
class _CreateSimCirclePainter extends CustomPainter {
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