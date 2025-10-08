import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/onboarding/data/repositories/user_profile_repository_impl.dart';
import '../../features/onboarding/domain/repositories/user_profile_repository.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/reports/data/repositories/report_repository_impl.dart';
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/reports/domain/usecases/export_report.dart';
import '../../features/reports/domain/usecases/get_monthly_trends.dart';
import '../../features/reports/domain/usecases/get_period_report.dart';
import '../../features/reports/presentation/bloc/reports_bloc.dart';
import '../../features/transactions/domain/usecases/get_period_totals.dart';
import '../../features/home/bloc/dashboard_bloc.dart';
import '../db/database_provider.dart';
import '../theme/theme_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDI() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  final databaseProvider = DatabaseProvider();
  await databaseProvider.init();
  getIt.registerSingleton<DatabaseProvider>(databaseProvider);
  
  getIt.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(getIt<SharedPreferences>()),
  );
  
  getIt.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(getIt<DatabaseProvider>()),
  );
  
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(getIt<DatabaseProvider>()),
  );
  
  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(getIt<DatabaseProvider>()),
  );
  
  getIt.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(getIt<DatabaseProvider>()),
  );
  
  // Report use cases
  getIt.registerLazySingleton<GetPeriodReport>(
    () => GetPeriodReport(getIt<ReportRepository>()),
  );
  
  getIt.registerLazySingleton<GetMonthlyTrends>(
    () => GetMonthlyTrends(getIt<ReportRepository>()),
  );
  
  getIt.registerLazySingleton<ExportReport>(
    () => ExportReport(getIt<ReportRepository>()),
  );
  
  // Transaction use cases
  getIt.registerLazySingleton<GetPeriodTotals>(
    () => GetPeriodTotals(getIt<TransactionRepository>()),
  );
  
  // Reports Bloc
  getIt.registerFactory<ReportsBloc>(
    () => ReportsBloc(
      getPeriodReport: getIt<GetPeriodReport>(),
      getMonthlyTrends: getIt<GetMonthlyTrends>(),
      exportReport: getIt<ExportReport>(),
    ),
  );
  
  // Dashboard Bloc
  getIt.registerFactory<DashboardBloc>(
    () => DashboardBloc(
      getPeriodTotals: getIt<GetPeriodTotals>(),
      userProfileRepository: getIt<UserProfileRepository>(),
    ),
  );
}