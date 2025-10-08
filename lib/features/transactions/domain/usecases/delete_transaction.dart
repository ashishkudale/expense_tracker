import '../../../../core/utils/result.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransaction {
  final TransactionRepository _repository;

  DeleteTransaction(this._repository);

  Future<Result<bool>> call(DeleteTransactionParams params) async {
    if (params.transactionId.trim().isEmpty) {
      return const Failure('Transaction ID cannot be empty');
    }

    return await _repository.deleteTransaction(params.transactionId);
  }
}

class DeleteTransactionParams {
  final String transactionId;

  DeleteTransactionParams({required this.transactionId});
}