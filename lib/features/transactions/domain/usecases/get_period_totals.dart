import '../../../../core/utils/result.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetPeriodTotals {
  final TransactionRepository _repository;

  GetPeriodTotals(this._repository);

  Future<Result<PeriodTotals>> call(GetPeriodTotalsParams params) async {
    return _getPeriodTotals(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }

  Future<Result<PeriodTotals>> _getPeriodTotals({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final spendResult = await _repository.getTotalForPeriod(
      startDate: startDate,
      endDate: endDate,
      type: TransactionType.spend,
    );

    if (spendResult.isFailure) {
      return Failure(spendResult.error!);
    }

    final earnResult = await _repository.getTotalForPeriod(
      startDate: startDate,
      endDate: endDate,
      type: TransactionType.earn,
    );

    if (earnResult.isFailure) {
      return Failure(earnResult.error!);
    }

    return Success(PeriodTotals(
      totalSpent: spendResult.data!,
      totalEarned: earnResult.data!,
    ));
  }
}

class GetPeriodTotalsParams {
  final DateTime startDate;
  final DateTime endDate;

  GetPeriodTotalsParams({
    required this.startDate,
    required this.endDate,
  });
}

class PeriodTotals {
  final double totalSpent;
  final double totalEarned;

  PeriodTotals({
    required this.totalSpent,
    required this.totalEarned,
  });

  double get balance => totalEarned - totalSpent;
  double get totalIncome => totalEarned;
  double get totalExpense => totalSpent;
}