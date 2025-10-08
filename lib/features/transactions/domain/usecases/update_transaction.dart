import '../../../../core/utils/result.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransaction {
  final TransactionRepository _repository;

  UpdateTransaction(this._repository);

  Future<Result<Transaction>> call(UpdateTransactionParams params) async {
    if (params.id.trim().isEmpty) {
      return const Failure('Transaction ID cannot be empty');
    }

    if (params.categoryId.trim().isEmpty) {
      return const Failure('Category ID cannot be empty');
    }

    if (params.amount <= 0) {
      return const Failure('Amount must be greater than zero');
    }

    if (params.note != null && params.note!.trim().length > 500) {
      return const Failure('Note cannot be longer than 500 characters');
    }

    final transaction = Transaction(
      id: params.id.trim(),
      type: params.type,
      categoryId: params.categoryId.trim(),
      amount: params.amount,
      occurredOn: params.occurredOn,
      note: params.note?.trim().isEmpty == true ? null : params.note?.trim(),
      createdAt: params.createdAt,
    );

    return await _repository.updateTransaction(transaction);
  }
}

class UpdateTransactionParams {
  final String id;
  final TransactionType type;
  final String categoryId;
  final double amount;
  final DateTime occurredOn;
  final String? note;
  final DateTime createdAt;

  UpdateTransactionParams({
    required this.id,
    required this.type,
    required this.categoryId,
    required this.amount,
    required this.occurredOn,
    required this.createdAt,
    this.note,
  });
}
