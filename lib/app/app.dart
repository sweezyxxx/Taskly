import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/create_task_screen.dart';
import '../presentation/screens/error_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/settings_screen.dart';
import '../presentation/screens/statistics_screen.dart';
import '../presentation/screens/task_detail_screen.dart';
import 'theme/app_theme.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/entities/task_entity.dart';
import '../presentation/blocs/settings_bloc.dart';
import '../presentation/blocs/stats_bloc.dart';
import '../presentation/blocs/task_list_bloc.dart';
import 'di/injection.dart';

class TasklyApp extends StatelessWidget {
  const TasklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>(
          create: (_) => getIt<SettingsBloc>()..add(LoadSettings()),
        ),
        BlocProvider<TaskListBloc>(
          create: (_) => getIt<TaskListBloc>()..add(LoadTasks()),
        ),
        BlocProvider<StatsBloc>(
          create: (_) => getIt<StatsBloc>()..add(LoadStats()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Taskly',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}


final GoRouter _router = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => const ErrorScreen(),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/task/create',
      builder: (context, state) => const CreateTaskScreen(),
    ),
    GoRoute(
      path: '/task/:id/edit',
      builder: (context, state) {
        final task = state.extra as TaskEntity?;
        return CreateTaskScreen(taskToEdit: task);
      },
    ),
    GoRoute(
      path: '/task/:id',
      builder: (context, state) {
        final taskId = state.pathParameters['id']!;
        return TaskDetailScreen(taskId: taskId);
      },
    ),
    GoRoute(
      path: '/statistics',
      builder: (context, state) => const StatisticsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
