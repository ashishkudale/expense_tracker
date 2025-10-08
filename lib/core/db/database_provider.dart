import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static const String _dbName = 'expense_tracker.db';
  static const int _dbVersion = 3;
  
  Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }
  
  Future<void> init() async {
    _database = await _initDB();
  }
  
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        currency_code TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL CHECK (type IN ('SPEND', 'EARN')),
        created_at INTEGER NOT NULL,
        archived INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL CHECK (type IN ('SPEND', 'EARN')),
        category_id TEXT NOT NULL,
        amount REAL NOT NULL,
        occurred_on INTEGER NOT NULL,
        note TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_category_id ON transactions (category_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_occurred_on ON transactions (occurred_on)
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_type ON transactions (type)
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _migrateToV2(db);
    }
    if (oldVersion < 3) {
      await _migrateToV3(db);
    }
  }
  
  Future<void> _migrateToV2(Database db) async {
    await db.execute('''
      ALTER TABLE categories ADD COLUMN archived INTEGER NOT NULL DEFAULT 0
    ''');
  }

  Future<void> _migrateToV3(Database db) async {
    // Add default categories for existing users
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Default income categories
    final incomeCategories = [
      {'id': 'income_salary', 'name': 'Salary', 'type': 'EARN'},
      {'id': 'income_bonus', 'name': 'Bonus', 'type': 'EARN'},
      {'id': 'income_freelance', 'name': 'Freelance', 'type': 'EARN'},
      {'id': 'income_investment', 'name': 'Investment', 'type': 'EARN'},
      {'id': 'income_business', 'name': 'Business', 'type': 'EARN'},
      {'id': 'income_gift', 'name': 'Gift', 'type': 'EARN'},
      {'id': 'income_other', 'name': 'Other Income', 'type': 'EARN'},
    ];

    // Default expense categories
    final expenseCategories = [
      {'id': 'expense_rent', 'name': 'Rent', 'type': 'SPEND'},
      {'id': 'expense_bills', 'name': 'Bills', 'type': 'SPEND'},
      {'id': 'expense_groceries', 'name': 'Groceries', 'type': 'SPEND'},
      {'id': 'expense_transportation', 'name': 'Transportation', 'type': 'SPEND'},
      {'id': 'expense_food', 'name': 'Food & Dining', 'type': 'SPEND'},
      {'id': 'expense_entertainment', 'name': 'Entertainment', 'type': 'SPEND'},
      {'id': 'expense_shopping', 'name': 'Shopping', 'type': 'SPEND'},
      {'id': 'expense_healthcare', 'name': 'Healthcare', 'type': 'SPEND'},
      {'id': 'expense_education', 'name': 'Education', 'type': 'SPEND'},
      {'id': 'expense_utilities', 'name': 'Utilities', 'type': 'SPEND'},
      {'id': 'expense_insurance', 'name': 'Insurance', 'type': 'SPEND'},
      {'id': 'expense_other', 'name': 'Other Expenses', 'type': 'SPEND'},
    ];

    // Insert income categories
    for (final category in incomeCategories) {
      await db.insert('categories', {
        'id': category['id'],
        'name': category['name'],
        'type': category['type'],
        'created_at': now,
        'archived': 0,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Insert expense categories
    for (final category in expenseCategories) {
      await db.insert('categories', {
        'id': category['id'],
        'name': category['name'],
        'type': category['type'],
        'created_at': now,
        'archived': 0,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
  
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}