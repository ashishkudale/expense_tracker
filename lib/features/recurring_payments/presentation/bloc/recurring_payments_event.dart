import 'package:equatable/equatable.dart';
import '../../domain/entities/recurring_payment.dart';

abstract class RecurringPaymentsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RecurringPaymentsLoadRequested extends RecurringPaymentsEvent {}

class RecurringPaymentAddRequested extends RecurringPaymentsEvent {
  final RecurringPayment payment;

  RecurringPaymentAddRequested(this.payment);

  @override
  List<Object?> get props => [payment];
}

class RecurringPaymentDeleteRequested extends RecurringPaymentsEvent {
  final String id;

  RecurringPaymentDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class RecurringPaymentToggleStatusRequested extends RecurringPaymentsEvent {
  final String id;
  final bool isActive;

  RecurringPaymentToggleStatusRequested(this.id, this.isActive);

  @override
  List<Object?> get props => [id, isActive];
}

class RecurringPaymentsProcessDueRequested extends RecurringPaymentsEvent {}
