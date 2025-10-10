import '../../../../core/utils/result.dart';
import '../repositories/recurring_payment_repository.dart';

class DeleteRecurringPayment {
  final RecurringPaymentRepository repository;

  DeleteRecurringPayment(this.repository);

  Future<Result<void>> call(String id) {
    return repository.deleteRecurringPayment(id);
  }
}
