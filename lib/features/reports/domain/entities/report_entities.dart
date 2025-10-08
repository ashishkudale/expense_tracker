import 'package:equatable/equatable.dart';
import '../../../transactions/domain/entities/transaction.dart';

enum ReportPeriod { week, month, year, custom }

class PeriodReport extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int transactionCount;
  final List<CategoryBreakdown> categoryBreakdowns;
  final List<DailyTotal> dailyTotals;

  const PeriodReport({
    required this.startDate,
    required this.endDate,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
    required this.categoryBreakdowns,
    required this.dailyTotals,
  });

  double get savingsRate => totalIncome > 0 
      ? ((totalIncome - totalExpense) / totalIncome * 100) 
      : 0;

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        totalIncome,
        totalExpense,
        balance,
        transactionCount,
        categoryBreakdowns,
        dailyTotals,
      ];
}

class CategoryBreakdown extends Equatable {
  final String categoryId;
  final String categoryName;
  final TransactionType type;
  final double amount;
  final int transactionCount;
  final double percentage;

  const CategoryBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.type,
    required this.amount,
    required this.transactionCount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [
        categoryId,
        categoryName,
        type,
        amount,
        transactionCount,
        percentage,
      ];
}

class DailyTotal extends Equatable {
  final DateTime date;
  final double income;
  final double expense;
  final double balance;

  const DailyTotal({
    required this.date,
    required this.income,
    required this.expense,
    required this.balance,
  });

  @override
  List<Object?> get props => [date, income, expense, balance];
}

class MonthlyTrend extends Equatable {
  final String month;
  final int year;
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const MonthlyTrend({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  @override
  List<Object?> get props => [
        month,
        year,
        totalIncome,
        totalExpense,
        balance,
      ];
}