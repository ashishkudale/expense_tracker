import '../../../../core/utils/result.dart';
import '../entities/report_entities.dart';

abstract class ReportRepository {
  Future<Result<PeriodReport>> getPeriodReport({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Result<List<CategoryBreakdown>>> getCategoryBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Result<List<MonthlyTrend>>> getMonthlyTrends({
    required int monthsCount,
  });

  Future<Result<List<DailyTotal>>> getDailyTotals({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Result<String>> exportReportToCSV({
    required PeriodReport report,
    required String fileName,
  });
}