import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/di.dart';
import '../../domain/entities/report_entities.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';
import '../widgets/category_breakdown_chart.dart';
import '../widgets/monthly_trends_chart.dart';
import '../widgets/period_selector.dart';
import '../widgets/report_summary_cards.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ReportsBloc>()
        ..add(const ReportsLoadRequested()),
      child: const _ReportsPageContent(),
    );
  }
}

class _ReportsPageContent extends StatelessWidget {
  const _ReportsPageContent();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.pie_chart), text: 'Overview'),
              Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
            ],
          ),
          actions: [
            BlocBuilder<ReportsBloc, ReportsState>(
              builder: (context, state) {
                if (state is ReportsLoaded) {
                  return IconButton(
                    icon: const Icon(Icons.file_download),
                    onPressed: () {
                      context.read<ReportsBloc>().add(
                        ReportExportRequested(state.periodReport),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<ReportsBloc, ReportsState>(
          listener: (context, state) {
            if (state is ReportExported) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Report exported to: ${state.filePath}'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is ReportsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ReportsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is ReportsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load reports',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ReportsBloc>().add(
                          const ReportsLoadRequested(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is ReportsLoaded) {
              return Column(
                children: [
                  PeriodSelector(
                    selectedPeriod: state.selectedPeriod,
                    onPeriodChanged: (period) {
                      context.read<ReportsBloc>().add(
                        ReportPeriodChanged(period),
                      );
                    },
                    onCustomDateRangeSelected: (startDate, endDate) {
                      context.read<ReportsBloc>().add(
                        CustomDateRangeSelected(
                          startDate: startDate,
                          endDate: endDate,
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _OverviewTab(report: state.periodReport),
                        _TrendsTab(
                          report: state.periodReport,
                          monthlyTrends: state.monthlyTrends,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const Center(
              child: Text('No data available'),
            );
          },
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final PeriodReport report;

  const _OverviewTab({required this.report});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReportSummaryCards(report: report),
          const SizedBox(height: 24),
          if (report.categoryBreakdowns.isNotEmpty) ...[
            Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            CategoryBreakdownChart(
              categoryBreakdowns: report.categoryBreakdowns,
            ),
            const SizedBox(height: 24),
          ],
          if (report.categoryBreakdowns.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.pie_chart_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions in this period',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some transactions to see your spending breakdown',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TrendsTab extends StatelessWidget {
  final PeriodReport report;
  final List<MonthlyTrend> monthlyTrends;

  const _TrendsTab({
    required this.report,
    required this.monthlyTrends,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Monthly Trends',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (monthlyTrends.isNotEmpty)
            MonthlyTrendsChart(monthlyTrends: monthlyTrends)
          else
            Container(
              height: 300,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No trend data available',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add transactions over multiple months to see trends',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}