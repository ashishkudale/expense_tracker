import '../../../../core/utils/result.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactions {
  final TransactionRepository _repository;

  GetTransactions(this._repository);

  Future<Result<List<Transaction>>> call() async {
    return await _repository.getTransactions();
  }
}