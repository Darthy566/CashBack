// lib/persona_service.dart

import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

// 1. Define the Persona class (No Change)
class Persona {
  final String persona;
  final String ageRange;
  final String incomeBracket;
  final String financialGoal;
  final String riskTolerance;
  final double avgMonthlySpending;
  final double avgMonthlySavings;
  final double debtToIncomeRatio;
  final double recNeeds; // Recommended Needs %
  final double recWants; // Recommended Wants %
  final double recSavings; // Recommended Savings %
  final String financialAdvice;

  Persona({
    required this.persona,
    required this.ageRange,
    required this.incomeBracket,
    required this.financialGoal,
    required this.riskTolerance,
    required this.avgMonthlySpending,
    required this.avgMonthlySavings,
    required this.debtToIncomeRatio,
    required this.recNeeds,
    required this.recWants,
    required this.recSavings,
    required this.financialAdvice,
  });

  // Factory constructor to create a Persona from a CSV row (List<dynamic>)
  factory Persona.fromCsvRow(List<dynamic> row) {
    return Persona(
      persona: row[0].toString(),
      ageRange: row[1].toString(),
      incomeBracket: row[2].toString(),
      financialGoal: row[3].toString(),
      riskTolerance: row[4].toString(),
      avgMonthlySpending: double.tryParse(row[5].toString()) ?? 0.0,
      avgMonthlySavings: double.tryParse(row[6].toString()) ?? 0.0,
      debtToIncomeRatio: double.tryParse(row[7].toString()) ?? 0.0,
      recNeeds: (double.tryParse(row[8].toString()) ?? 0.0) / 100.0, // Convert % to decimal
      recWants: (double.tryParse(row[9].toString()) ?? 0.0) / 100.0,
      recSavings: (double.tryParse(row[10].toString()) ?? 0.0) / 100.0,
      financialAdvice: row[11].toString(),
    );
  }
}

// 2. Define the PersonaService
class PersonaService {
  List<Persona>? _personaList;

  // Load and parse the CSV data (No Change)
  Future<void> _loadPersonaData() async {
    if (_personaList != null) return; // Data already loaded

    try {
      final rawData = await rootBundle.loadString('assets/synthetic_personal_finance_dataset.csv');
      final List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);
      
      // Skip the header row (index 0) and convert rows to Persona objects
      _personaList = csvTable.skip(1).map((row) => Persona.fromCsvRow(row)).toList();
    } catch (e) {
      print('Error loading persona data: $e');
      _personaList = []; // Init as empty list on error
    }
  }

  // Helper function to find the user's income bracket (No Change)
  String _getIncomeBracket(double monthlyIncome) {
    if (monthlyIncome <= 30000) return '<30k';
    if (monthlyIncome <= 60000) return '30k-60k';
    if (monthlyIncome <= 100000) return '60k-100k';
    return '>100k';
  }

  // Helper function to find the user's age range (No Change)
  String _getAgeRange(int age) {
    if (age <= 25) return '18-25';
    if (age <= 35) return '26-35';
    if (age <= 45) return '36-45';
    if (age <= 55) return '46-55';
    return '55+';
  }

  //
  // =================== LOGIC UPDATED HERE ===================
  //
  // 3. The main public method to get a persona
  Future<Persona?> getPersona({
    required int? age,
    required double monthlyIncome,
    required String? financialGoal,
  }) async {
    await _loadPersonaData(); // Ensure data is loaded

    if (_personaList == null || _personaList!.isEmpty || age == null || financialGoal == null) {
      return null; // Can't find a persona if data is missing
    }

    final String ageRange = _getAgeRange(age);
    final String incomeBracket = _getIncomeBracket(monthlyIncome);

    Persona? bestMatch;
    int bestScore = 0;

    for (final persona in _personaList!) {
      // Priority 1: Financial Goal MUST match.
      if (!persona.financialGoal.toLowerCase().contains(financialGoal.toLowerCase())) {
        continue; // Skip this persona entirely if the goal is different
      }

      int currentScore = 1; // We have a Goal match

      // Priority 2: Check Age match
      if (persona.ageRange == ageRange) {
        currentScore++;
      }

      // Priority 3: Check Income match
      if (persona.incomeBracket == incomeBracket) {
        currentScore++;
      }

      if (currentScore == 3) {
        // This is a perfect 3/3 match. Return it immediately.
        return persona;
      }

      if (currentScore > bestScore) {
        // This is the best partial match we've found so far (e.g., 2/3)
        bestScore = currentScore;
        bestMatch = persona;
      }
    }

    // After checking all personas, return the best match we found (which could be 2/3 or 1/3).
    // If no persona matched even the goal, bestMatch will be null.
    return bestMatch;
  }
}