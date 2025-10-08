import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/report_entities.dart';
import '../../domain/usecases/export_report.dart';
import '../../domain/usecases/get_monthly_trends.dart';
import '../../domain/usecases/get_period_report.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetPeriodReport _getPeriodReport;
  final GetMonthlyTrends _getMonthlyTrends;
  final ExportReport _exportReport;

  ReportsBloc({
    required GetPeriodReport getPeriodReport,
    required GetMonthlyTrends getMonthlyTrends,
    required ExportReport exportReport,
  })  : _getPeriodReport = getPeriodReport,
        _getMonthlyTrends = getMonthlyTrends,
        _exportReport = exportReport,
        super(const ReportsInitial()) {
    on<ReportsLoadRequested>(_onReportsLoadRequested);
    on<ReportPeriodChanged>(_onReportPeriodChanged);
    on<CustomDateRangeSelected>(_onCustomDateRangeSelected);
    on<ReportExportRequested>(_onReportExportRequested);
    on<MonthlyTrendsRequested>(_onMonthlyTrendsRequested);
  }

  Future<void> _onReportsLoadRequested(
    ReportsLoadRequested event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());

    final periodReportResult = await _getPeriodReport(
      GetPeriodReportParams(
        period: event.period,
        customStartDate: event.customStartDate,
        customEndDate: event.customEndDate,
      ),
    );

    final monthlyTrendsResult = await _getMonthlyTrends(
      const GetMonthlyTrendsParams(monthsCount: 6),
    );

    if (periodReportResult.isFailure) {
      emit(ReportsError(periodReportResult.error ?? 'Failed to load report'));
      return;
    }

    emit(ReportsLoaded(
      periodReport: periodReportResult.data!,
      monthlyTrends: monthlyTrendsResult.data ?? [],
      selectedPeriod: event.period,
      customStartDate: event.customStartDate,
      customEndDate: event.customEndDate,
    ));
  }

  Future<void> _onReportPeriodChanged(
    ReportPeriodChanged event,
    Emitter<ReportsState> emit,
  ) async {
    if (state is ReportsLoaded) {
      add(ReportsLoadRequested(period: event.period));
    }
  }

  Future<void> _onCustomDateRangeSelected(
    CustomDateRangeSelected event,
    Emitter<ReportsState> emit,
  ) async {
    add(ReportsLoadRequested(
      period: ReportPeriod.custom,
      customStartDate: event.startDate,
      customEndDate: event.endDate,
    ));
  }

  Future<void> _onReportExportRequested(
    ReportExportRequested event,
    Emitter<ReportsState> emit,
  ) async {
    final currentState = state;
    emit(const ReportExporting());

    final result = await _exportReport(
      ExportReportParams(report: event.report),
    );

    if (result.isSuccess) {
      emit(ReportExported(result.data!));
      await Future.delayed(const Duration(seconds: 2));
      if (currentState is ReportsLoaded) {
        emit(currentState);
      }
    } else {
      emit(ReportsError(result.error ?? 'Failed to export report'));
      await Future.delayed(const Duration(seconds: 2));
      if (currentState is ReportsLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onMonthlyTrendsRequested(
    MonthlyTrendsRequested event,
    Emitter<ReportsState> emit,
  ) async {
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;
      
      final result = await _getMonthlyTrends(
        GetMonthlyTrendsParams(monthsCount: event.monthsCount),
      );

      if (result.isSuccess) {
        emit(currentState.copyWith(monthlyTrends: result.data));
      }
    }
  }
}