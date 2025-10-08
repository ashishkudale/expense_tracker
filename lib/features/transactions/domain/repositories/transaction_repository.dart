import '../../../../core/utils/result.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Result<List<Transaction>>> getTransactions();
  Future<Result<List<Transaction>>> getTransactionsByType(TransactionType type);
  Future<Result<List<Transaction>>> getTransactionsByCategory(String categoryId);
  Future<Result<List<Transaction>>> searchTransactionsByNote(String query);
  Future<Result<List<Transaction>>> getFilteredTransactions({
    TransactionType? type,
    String? categoryId,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Result<Transaction>> addTransaction(Transaction transaction);
  Future<Result<Transaction>> updateTransaction(Transaction transaction);
  Future<Result<bool>> deleteTransaction(String transactionId);
  Future<Result<double>> getTotalForPeriod({
    required DateTime startDate,
    required DateTime endDate,
    TransactionType? type,
  });
}