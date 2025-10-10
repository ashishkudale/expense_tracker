import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_recurring_payment.dart';
import '../../domain/usecases/delete_recurring_payment.dart';
import '../../domain/usecases/get_recurring_payments.dart';
import '../../domain/usecases/process_due_recurring_payments.dart';
import '../../domain/usecases/toggle_recurring_payment_status.dart';
import 'recurring_payments_event.dart';
import 'recurring_payments_state.dart';

class RecurringPaymentsBloc extends Bloc<RecurringPaymentsEvent, RecurringPaymentsState> {
  final GetRecurringPayments getRecurringPayments;
  final AddRecurringPayment addRecurringPayment;
  final DeleteRecurringPayment deleteRecurringPayment;
  final ToggleRecurringPaymentStatus toggleRecurringPaymentStatus;
  final ProcessDueRecurringPayments processDueRecurringPayments;

  RecurringPaymentsBloc({
    required this.getRecurringPayments,
    required this.addRecurringPayment,
    required this.deleteRecurringPayment,
    required this.toggleRecurringPaymentStatus,
    required this.processDueRecurringPayments,
  }) : super(RecurringPaymentsInitial()) {
    on<RecurringPaymentsLoadRequested>(_onLoadRequested);
    on<RecurringPaymentAddRequested>(_onAddRequested);
    on<RecurringPaymentDeleteRequested>(_onDeleteRequested);
    on<RecurringPaymentToggleStatusRequested>(_onToggleStatusRequested);
    on<RecurringPaymentsProcessDueRequested>(_onProcessDueRequested);
  }

  Future<void> _onLoadRequested(
    RecurringPaymentsLoadRequested event,
    Emitter<RecurringPaymentsState> emit,
  ) async {
    emit(RecurringPaymentsLoading());

    final result = await getRecurringPayments();

    if (result.isSuccess) {
      emit(RecurringPaymentsLoaded(result.data ?? []));
    } else {
      emit(RecurringPaymentsError(result.error ?? 'Failed to load recurring payments'));
    }
  }

  Future<void> _onAddRequested(
    RecurringPaymentAddRequested event,
    Emitter<RecurringPaymentsState> emit,
  ) async {
    final result = await addRecurringPayment(event.payment);

    if (result.isSuccess) {
      add(RecurringPaymentsLoadRequested());
    } else {
      emit(RecurringPaymentsError(result.error ?? 'Failed to add recurring payment'));
    }
  }

  Future<void> _onDeleteRequested(
    RecurringPaymentDeleteRequested event,
    Emitter<RecurringPaymentsState> emit,
  ) async {
    final result = await deleteRecurringPayment(event.id);

    if (result.isSuccess) {
      add(RecurringPaymentsLoadRequested());
    } else {
      emit(RecurringPaymentsError(result.error ?? 'Failed to delete recurring payment'));
    }
  }

  Future<void> _onToggleStatusRequested(
    RecurringPaymentToggleStatusRequested event,
    Emitter<RecurringPaymentsState> emit,
  ) async {
    final result = await toggleRecurringPaymentStatus(event.id, event.isActive);

    if (result.isSuccess) {
      add(RecurringPaymentsLoadRequested());
    } else {
      emit(RecurringPaymentsError(result.error ?? 'Failed to toggle status'));
    }
  }

  Future<void> _onProcessDueRequested(
    RecurringPaymentsProcessDueRequested event,
    Emitter<RecurringPaymentsState> emit,
  ) async {
    final currentState = state;
    if (currentState is RecurringPaymentsLoaded) {
      emit(RecurringPaymentsProcessing(currentState.payments));
    }

    final result = await processDueRecurringPayments();

    if (result.isSuccess) {
      final paymentsResult = await getRecurringPayments();
      if (paymentsResult.isSuccess) {
        emit(RecurringPaymentsProcessed(
          paymentsResult.data ?? [],
          result.data ?? 0,
        ));
      }
    } else {
      emit(RecurringPaymentsError(result.error ?? 'Failed to process recurring payments'));
    }
  }
}
