// home_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'database_helper.dart' as db; // <--- Use alias
import 'app_colors.dart';

// --- UPDATED WIDGET for the Action Grid Buttons ---
class HomeActionGridButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor; 
  final Color? textColor; 

  const HomeActionGridButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor, 
    this.textColor, 
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start, // <-- REVERTED
          children: [
            Icon(
              icon,
              size: 36, // <-- REVERTED
              color: iconColor ?? primaryAppGreen, 
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.left, // <-- REVERTED
              style: TextStyle(
                color: textColor ?? Colors.black87, 
                fontSize: 16, // <-- REVERTED
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Home Screen Widget ---
class HomeScreen extends StatefulWidget {
  final db.User user; // <--- Use alias

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late db.User _currentUser; // <--- Use alias
  
  // --- State for PageView ---
  late PageController _pageController;
  int _currentPage = 0;
  
  // --- State for Data ---
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  List<db.Goal> _userGoals = []; // <--- Use alias
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _currentUser = db.User.fromMap(widget.user.toMap());
    _pageController = PageController();
    _fetchAllData(); 
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user.id != oldWidget.user.id || widget.user.firstName != oldWidget.user.firstName) {
      _currentUser = db.User.fromMap(widget.user.toMap());
    }
  }

  // --- Data Fetching ---
  Future<void> _fetchAllData() async {
    if (_currentUser.id == null) return;
    
    final results = await Future.wait([
      db.DatabaseHelper().getTotalAmount(_currentUser.id!, 'Income'),
      db.DatabaseHelper().getTotalAmount(_currentUser.id!, 'Expense'),
      db.DatabaseHelper().getGoals(_currentUser.id!, status: 'active')
    ]);
    
    if (mounted) {
      setState(() {
        _totalIncome = results[0] as double;
        _totalExpense = results[1] as double;
        _userGoals = results[2] as List<db.Goal>; // <--- Use alias
        _isLoadingData = false;
      });
    }
  }
  
  // --- Navigation Handlers ---
  void _navigateToProfileFlow() async {
    final updatedUser = await Navigator.pushNamed(
      context, 
      '/profile',
      arguments: _currentUser, 
    );
    
    if (updatedUser != null && updatedUser is db.User) { // <--- Use alias
      setState(() {
        _currentUser = updatedUser;
      });
      _fetchAllData(); 
    }
  }
  
  void _navigateToPersonalFinance() async {
    await Navigator.pushNamed(context, '/personalFinance', arguments: _currentUser);
    _fetchAllData(); 
  }
  
  void _navigateToGoalManagement() async {
    await Navigator.pushNamed(context, '/goalManagement', arguments: _currentUser);
    _fetchAllData(); 
  }

  // --- Log Out Handler (MOVED HERE) ---
  void _handleLogout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context, 
      '/',
      (Route<dynamic> route) => false,
    );
  }


  @override
  Widget build(BuildContext context) {
    final pageCount = _userGoals.isEmpty ? 3 : _userGoals.length + 2;

    return Scaffold(
      backgroundColor: appBackgroundColor,
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            height: MediaQuery.of(context).size.height * 0.35, 
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [lightGreen, primaryAppGreen],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          // 2. Main Scrollable Content
          SafeArea(
            //
            // =================== LAYOUTBUILDER REMOVED ===================
            //
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0), // <-- Added padding here
              child: Column(
                // Removed MainAxisAlignment.spaceBetween
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- HEADER GROUP ---
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${_currentUser.firstName}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Smart savings. Brighter future.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // --- PAGEVIEW GROUP ---
                  Container(
                    height: 140, 
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05), // <-- Softer shadow
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemCount: pageCount,
                      itemBuilder: (context, index) {
                        if (_isLoadingData) {
                          return const Center(child: CircularProgressIndicator(color: primaryAppGreen));
                        }
                        
                        if (_userGoals.isEmpty) {
                          if (index == 0) return _buildNoGoalPage();
                          if (index == 1) return _buildFinancialPage("Total Income", _totalIncome, primaryAppGreen);
                          if (index == 2) return _buildFinancialPage("Total Expense", _totalExpense, Colors.red);
                        }
                        
                        if (index < _userGoals.length) {
                          return _buildGoalPage(_userGoals[index]);
                        }
                        if (index == _userGoals.length) {
                          return _buildFinancialPage("Total Income", _totalIncome, primaryAppGreen);
                        }
                        if (index == _userGoals.length + 1) {
                          return _buildFinancialPage("Total Expense", _totalExpense, Colors.red);
                        }
                        
                        return Container(); 
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPageIndicator(pageCount),
                  
                  // --- GRIDVIEW GROUP ---
                  const SizedBox(height: 32),
                  GridView.count(
                    crossAxisCount: 2, // <-- CHANGED TO 2
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.4, // <-- Adjusted ratio
                    children: [
                      HomeActionGridButton(
                        title: 'Profile',
                        icon: Icons.person_outline,
                        onTap: _navigateToProfileFlow,
                      ),
                      HomeActionGridButton(
                        title: 'Personal Finance', // <-- REVERTED title
                        icon: Icons.account_balance_wallet_outlined,
                        onTap: _navigateToPersonalFinance,
                      ),
                      HomeActionGridButton(
                        title: 'Goal Management', // <-- REVERTED title
                        icon: Icons.flag_outlined,
                        onTap: _navigateToGoalManagement, 
                      ),
                      HomeActionGridButton(
                        title: 'Recommendations', // <-- REVERTED title
                        icon: Icons.lightbulb_outline,
                        onTap: () {
                          Navigator.pushNamed(context, '/savingsRecommendation', arguments: _currentUser);
                        },
                      ),
                      HomeActionGridButton(
                        title: 'Simulation', // <-- REVERTED title
                        icon: Icons.trending_up_rounded,
                        onTap: () {
                          Navigator.pushNamed(context, '/investmentSimulator', arguments: _currentUser);
                        },
                      ),
                      HomeActionGridButton(
                        title: 'Log Out',
                        icon: Icons.logout,
                        iconColor: Colors.red,
                        textColor: Colors.red,
                        onTap: () => _handleLogout(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24), // Keep bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widget for Goal Card ---
  Widget _buildGoalPage(db.Goal goal) { 
    final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Current Goal',
            style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.w600), 
          ),
          const SizedBox(height: 4), 
          Text(
            goal.title, 
            style: const TextStyle(
              color: Colors.black87, 
              fontSize: 28, 
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          //
          // =================== OVERFLOW FIX ===================
          //
          Expanded( // <-- WRAP with Expanded
            child: FittedBox( 
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft, // <-- Align left
              child: Text(
                currencyFormat.format(goal.amount),
                style: const TextStyle(
                  color: primaryAppGreen, 
                  fontSize: 40, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widget for "No Goal" placeholder ---
  Widget _buildNoGoalPage() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No Goal Set',
            style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a goal in Goal Management!',
            style: TextStyle(
              color: primaryAppGreen, 
              fontSize: 20, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widget for Income/Expense Cards ---
  Widget _buildFinancialPage(String title, double amount, Color amountColor) {
    final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _isLoadingData
            ? const Center(child: CircularProgressIndicator(color: primaryAppGreen))
            //
            // =================== OVERFLOW FIX ===================
            //
            : Expanded( // <-- WRAP with Expanded
                child: FittedBox(
                  fit: BoxFit.scaleDown, // <-- Use scaleDown
                  alignment: Alignment.centerLeft, // <-- Align left
                  child: Text(
                    currencyFormat.format(amount),
                    style: TextStyle(
                      color: amountColor, 
                      fontSize: 44, 
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1, 
                  ),
                ),
              ),
        ],
      ),
    );
  }
  
  // --- Helper Widget for Page Indicator ---
  Widget _buildPageIndicator(int pageCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? primaryAppDarkGreen : Colors.grey.shade300,
          ),
        );
      }),
    );
  }
}