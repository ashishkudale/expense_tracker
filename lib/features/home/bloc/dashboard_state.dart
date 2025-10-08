import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  const DashboardLoaded({
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.todayIncome,
    required this.todayExpense,
    required this.currencySymbol,
  });

  final double monthlyIncome;
  final double monthlyExpense;
  final double todayIncome;
  final double todayExpense;
  final String currencySymbol;

  @override
  List<Object?> get props => [
    monthlyIncome,
    monthlyExpense,
    todayIncome,
    todayExpense,
    currencySymbol,
  ];
}

class DashboardError extends DashboardState {
  const DashboardError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}