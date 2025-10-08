import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/currencies.dart';
import '../../onboarding/domain/repositories/user_profile_repository.dart';
import '../../transactions/domain/usecases/get_period_totals.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetPeriodTotals _getPeriodTotals;
  final UserProfileRepository _userProfileRepository;

  DashboardBloc({
    required GetPeriodTotals getPeriodTotals,
    required UserProfileRepository userProfileRepository,
  })  : _getPeriodTotals = getPeriodTotals,
        _userProfileRepository = userProfileRepository,
        super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onDashboardLoadRequested);
    on<DashboardRefreshRequested>(_onDashboardRefreshRequested);
  }

  Future<void> _onDashboardLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    await _loadDashboardData(emit);
  }

  Future<void> _onDashboardRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadDashboardData(emit);
  }

  Future<void> _loadDashboardData(Emitter<DashboardState> emit) async {
    try {
      final now = DateTime.now();
      
      // Get current month start and end
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
      
      // Get today start and end
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Get monthly totals
      final monthlyResult = await _getPeriodTotals(
        GetPeriodTotalsParams(
          startDate: monthStart,
          endDate: monthEnd,
        ),
      );

      // Get today's totals
      final todayResult = await _getPeriodTotals(
        GetPeriodTotalsParams(
          startDate: todayStart,
          endDate: todayEnd,
        ),
      );

      // Get currency symbol
      String currencySymbol = '\$';
      try {
        final profileResult = await _userProfileRepository.getUserProfile();
        if (profileResult.isSuccess && profileResult.data != null) {
          final currency = Currencies.getByCode(profileResult.data!.currencyCode);
          currencySymbol = currency?.symbol ?? '\$';
        }
      } catch (e) {
        // Use default currency symbol if failed to get user profile
      }

      if (monthlyResult.isFailure || todayResult.isFailure) {
        emit(DashboardError(monthlyResult.error ?? todayResult.error ?? 'Failed to load dashboard data'));
        return;
      }

      final monthlyTotals = monthlyResult.data!;
      final todayTotals = todayResult.data!;

      emit(DashboardLoaded(
        monthlyIncome: monthlyTotals.totalIncome,
        monthlyExpense: monthlyTotals.totalExpense,
        todayIncome: todayTotals.totalIncome,
        todayExpense: todayTotals.totalExpense,
        currencySymbol: currencySymbol,
      ));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard: ${e.toString()}'));
    }
  }
}