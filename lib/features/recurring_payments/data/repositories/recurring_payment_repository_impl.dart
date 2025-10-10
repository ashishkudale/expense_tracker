import 'package:sqflite/sqflite.dart';
import '../../../../core/db/database_provider.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/recurring_payment.dart';
import '../../domain/repositories/recurring_payment_repository.dart';
import '../models/recurring_payment_model.dart';

class RecurringPaymentRepositoryImpl implements RecurringPaymentRepository {
  final DatabaseProvider _databaseProvider;

  RecurringPaymentRepositoryImpl(this._databaseProvider);

  @override
  Future<Result<List<RecurringPayment>>> getRecurringPayments() async {
    try {
      final db = await _databaseProvider.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'recurring_payments',
        orderBy: 'created_at DESC',
      );

      final payments = maps.map((map) => RecurringPaymentModel.fromMap(map)).toList();
      return Success(payments);
    } catch (e) {
      return Failure('Failed to get recurring payments: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<RecurringPayment>>> getActiveRecurringPayments() async {
    try {
      final db = await _databaseProvider.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'recurring_payments',
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: 'created_at DESC',
      );

      final payments = maps.map((map) => RecurringPaymentModel.fromMap(map)).toList();
      return Success(payments);
    } catch (e) {
      return Failure('Failed to get active recurring payments: ${e.toString()}');
    }
  }

  @override
  Future<Result<RecurringPayment?>> getRecurringPaymentById(String id) async {
    try {
      final db = await _databaseProvider.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'recurring_payments',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        return const Success(null);
      }

      final payment = RecurringPaymentModel.fromMap(maps.first);
      return Success(payment);
    } catch (e) {
      return Failure('Failed to get recurring payment: ${e.toString()}');
    }
  }

  @override
  Future<Result<RecurringPayment>> addRecurringPayment(RecurringPayment payment) async {
    try {
      final db = await _databaseProvider.database;
      final model = RecurringPaymentModel.fromEntity(payment);

      await db.insert(
        'recurring_payments',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Success(payment);
    } catch (e) {
      return Failure('Failed to add recurring payment: ${e.toString()}');
    }
  }

  @override
  Future<Result<RecurringPayment>> updateRecurringPayment(RecurringPayment payment) async {
    try {
      final db = await _databaseProvider.database;
      final model = RecurringPaymentModel.fromEntity(payment);

      await db.update(
        'recurring_payments',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [payment.id],
      );

      return Success(payment);
    } catch (e) {
      return Failure('Failed to update recurring payment: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteRecurringPayment(String id) async {
    try {
      final db = await _databaseProvider.database;
      await db.delete(
        'recurring_payments',
        where: 'id = ?',
        whereArgs: [id],
      );

      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete recurring payment: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> toggleRecurringPaymentStatus(String id, bool isActive) async {
    try {
      final db = await _databaseProvider.database;
      await db.update(
        'recurring_payments',
        {'is_active': isActive ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );

      return const Success(null);
    } catch (e) {
      return Failure('Failed to toggle recurring payment status: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<RecurringPayment>>> getDueRecurringPayments() async {
    try {
      final db = await _databaseProvider.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'recurring_payments',
        where: 'is_active = ?',
        whereArgs: [1],
      );

      final payments = maps
          .map((map) => RecurringPaymentModel.fromMap(map))
          .where((payment) => payment.shouldProcess)
          .toList();

      return Success(payments);
    } catch (e) {
      return Failure('Failed to get due recurring payments: ${e.toString()}');
    }
  }
}
