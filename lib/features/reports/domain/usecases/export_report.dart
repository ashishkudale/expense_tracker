import '../../../../core/utils/result.dart';
import '../entities/report_entities.dart';
import '../repositories/report_repository.dart';

class ExportReportParams {
  final PeriodReport report;
  final String fileName;

  ExportReportParams({
    required this.report,
    String? fileName,
  }) : fileName = fileName ?? 'expense_report_${DateTime.now().millisecondsSinceEpoch}';
}

class ExportReport {
  final ReportRepository _repository;

  ExportReport(this._repository);

  Future<Result<String>> call(ExportReportParams params) async {
    return await _repository.exportReportToCSV(
      report: params.report,
      fileName: params.fileName,
    );
  }
}