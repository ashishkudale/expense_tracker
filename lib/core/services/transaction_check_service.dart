import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../utils/result.dart';

class TransactionCheckService {
  final TransactionRepository _transactionRepository;

  TransactionCheckService(this._transactionRepository);

  /// Check if user has added any transaction today
  Future<bool> hasTransactionToday() async {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59, 999);

    final result = await _transactionRepository.getFilteredTransactions(
      startDate: startOfToday,
      endDate: endOfToday,
    );

    if (result is Success) {
      final transactions = (result as Success).data;
      return transactions.isNotEmpty;
    }

    // If there's an error, assume no transactions to be safe
    return false;
  }

  /// Get count of transactions added today
  Future<int> getTransactionCountToday() async {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59, 999);

    final result = await _transactionRepository.getFilteredTransactions(
      startDate: startOfToday,
      endDate: endOfToday,
    );

    if (result is Success) {
      final transactions = (result as Success).data;
      return transactions.length;
    }

    return 0;
  }
}
