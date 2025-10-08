import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/di/di.dart';
import 'core/theme/theme.dart';
import 'core/theme/theme_cubit.dart';
import 'routes/app_router.dart';

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    final GoRouter router = AppRouter.router();

    return BlocProvider(
      create: (_) => getIt<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, AppThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Expense Tracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: context.read<ThemeCubit>().themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}