// lib/main.dart

import 'package:flutter/material.dart';
import 'database_helper.dart' as db;
import 'welcome_screen.dart'; // <-- IMPORT THE NEW SCREEN
import 'login_screen.dart';
import 'create_account_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'profile_view_screen.dart';
import 'profile_edit_screen.dart';
import 'information_screen.dart';
import 'personal_finance_screen.dart';
import 'transaction_choose_screen.dart';
import 'transaction_add_screen.dart';
import 'transaction_view_screen.dart';
import 'transaction_edit_screen.dart';
import 'savings_recommendation_screen.dart';
import 'goal_management_screen.dart';
import 'goal_add_edit_screen.dart';
import 'goal_history_screen.dart';
import 'investment_simulator_screen.dart';
import 'simulation_create_screen.dart';

import 'app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await db.DatabaseHelper().database;
  runApp(const CashBackApp());
}

class CashBackApp extends StatelessWidget {
  const CashBackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CashBack',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: appBackgroundColor,
      ),
      //
      // =================== FIX IS HERE ===================
      //
      initialRoute: '/welcome', // <-- SET NEW INITIAL ROUTE
      //
      // =================== END OF FIX ===================
      //
      onGenerateRoute: (settings) {
        final args = settings.arguments;
        
        switch (settings.name) {
          //
          // =================== ADD THIS ROUTE ===================
          //
          case '/welcome':
            return MaterialPageRoute(builder: (_) => const WelcomeScreen());
          //
          // =================== END OF ADDITION ===================
          //
          case '/':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/createAccount':
            return MaterialPageRoute(builder: (_) => const CreateAccountScreen());
          case '/home':
            if (args is db.User) {
              return MaterialPageRoute(builder: (_) => HomeScreen(user: args));
            }
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/profile':
            if (args is db.User) {
              return MaterialPageRoute(builder: (_) => ProfileScreen(user: args));
            }
            return MaterialPageRoute(builder: (_) => const LoginScreen());
            
          case '/profileView':
            final user = args is db.User ? args : null;
            if (user != null) {
              return MaterialPageRoute(builder: (_) => ProfileViewScreen(user: user));
            }
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/profileEdit':
            if (args is db.User) {
              return MaterialPageRoute(builder: (_) => ProfileEditScreen(user: args));
            }
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/information':
            return MaterialPageRoute(builder: (_) => const InformationScreen());
            
          case '/personalFinance':
            if (args is db.User) {
              return MaterialPageRoute(builder: (_) => PersonalFinanceScreen(user: args));
            }
            return MaterialPageRoute(builder: (_) => const LoginScreen());
            
          case '/transactionChoose':
             if (args is Map<String, dynamic>) {
              return MaterialPageRoute(builder: (_) => TransactionChooseScreen(user: args['user'], type: args['type']));
            }
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/transactionAdd':
            if (args is Map<String, dynamic>) {
              return MaterialPageRoute(builder: (_) => TransactionAddScreen(user: args['user'], type: args['type']));
            }
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/transactionView':
            if (args is Map<String, dynamic>) {
              return MaterialPageRoute(builder: (_) => TransactionViewScreen(transactionId: args['transactionId'], user: args['user']));
            }
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/transactionEdit':
            if (args is Map<String, dynamic>) {
              return MaterialPageRoute(builder: (_) => TransactionEditScreen(transaction: args['transaction'], user: args['user']));
            }
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/savingsRecommendation':
            if (args is db.User) {
              return MaterialPageRoute(builder: (_) => SavingsRecommendationScreen(user: args));
            }
            return MaterialPageRoute(builder: (_) => const LoginScreen());
            
          case '/goalManagement':
            if (args is db.User) {
              return MaterialPageRoute(builder: (_) => GoalManagementScreen(user: args));
            }
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/goalAddEdit':
            if (args is Map<String, dynamic>) {
              return MaterialPageRoute(builder: (_) => GoalAddEditScreen(user: args['user'], goal: args['goal']));
            }
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/goalHistory':
            if (args is db.User) {
              return MaterialPageRoute(builder: (_) => GoalHistoryScreen(user: args));
            }
            return MaterialPageRoute(builder: (_) => const LoginScreen());
            
          case '/investmentSimulator':
            if (args is db.User) {
              return MaterialPageRoute(builder: (_) => InvestmentSimulatorScreen(user: args));
            }
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/createSimulation':
            if (args is db.User) {
              return MaterialPageRoute(builder: (_) => SimulationCreateScreen(user: args));
            }
            return MaterialPageRoute(builder: (_) => const LoginScreen());
            
          default:
            return MaterialPageRoute(builder: (_) => const WelcomeScreen()); // Default to welcome
        }
      },
    );
  }
}