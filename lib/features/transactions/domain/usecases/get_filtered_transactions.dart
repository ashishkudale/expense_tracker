import '../../../../core/utils/result.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetFilteredTransactions {
  final TransactionRepository _repository;

  GetFilteredTransactions(this._repository);

  Future<Result<List<Transaction>>> call(GetFilteredTransactionsParams params) async {
    return await _repository.getFilteredTransactions(
      type: params.type,
      categoryId: params.categoryId,
      searchQuery: params.searchQuery,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetFilteredTransactionsParams {
  final TransactionType? type;
  final String? categoryId;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  GetFilteredTransactionsParams({
    this.type,
    this.categoryId,
    this.searchQuery,
    this.startDate,
    this.endDate,
  });
}