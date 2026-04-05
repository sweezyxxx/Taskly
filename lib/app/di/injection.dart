import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/database/app_database.dart';
import '../../data/datasources/local/prefs_local_ds.dart';
import '../../data/datasources/local/task_local_ds.dart';
import '../../data/datasources/remote/api_remote_ds.dart';
import '../../data/datasources/remote/task_remote_ds.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/task_usecases.dart';
import '../../presentation/blocs/settings_bloc.dart';
import '../../presentation/blocs/stats_bloc.dart';
import '../../presentation/blocs/task_detail_bloc.dart';
import '../../presentation/blocs/task_list_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Wait for SharedPreferences to instantiate before treating it as a synchronous dependency
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Singletons: instantiated once and reused throughout the app lifecycle
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton(() => Dio());
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton(() => AppDatabase());

  getIt.registerLazySingleton<PrefsLocalDataSource>(
    () => PrefsLocalDataSourceImpl(prefs: getIt()),
  );
  getIt.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(db: getIt()),
  );
  getIt.registerLazySingleton<ApiRemoteDataSource>(
    () => ApiRemoteDataSourceImpl(dio: getIt()),
  );
  getIt.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(firestore: getIt()),
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(localDs: getIt()),
  );
  getIt.registerLazySingleton<TaskRepository>(
    () =>
        TaskRepositoryImpl(localDs: getIt(), remoteDs: getIt(), apiDs: getIt()),
  );

  getIt.registerLazySingleton(() => WatchTasksUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateTaskUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateTaskUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteTaskUseCase(getIt()));
  getIt.registerLazySingleton(() => SyncTasksUseCase(getIt()));
  getIt.registerLazySingleton(() => ImportTasksUseCase(getIt()));

  // BLoC Factories: A new instance is created every time a BLoC is requested.
  // This is crucial for UI state management to prevent retaining stale state
  // across different screen navigations.
  getIt.registerFactory(
    () => TaskListBloc(
      watchTasksUseCase: getIt(),
      updateTaskUseCase: getIt(),
      deleteTaskUseCase: getIt(),
    ),
  );
  getIt.registerFactory(
    () => TaskDetailBloc(createUseCase: getIt(), updateUseCase: getIt()),
  );
  getIt.registerFactory(
    () => SettingsBloc(
      settingsRepo: getIt(),
      syncUseCase: getIt(),
      importUseCase: getIt(),
    ),
  );
  getIt.registerFactory(() => StatsBloc(watchTasksUseCase: getIt()));
}
