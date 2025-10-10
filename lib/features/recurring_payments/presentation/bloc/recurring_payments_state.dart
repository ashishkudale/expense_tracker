import 'package:equatable/equatable.dart';
import '../../domain/entities/recurring_payment.dart';

abstract class RecurringPaymentsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RecurringPaymentsInitial extends RecurringPaymentsState {}

class RecurringPaymentsLoading extends RecurringPaymentsState {}

class RecurringPaymentsLoaded extends RecurringPaymentsState {
  final List<RecurringPayment> payments;

  RecurringPaymentsLoaded(this.payments);

  @override
  List<Object?> get props => [payments];
}

class RecurringPaymentsError extends RecurringPaymentsState {
  final String message;

  RecurringPaymentsError(this.message);

  @override
  List<Object?> get props => [message];
}

class RecurringPaymentsProcessing extends RecurringPaymentsState {
  final List<RecurringPayment> payments;

  RecurringPaymentsProcessing(this.payments);

  @override
  List<Object?> get props => [payments];
}

class RecurringPaymentsProcessed extends RecurringPaymentsState {
  final List<RecurringPayment> payments;
  final int processedCount;

  RecurringPaymentsProcessed(this.payments, this.processedCount);

  @override
  List<Object?> get props => [payments, processedCount];
}
