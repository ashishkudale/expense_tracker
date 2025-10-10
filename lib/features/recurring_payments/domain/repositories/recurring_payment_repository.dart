import '../../../../core/utils/result.dart';
import '../entities/recurring_payment.dart';

abstract class RecurringPaymentRepository {
  Future<Result<List<RecurringPayment>>> getRecurringPayments();
  Future<Result<List<RecurringPayment>>> getActiveRecurringPayments();
  Future<Result<RecurringPayment?>> getRecurringPaymentById(String id);
  Future<Result<RecurringPayment>> addRecurringPayment(RecurringPayment payment);
  Future<Result<RecurringPayment>> updateRecurringPayment(RecurringPayment payment);
  Future<Result<void>> deleteRecurringPayment(String id);
  Future<Result<void>> toggleRecurringPaymentStatus(String id, bool isActive);
  Future<Result<List<RecurringPayment>>> getDueRecurringPayments();
}
