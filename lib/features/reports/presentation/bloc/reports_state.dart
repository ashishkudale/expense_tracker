import 'package:equatable/equatable.dart';
import '../../domain/entities/report_entities.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

class ReportsLoaded extends ReportsState {
  final PeriodReport periodReport;
  final List<MonthlyTrend> monthlyTrends;
  final ReportPeriod selectedPeriod;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const ReportsLoaded({
    required this.periodReport,
    required this.monthlyTrends,
    required this.selectedPeriod,
    this.customStartDate,
    this.customEndDate,
  });

  @override
  List<Object?> get props => [
        periodReport,
        monthlyTrends,
        selectedPeriod,
        customStartDate,
        customEndDate,
      ];

  ReportsLoaded copyWith({
    PeriodReport? periodReport,
    List<MonthlyTrend>? monthlyTrends,
    ReportPeriod? selectedPeriod,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    return ReportsLoaded(
      periodReport: periodReport ?? this.periodReport,
      monthlyTrends: monthlyTrends ?? this.monthlyTrends,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
    );
  }
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReportExporting extends ReportsState {
  const ReportExporting();
}

class ReportExported extends ReportsState {
  final String filePath;

  const ReportExported(this.filePath);

  @override
  List<Object?> get props => [filePath];
}