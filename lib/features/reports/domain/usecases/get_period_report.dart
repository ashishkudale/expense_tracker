import '../../../../core/utils/result.dart';
import '../entities/report_entities.dart';
import '../repositories/report_repository.dart';

class GetPeriodReportParams {
  final ReportPeriod period;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const GetPeriodReportParams({
    required this.period,
    this.customStartDate,
    this.customEndDate,
  });

  DateTime get startDate {
    if (period == ReportPeriod.custom) {
      return customStartDate ?? DateTime.now().subtract(const Duration(days: 30));
    }

    final now = DateTime.now();
    switch (period) {
      case ReportPeriod.week:
        final weekday = now.weekday;
        return DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: weekday - 1));
      case ReportPeriod.month:
        return DateTime(now.year, now.month, 1);
      case ReportPeriod.year:
        return DateTime(now.year, 1, 1);
      default:
        return DateTime(now.year, now.month, 1);
    }
  }

  DateTime get endDate {
    if (period == ReportPeriod.custom) {
      return customEndDate ?? DateTime.now();
    }

    final now = DateTime.now();
    switch (period) {
      case ReportPeriod.week:
        final weekday = now.weekday;
        return DateTime(now.year, now.month, now.day)
            .add(Duration(days: 7 - weekday))
            .add(const Duration(hours: 23, minutes: 59, seconds: 59));
      case ReportPeriod.month:
        return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      case ReportPeriod.year:
        return DateTime(now.year, 12, 31, 23, 59, 59);
      default:
        return DateTime.now();
    }
  }
}

class GetPeriodReport {
  final ReportRepository _repository;

  GetPeriodReport(this._repository);

  Future<Result<PeriodReport>> call(GetPeriodReportParams params) async {
    return await _repository.getPeriodReport(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}