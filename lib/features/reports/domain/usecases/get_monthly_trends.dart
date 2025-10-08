import '../../../../core/utils/result.dart';
import '../entities/report_entities.dart';
import '../repositories/report_repository.dart';

class GetMonthlyTrendsParams {
  final int monthsCount;

  const GetMonthlyTrendsParams({
    this.monthsCount = 6,
  });
}

class GetMonthlyTrends {
  final ReportRepository _repository;

  GetMonthlyTrends(this._repository);

  Future<Result<List<MonthlyTrend>>> call(GetMonthlyTrendsParams params) async {
    if (params.monthsCount <= 0 || params.monthsCount > 24) {
      return const Failure('Months count must be between 1 and 24');
    }

    return await _repository.getMonthlyTrends(
      monthsCount: params.monthsCount,
    );
  }
}