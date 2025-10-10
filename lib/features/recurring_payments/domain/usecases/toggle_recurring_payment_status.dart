import '../../../../core/utils/result.dart';
import '../repositories/recurring_payment_repository.dart';

class ToggleRecurringPaymentStatus {
  final RecurringPaymentRepository repository;

  ToggleRecurringPaymentStatus(this.repository);

  Future<Result<void>> call(String id, bool isActive) {
    return repository.toggleRecurringPaymentStatus(id, isActive);
  }
}
