import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../../core/db/database_provider.dart';
import '../../../../core/utils/result.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/entities/report_entities.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final DatabaseProvider _databaseProvider;

  ReportRepositoryImpl(this._databaseProvider);

  @override
  Future<Result<PeriodReport>> getPeriodReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final db = await _databaseProvider.database;
      
      // Get total income and expense
      final totalsResult = await db.rawQuery('''
        SELECT 
          SUM(CASE WHEN type = 'EARN' THEN amount ELSE 0 END) as total_income,
          SUM(CASE WHEN type = 'SPEND' THEN amount ELSE 0 END) as total_expense,
          COUNT(*) as transaction_count
        FROM transactions
        WHERE occurred_on BETWEEN ? AND ?
      ''', [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);

      final totals = totalsResult.first;
      final totalIncome = (totals['total_income'] as num?)?.toDouble() ?? 0.0;
      final totalExpense = (totals['total_expense'] as num?)?.toDouble() ?? 0.0;
      final transactionCount = (totals['transaction_count'] as int?) ?? 0;

      // Get category breakdowns
      final categoryBreakdownResult = await getCategoryBreakdown(
        startDate: startDate,
        endDate: endDate,
      );
      
      final categoryBreakdowns = categoryBreakdownResult.isSuccess
          ? categoryBreakdownResult.data ?? <CategoryBreakdown>[]
          : <CategoryBreakdown>[];

      // Get daily totals
      final dailyTotalsResult = await getDailyTotals(
        startDate: startDate,
        endDate: endDate,
      );
      
      final dailyTotals = dailyTotalsResult.isSuccess
          ? dailyTotalsResult.data ?? <DailyTotal>[]
          : <DailyTotal>[];

      return Success(PeriodReport(
        startDate: startDate,
        endDate: endDate,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: totalIncome - totalExpense,
        transactionCount: transactionCount,
        categoryBreakdowns: categoryBreakdowns,
        dailyTotals: dailyTotals,
      ));
    } catch (e) {
      return Failure('Failed to generate period report: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<CategoryBreakdown>>> getCategoryBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final db = await _databaseProvider.database;
      
      final result = await db.rawQuery('''
        SELECT 
          c.id as category_id,
          c.name as category_name,
          c.type as category_type,
          SUM(t.amount) as total_amount,
          COUNT(t.id) as transaction_count
        FROM transactions t
        INNER JOIN categories c ON t.category_id = c.id
        WHERE t.occurred_on BETWEEN ? AND ?
        GROUP BY c.id, c.name, c.type
        ORDER BY total_amount DESC
      ''', [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);

      // Calculate totals for percentage
      final totalSpend = result
          .where((r) => r['category_type'] == 'SPEND')
          .fold<double>(0, (sum, r) => sum + ((r['total_amount'] as num?)?.toDouble() ?? 0));
      
      final totalEarn = result
          .where((r) => r['category_type'] == 'EARN')
          .fold<double>(0, (sum, r) => sum + ((r['total_amount'] as num?)?.toDouble() ?? 0));

      final breakdowns = result.map((row) {
        final type = row['category_type'] == 'SPEND' 
            ? TransactionType.spend 
            : TransactionType.earn;
        final amount = (row['total_amount'] as num?)?.toDouble() ?? 0.0;
        final total = type == TransactionType.spend ? totalSpend : totalEarn;
        
        return CategoryBreakdown(
          categoryId: row['category_id'] as String,
          categoryName: row['category_name'] as String,
          type: type,
          amount: amount,
          transactionCount: (row['transaction_count'] as int?) ?? 0,
          percentage: total > 0 ? (amount / total * 100) : 0,
        );
      }).toList();

      return Success(breakdowns);
    } catch (e) {
      return Failure('Failed to get category breakdown: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<MonthlyTrend>>> getMonthlyTrends({
    required int monthsCount,
  }) async {
    try {
      final db = await _databaseProvider.database;
      final endDate = DateTime.now();
      final startDate = DateTime(endDate.year, endDate.month - monthsCount + 1, 1);
      
      final result = await db.rawQuery('''
        SELECT 
          strftime('%Y', datetime(occurred_on/1000, 'unixepoch')) as year,
          strftime('%m', datetime(occurred_on/1000, 'unixepoch')) as month,
          SUM(CASE WHEN type = 'EARN' THEN amount ELSE 0 END) as total_income,
          SUM(CASE WHEN type = 'SPEND' THEN amount ELSE 0 END) as total_expense
        FROM transactions
        WHERE occurred_on >= ?
        GROUP BY year, month
        ORDER BY year, month
      ''', [startDate.millisecondsSinceEpoch]);

      final trends = result.map((row) {
        final totalIncome = (row['total_income'] as num?)?.toDouble() ?? 0.0;
        final totalExpense = (row['total_expense'] as num?)?.toDouble() ?? 0.0;
        
        return MonthlyTrend(
          month: _getMonthName(int.parse(row['month'] as String)),
          year: int.parse(row['year'] as String),
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          balance: totalIncome - totalExpense,
        );
      }).toList();

      return Success(trends);
    } catch (e) {
      return Failure('Failed to get monthly trends: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<DailyTotal>>> getDailyTotals({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final db = await _databaseProvider.database;
      
      final result = await db.rawQuery('''
        SELECT 
          date(datetime(occurred_on/1000, 'unixepoch')) as date,
          SUM(CASE WHEN type = 'EARN' THEN amount ELSE 0 END) as income,
          SUM(CASE WHEN type = 'SPEND' THEN amount ELSE 0 END) as expense
        FROM transactions
        WHERE occurred_on BETWEEN ? AND ?
        GROUP BY date(datetime(occurred_on/1000, 'unixepoch'))
        ORDER BY date(datetime(occurred_on/1000, 'unixepoch'))
      ''', [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);

      final dailyTotals = result.map((row) {
        final income = (row['income'] as num?)?.toDouble() ?? 0.0;
        final expense = (row['expense'] as num?)?.toDouble() ?? 0.0;
        
        return DailyTotal(
          date: DateTime.parse(row['date'] as String),
          income: income,
          expense: expense,
          balance: income - expense,
        );
      }).toList();

      return Success(dailyTotals);
    } catch (e) {
      return Failure('Failed to get daily totals: ${e.toString()}');
    }
  }

  @override
  Future<Result<String>> exportReportToCSV({
    required PeriodReport report,
    required String fileName,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.csv');
      
      final csvContent = StringBuffer();
      
      // Header
      csvContent.writeln('Expense Report');
      csvContent.writeln('Period: ${_formatDate(report.startDate)} to ${_formatDate(report.endDate)}');
      csvContent.writeln('');
      
      // Summary
      csvContent.writeln('Summary');
      csvContent.writeln('Total Income,${report.totalIncome.toStringAsFixed(2)}');
      csvContent.writeln('Total Expense,${report.totalExpense.toStringAsFixed(2)}');
      csvContent.writeln('Balance,${report.balance.toStringAsFixed(2)}');
      csvContent.writeln('Savings Rate,${report.savingsRate.toStringAsFixed(1)}%');
      csvContent.writeln('Total Transactions,${report.transactionCount}');
      csvContent.writeln('');
      
      // Category Breakdown
      csvContent.writeln('Category Breakdown');
      csvContent.writeln('Category,Type,Amount,Transactions,Percentage');
      for (final category in report.categoryBreakdowns) {
        csvContent.writeln(
          '${category.categoryName},${category.type.name},${category.amount.toStringAsFixed(2)},${category.transactionCount},${category.percentage.toStringAsFixed(1)}%'
        );
      }
      csvContent.writeln('');
      
      // Daily Totals
      csvContent.writeln('Daily Totals');
      csvContent.writeln('Date,Income,Expense,Balance');
      for (final daily in report.dailyTotals) {
        csvContent.writeln(
          '${_formatDate(daily.date)},${daily.income.toStringAsFixed(2)},${daily.expense.toStringAsFixed(2)},${daily.balance.toStringAsFixed(2)}'
        );
      }
      
      await file.writeAsString(csvContent.toString());
      return Success(file.path);
    } catch (e) {
      return Failure('Failed to export report: ${e.toString()}');
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}