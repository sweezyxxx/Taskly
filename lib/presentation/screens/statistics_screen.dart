import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/theme/app_colors.dart';
import '../blocs/stats_bloc.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: BlocBuilder<StatsBloc, StatsState>(
        builder: (context, state) {
          if (state is StatsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSummaryCards(state),
              const SizedBox(height: 32),
              Text('Task Distribution', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: state.totalTasks == 0 
                    ? const Center(child: Text('No data yet'))
                    : PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: Colors.grey.shade400,
                        value: state.todoTasks.toDouble(),
                        title: '${state.todoTasks}',
                        radius: 50,
                      ),
                      PieChartSectionData(
                        color: AppColors.success,
                        value: state.doneTasks.toDouble(),
                        title: '${state.doneTasks}',
                        radius: 60, // slightly larger for emphasis
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   _indicator(Colors.grey.shade400, 'To Do'),
                   const SizedBox(width: 16),
                   _indicator(AppColors.success, 'Done'),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget _indicator(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }

  Widget _buildSummaryCards(StatsState state) {
    return Column(
      children: [
        Row(
          children: [
             Expanded(child: _statCard('Total Tasks', '${state.totalTasks}', Icons.list)),
             const SizedBox(width: 16),
             Expanded(child: _statCard('Completion', '${state.completionRate.toStringAsFixed(1)}%', Icons.check_circle_outline)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
             Expanded(child: _statCard('Overdue', '${state.overdueTasks}', Icons.warning_amber, color: AppColors.error)),
             const SizedBox(width: 16),
             const Expanded(child: SizedBox()), // Placeholder
          ],
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, {Color? color}) {
    return Card(
      elevation: 0,
      color: (color ?? AppColors.primary).withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color ?? AppColors.primary),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: color ?? AppColors.primary)),
            Text(title, style: GoogleFonts.inter(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
