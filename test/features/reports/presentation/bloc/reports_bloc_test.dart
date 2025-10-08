import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../lib/features/reports/domain/entities/report_entities.dart';
import '../../../../../lib/features/reports/presentation/bloc/reports_bloc.dart';
import '../../../../../lib/features/reports/presentation/bloc/reports_event.dart';
import '../../../../../lib/features/reports/presentation/bloc/reports_state.dart';
import '../../../../../lib/features/transactions/domain/entities/transaction.dart';

void main() {
  group('ReportsBloc', () {
    test('ReportPeriod enum values', () {
      expect(ReportPeriod.week.toString(), 'ReportPeriod.week');
      expect(ReportPeriod.month.toString(), 'ReportPeriod.month');
      expect(ReportPeriod.year.toString(), 'ReportPeriod.year');
      expect(ReportPeriod.custom.toString(), 'ReportPeriod.custom');
    });

    test('ReportsInitial state equality', () {
      expect(
        const ReportsInitial(),
        equals(const ReportsInitial()),
      );
    });

    test('ReportsLoading state equality', () {
      expect(
        const ReportsLoading(),
        equals(const ReportsLoading()),
      );
    });

    test('ReportsError state equality', () {
      expect(
        const ReportsError('Error message'),
        equals(const ReportsError('Error message')),
      );
    });

    test('ReportsLoaded state equality', () {
      final now = DateTime.now();
      final report = PeriodReport(
        startDate: now,
        endDate: now,
        totalIncome: 1000.0,
        totalExpense: 500.0,
        balance: 500.0,
        transactionCount: 5,
        categoryBreakdowns: const [],
        dailyTotals: const [],
      );
      
      final state1 = ReportsLoaded(
        periodReport: report,
        monthlyTrends: const [],
        selectedPeriod: ReportPeriod.month,
      );
      
      final state2 = ReportsLoaded(
        periodReport: report,
        monthlyTrends: const [],
        selectedPeriod: ReportPeriod.month,
      );
      
      expect(state1, equals(state2));
    });

    group('Events', () {
      test('ReportsLoadRequested equality', () {
        expect(
          const ReportsLoadRequested(),
          equals(const ReportsLoadRequested()),
        );
      });

      test('ReportPeriodChanged equality', () {
        expect(
          const ReportPeriodChanged(ReportPeriod.week),
          equals(const ReportPeriodChanged(ReportPeriod.week)),
        );
      });

      test('CustomDateRangeSelected equality', () {
        final now = DateTime.now();
        expect(
          CustomDateRangeSelected(
            startDate: now,
            endDate: now,
          ),
          equals(CustomDateRangeSelected(
            startDate: now,
            endDate: now,
          )),
        );
      });

      test('ReportExportRequested equality', () {
        final report = PeriodReport(
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          totalIncome: 1000.0,
          totalExpense: 500.0,
          balance: 500.0,
          transactionCount: 5,
          categoryBreakdowns: const [],
          dailyTotals: const [],
        );

        expect(
          ReportExportRequested(report),
          equals(ReportExportRequested(report)),
        );
      });

      test('MonthlyTrendsRequested equality', () {
        expect(
          const MonthlyTrendsRequested(monthsCount: 6),
          equals(const MonthlyTrendsRequested(monthsCount: 6)),
        );
      });
    });

    group('Report Entities', () {
      test('PeriodReport creation and equality', () {
        final now = DateTime.now();
        final report1 = PeriodReport(
          startDate: now,
          endDate: now,
          totalIncome: 1000.0,
          totalExpense: 500.0,
          balance: 500.0,
          transactionCount: 5,
          categoryBreakdowns: const [],
          dailyTotals: const [],
        );

        final report2 = PeriodReport(
          startDate: now,
          endDate: now,
          totalIncome: 1000.0,
          totalExpense: 500.0,
          balance: 500.0,
          transactionCount: 5,
          categoryBreakdowns: const [],
          dailyTotals: const [],
        );

        expect(report1, equals(report2));
      });

      test('PeriodReport savings rate calculation', () {
        final report = PeriodReport(
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          totalIncome: 1000.0,
          totalExpense: 600.0,
          balance: 400.0,
          transactionCount: 5,
          categoryBreakdowns: const [],
          dailyTotals: const [],
        );

        expect(report.savingsRate, 40.0);
      });

      test('PeriodReport savings rate with zero income', () {
        final report = PeriodReport(
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          totalIncome: 0.0,
          totalExpense: 600.0,
          balance: -600.0,
          transactionCount: 5,
          categoryBreakdowns: const [],
          dailyTotals: const [],
        );

        expect(report.savingsRate, 0.0);
      });

      test('CategoryBreakdown creation and equality', () {
        const breakdown1 = CategoryBreakdown(
          categoryId: '1',
          categoryName: 'Food',
          type: TransactionType.spend,
          amount: 100.0,
          transactionCount: 5,
          percentage: 25.0,
        );

        const breakdown2 = CategoryBreakdown(
          categoryId: '1',
          categoryName: 'Food',
          type: TransactionType.spend,
          amount: 100.0,
          transactionCount: 5,
          percentage: 25.0,
        );

        expect(breakdown1, equals(breakdown2));
      });

      test('DailyTotal creation and equality', () {
        final date = DateTime.now();
        final daily1 = DailyTotal(
          date: date,
          income: 100.0,
          expense: 50.0,
          balance: 50.0,
        );

        final daily2 = DailyTotal(
          date: date,
          income: 100.0,
          expense: 50.0,
          balance: 50.0,
        );

        expect(daily1, equals(daily2));
      });

      test('MonthlyTrend creation and equality', () {
        const trend1 = MonthlyTrend(
          month: 'Jan',
          year: 2024,
          totalIncome: 1000.0,
          totalExpense: 600.0,
          balance: 400.0,
        );

        const trend2 = MonthlyTrend(
          month: 'Jan',
          year: 2024,
          totalIncome: 1000.0,
          totalExpense: 600.0,
          balance: 400.0,
        );

        expect(trend1, equals(trend2));
      });
    });

    group('ReportsLoaded copyWith', () {
      test('should update fields correctly', () {
        final report = PeriodReport(
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          totalIncome: 1000.0,
          totalExpense: 500.0,
          balance: 500.0,
          transactionCount: 5,
          categoryBreakdowns: const [],
          dailyTotals: const [],
        );

        final originalState = ReportsLoaded(
          periodReport: report,
          monthlyTrends: const [],
          selectedPeriod: ReportPeriod.month,
        );

        final newTrends = [
          const MonthlyTrend(
            month: 'Jan',
            year: 2024,
            totalIncome: 1000.0,
            totalExpense: 600.0,
            balance: 400.0,
          ),
        ];

        final copiedState = originalState.copyWith(
          monthlyTrends: newTrends,
          selectedPeriod: ReportPeriod.year,
        );

        expect(copiedState.monthlyTrends, equals(newTrends));
        expect(copiedState.selectedPeriod, equals(ReportPeriod.year));
        expect(copiedState.periodReport, equals(report));
      });
    });
  });
}