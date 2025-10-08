import 'package:equatable/equatable.dart';
import '../../domain/entities/report_entities.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class ReportsLoadRequested extends ReportsEvent {
  final ReportPeriod period;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const ReportsLoadRequested({
    this.period = ReportPeriod.month,
    this.customStartDate,
    this.customEndDate,
  });

  @override
  List<Object?> get props => [period, customStartDate, customEndDate];
}

class ReportPeriodChanged extends ReportsEvent {
  final ReportPeriod period;

  const ReportPeriodChanged(this.period);

  @override
  List<Object?> get props => [period];
}

class CustomDateRangeSelected extends ReportsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const CustomDateRangeSelected({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class ReportExportRequested extends ReportsEvent {
  final PeriodReport report;

  const ReportExportRequested(this.report);

  @override
  List<Object?> get props => [report];
}

class MonthlyTrendsRequested extends ReportsEvent {
  final int monthsCount;

  const MonthlyTrendsRequested({this.monthsCount = 6});

  @override
  List<Object?> get props => [monthsCount];
}