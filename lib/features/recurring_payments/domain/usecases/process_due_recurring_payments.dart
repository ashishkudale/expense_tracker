import 'package:uuid/uuid.dart';
import '../../../../core/utils/result.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../entities/recurring_payment.dart';
import '../repositories/recurring_payment_repository.dart';

class ProcessDueRecurringPayments {
  final RecurringPaymentRepository recurringPaymentRepository;
  final TransactionRepository transactionRepository;
  final Uuid uuid = const Uuid();

  ProcessDueRecurringPayments(
    this.recurringPaymentRepository,
    this.transactionRepository,
  );

  Future<Result<int>> call() async {
    try {
      // Get all due recurring payments
      final duePaymentsResult = await recurringPaymentRepository.getDueRecurringPayments();

      if (duePaymentsResult.isFailure) {
        return Failure(duePaymentsResult.error!);
      }

      final duePayments = duePaymentsResult.data ?? [];
      int processedCount = 0;

      for (final payment in duePayments) {
        // Create transaction from recurring payment
        final transaction = Transaction(
          id: uuid.v4(),
          type: payment.type,
          categoryId: payment.categoryId,
          amount: payment.amount,
          occurredOn: DateTime.now(),
          note: payment.note != null
              ? '${payment.note} (Recurring - ${payment.frequency.displayName})'
              : 'Recurring - ${payment.frequency.displayName}',
          createdAt: DateTime.now(),
        );

        // Add transaction
        final addResult = await transactionRepository.addTransaction(transaction);

        if (addResult.isSuccess) {
          // Update last processed date
          final updatedPayment = RecurringPayment(
            id: payment.id,
            type: payment.type,
            categoryId: payment.categoryId,
            amount: payment.amount,
            note: payment.note,
            frequency: payment.frequency,
            startDate: payment.startDate,
            endDate: payment.endDate,
            lastProcessedDate: DateTime.now(),
            isActive: payment.isActive,
            createdAt: payment.createdAt,
          );

          await recurringPaymentRepository.updateRecurringPayment(updatedPayment);
          processedCount++;
        }
      }

      return Success(processedCount);
    } catch (e) {
      return Failure('Failed to process recurring payments: ${e.toString()}');
    }
  }
}
