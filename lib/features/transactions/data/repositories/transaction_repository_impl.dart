import 'package:sqflite/sqflite.dart' hide Transaction;
import '../../../../core/db/database_provider.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final DatabaseProvider _databaseProvider;

  TransactionRepositoryImpl(this._databaseProvider);

  @override
  Future<Result<List<Transaction>>> getTransactions() async {
    try {
      final db = await _databaseProvider.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        orderBy: 'occurred_on DESC, created_at DESC',
      );

      final transactions = maps.map(TransactionModel.fromMap).toList();
      return Success(transactions);
    } catch (e) {
      return Failure('Failed to get transactions: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Transaction>>> getTransactionsByType(TransactionType type) async {
    try {
      final db = await _databaseProvider.database;
      final typeString = type == TransactionType.spend ? 'SPEND' : 'EARN';
      
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'type = ?',
        whereArgs: [typeString],
        orderBy: 'occurred_on DESC, created_at DESC',
      );

      final transactions = maps.map(TransactionModel.fromMap).toList();
      return Success(transactions);
    } catch (e) {
      return Failure('Failed to get transactions by type: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Transaction>>> getTransactionsByCategory(String categoryId) async {
    try {
      final db = await _databaseProvider.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'category_id = ?',
        whereArgs: [categoryId],
        orderBy: 'occurred_on DESC, created_at DESC',
      );

      final transactions = maps.map(TransactionModel.fromMap).toList();
      return Success(transactions);
    } catch (e) {
      return Failure('Failed to get transactions by category: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Transaction>>> searchTransactionsByNote(String query) async {
    try {
      final db = await _databaseProvider.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'note LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'occurred_on DESC, created_at DESC',
      );

      final transactions = maps.map(TransactionModel.fromMap).toList();
      return Success(transactions);
    } catch (e) {
      return Failure('Failed to search transactions: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Transaction>>> getFilteredTransactions({
    TransactionType? type,
    String? categoryId,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final db = await _databaseProvider.database;
      
      String whereClause = '';
      List<dynamic> whereArgs = [];
      
      if (type != null) {
        whereClause += 'type = ?';
        whereArgs.add(type == TransactionType.spend ? 'SPEND' : 'EARN');
      }
      
      if (categoryId != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'category_id = ?';
        whereArgs.add(categoryId);
      }
      
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'note LIKE ?';
        whereArgs.add('%${searchQuery.trim()}%');
      }
      
      if (startDate != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'occurred_on >= ?';
        whereArgs.add(startDate.millisecondsSinceEpoch);
      }
      
      if (endDate != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'occurred_on <= ?';
        whereArgs.add(endDate.millisecondsSinceEpoch);
      }
      
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: whereClause.isEmpty ? null : whereClause,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: 'occurred_on DESC, created_at DESC',
      );

      final transactions = maps.map(TransactionModel.fromMap).toList();
      return Success(transactions);
    } catch (e) {
      return Failure('Failed to get filtered transactions: ${e.toString()}');
    }
  }

  @override
  Future<Result<Transaction>> addTransaction(Transaction transaction) async {
    try {
      final db = await _databaseProvider.database;
      final model = TransactionModel.fromEntity(transaction);
      
      await db.insert(
        'transactions',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Success(transaction);
    } catch (e) {
      return Failure('Failed to add transaction: ${e.toString()}');
    }
  }

  @override
  Future<Result<Transaction>> updateTransaction(Transaction transaction) async {
    try {
      final db = await _databaseProvider.database;
      final model = TransactionModel.fromEntity(transaction);
      
      final updatedRows = await db.update(
        'transactions',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );

      if (updatedRows == 0) {
        return const Failure('Transaction not found');
      }

      return Success(transaction);
    } catch (e) {
      return Failure('Failed to update transaction: ${e.toString()}');
    }
  }

  @override
  Future<Result<bool>> deleteTransaction(String transactionId) async {
    try {
      final db = await _databaseProvider.database;
      
      final deletedRows = await db.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [transactionId],
      );

      return Success(deletedRows > 0);
    } catch (e) {
      return Failure('Failed to delete transaction: ${e.toString()}');
    }
  }

  @override
  Future<Result<double>> getTotalForPeriod({
    required DateTime startDate,
    required DateTime endDate,
    TransactionType? type,
  }) async {
    try {
      final db = await _databaseProvider.database;
      
      String whereClause = 'occurred_on >= ? AND occurred_on <= ?';
      List<dynamic> whereArgs = [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ];
      
      if (type != null) {
        whereClause += ' AND type = ?';
        whereArgs.add(type == TransactionType.spend ? 'SPEND' : 'EARN');
      }
      
      final List<Map<String, dynamic>> result = await db.query(
        'transactions',
        columns: ['SUM(amount) as total'],
        where: whereClause,
        whereArgs: whereArgs,
      );

      final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
      return Success(total);
    } catch (e) {
      return Failure('Failed to get total for period: ${e.toString()}');
    }
  }
}