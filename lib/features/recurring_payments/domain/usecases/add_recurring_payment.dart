import '../../../../core/utils/result.dart';
import '../entities/recurring_payment.dart';
import '../repositories/recurring_payment_repository.dart';

class AddRecurringPayment {
  final RecurringPaymentRepository repository;

  AddRecurringPayment(this.repository);

  Future<Result<RecurringPayment>> call(RecurringPayment payment) {
    return repository.addRecurringPayment(payment);
  }
}
