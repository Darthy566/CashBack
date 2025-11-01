// lib/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// --- User Model (Updated) ---
class User {
  int? id;
  String firstName;
  String lastName;
  String email;
  String password;
  
  // New fields from UI
  String? age;
  String? dateOfBirth;
  String? occupation;
  String? contactNumber;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.age,
    this.dateOfBirth,
    this.occupation,
    this.contactNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'age': age,
      'dateOfBirth': dateOfBirth,
      'occupation': occupation,
      'contactNumber': contactNumber,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      password: map['password'],
      age: map['age'],
      dateOfBirth: map['dateOfBirth'],
      occupation: map['occupation'],
      contactNumber: map['contactNumber'],
    );
  }
}

// --- Goal Model ---
class Goal {
  int? id;
  int userId;
  String title;
  double amount;
  String status;
  int? timeToAchieveMonths;
  String? completionDate;

  Goal({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    this.status = 'active',
    this.timeToAchieveMonths,
    this.completionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'status': status,
      'timeToAchieveMonths': timeToAchieveMonths,
      'completionDate': completionDate,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      amount: map['amount'],
      status: map['status'],
      timeToAchieveMonths: map['timeToAchieveMonths'],
      completionDate: map['completionDate'],
    );
  }
}

// --- Transaction Model ---
class Transaction {
  int? id;
  int userId;
  String title;
  double amount;
  String type;
  String category;
  String date;

  Transaction({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      amount: map['amount'],
      type: map['type'],
      category: map['category'],
      date: map['date'],
    );
  }
}

// --- Simulation Model ---
class Simulation {
  int? id;
  int userId;
  String stockSymbol;
  double initialInvestment;
  double monthlyContribution;
  int years;
  double projectedValue;
  double cagr;
  double avgReturn;

  Simulation({
    this.id,
    required this.userId,
    required this.stockSymbol,
    required this.initialInvestment,
    required this.monthlyContribution,
    required this.years,
    required this.projectedValue,
    required this.cagr,
    required this.avgReturn,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'stockSymbol': stockSymbol,
      'initialInvestment': initialInvestment,
      'monthlyContribution': monthlyContribution,
      'years': years,
      'projectedValue': projectedValue,
      'cagr': cagr,
      'avgReturn': avgReturn,
    };
  }

  factory Simulation.fromMap(Map<String, dynamic> map) {
    return Simulation(
      id: map['id'],
      userId: map['userId'],
      stockSymbol: map['stockSymbol'],
      initialInvestment: map['initialInvestment'],
      monthlyContribution: map['monthlyContribution'],
      years: map['years'],
      projectedValue: map['projectedValue'],
      cagr: map['cagr'],
      avgReturn: map['avgReturn'],
    );
  }
}


// --- DatabaseHelper Class (Updated) ---
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'cashback_database.db');
    return await openDatabase(
      path,
      version: 3, // Incremented version to 3
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Added upgrade path
    );
  }

  // --- onUpgrade (Updated) ---
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE goals ADD COLUMN timeToAchieveMonths INTEGER');
      await db.execute('ALTER TABLE goals ADD COLUMN completionDate TEXT');
    }
    if (oldVersion < 3) {
      // Add new user columns
      await db.execute('ALTER TABLE users ADD COLUMN age TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN dateOfBirth TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN occupation TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN contactNumber TEXT');
    }
  }

  // --- onCreate (Updated) ---
  Future<void> _onCreate(Database db, int version) async {
    // Users Table (Updated)
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        age TEXT,
        dateOfBirth TEXT,
        occupation TEXT,
        contactNumber TEXT
      )
    ''');
    
    // Goals Table
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        status TEXT NOT NULL,
        timeToAchieveMonths INTEGER,
        completionDate TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    
    // Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Simulations Table
    await db.execute('''
      CREATE TABLE simulations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        stockSymbol TEXT NOT NULL,
        initialInvestment REAL NOT NULL,
        monthlyContribution REAL NOT NULL,
        years INTEGER NOT NULL,
        projectedValue REAL NOT NULL,
        cagr REAL NOT NULL,
        avgReturn REAL NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- User Methods ---
  Future<int> addUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
  
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // --- New Delete User Method ---
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Goal Methods ---
  Future<int> addGoal(Goal goal) async {
    final db = await database;
    return await db.insert('goals', goal.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Goal>> getGoals(int userId, {String? status}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;
    if (status != null) {
      maps = await db.query(
        'goals',
        where: 'userId = ? AND status = ?',
        whereArgs: [userId, status],
      );
    } else {
      maps = await db.query('goals', where: 'userId = ?', whereArgs: [userId]);
    }

    return List.generate(maps.length, (i) {
      return Goal.fromMap(maps[i]);
    });
  }
  
  Future<Goal?> getGoal(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Goal.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateGoal(Goal goal) async {
    final db = await database;
    return await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // --- Transaction Methods ---
  Future<int> addTransaction(Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<List<Transaction>> getTransactions(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'userId = ?',
      orderBy: 'date DESC',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }
  
  Future<Transaction?> getTransaction(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Transaction.fromMap(maps.first);
    }
    return null;
  }
  
  Future<double> getTotalAmount(int userId, String type) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE userId = ? AND type = ?',
      [userId, type],
    );
    return (result.first['total'] as double?) ?? 0.0;
  }
  
  Future<Map<String, double>> getExpensesByCategory(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT category, SUM(amount) as total FROM transactions WHERE userId = ? AND type = ? GROUP BY category',
      [userId, 'Expense'],
    );
    
    Map<String, double> categoryTotals = {};
    for (var row in result) {
      categoryTotals[row['category']] = (row['total'] as double?) ?? 0.0;
    }
    return categoryTotals;
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // --- Simulation Methods ---
  Future<int> addSimulation(Simulation simulation) async {
    final db = await database;
    return await db.insert('simulations', simulation.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<List<Simulation>> getSimulations(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'simulations',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return Simulation.fromMap(maps[i]);
    });
  }

  Future<int> deleteSimulation(int id) async {
    final db = await database;
    return await db.delete(
      'simulations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}