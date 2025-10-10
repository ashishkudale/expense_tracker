import '../../../../core/utils/result.dart';
import '../entities/recurring_payment.dart';
import '../repositories/recurring_payment_repository.dart';

class GetRecurringPayments {
  final RecurringPaymentRepository repository;

  GetRecurringPayments(this.repository);

  Future<Result<List<RecurringPayment>>> call() {
    return repository.getRecurringPayments();
  }
}
