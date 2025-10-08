import 'package:uuid/uuid.dart';
import '../../../../core/utils/result.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class AddTransaction {
  final TransactionRepository _repository;

  AddTransaction(this._repository);

  Future<Result<Transaction>> call(AddTransactionParams params) async {
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
      id: const Uuid().v4(),
      type: params.type,
      categoryId: params.categoryId.trim(),
      amount: params.amount,
      occurredOn: params.occurredOn,
      note: params.note?.trim().isEmpty == true ? null : params.note?.trim(),
      createdAt: DateTime.now(),
    );

    return await _repository.addTransaction(transaction);
  }
}

class AddTransactionParams {
  final TransactionType type;
  final String categoryId;
  final double amount;
  final DateTime occurredOn;
  final String? note;

  AddTransactionParams({
    required this.type,
    required this.categoryId,
    required this.amount,
    required this.occurredOn,
    this.note,
  });
}