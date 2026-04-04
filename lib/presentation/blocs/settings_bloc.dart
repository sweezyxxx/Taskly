import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../../../domain/usecases/task_usecases.dart';

// --- Events ---
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class ToggleTheme extends SettingsEvent {}

class UpdateUsername extends SettingsEvent {
  final String username;
  const UpdateUsername(this.username);
  @override List<Object?> get props => [username];
}

class SyncData extends SettingsEvent {}

class ImportData extends SettingsEvent {}

// --- States ---
class SettingsState extends Equatable {
  final bool isDarkMode;
  final String username;
  final bool isSyncingCloud;
  final bool isImportingData;
  final String? message;

  const SettingsState({
    required this.isDarkMode,
    required this.username,
    this.isSyncingCloud = false,
    this.isImportingData = false,
    this.message,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    String? username,
    bool? isSyncingCloud,
    bool? isImportingData,
    String? message,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      username: username ?? this.username,
      isSyncingCloud: isSyncingCloud ?? this.isSyncingCloud,
      isImportingData: isImportingData ?? this.isImportingData,
      message: message, // Allow null override
    );
  }

  @override List<Object?> get props => [isDarkMode, username, isSyncingCloud, isImportingData, message];
}

// --- BLoC ---
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepo;
  final SyncTasksUseCase syncUseCase;
  final ImportTasksUseCase importUseCase;

  SettingsBloc({
    required this.settingsRepo,
    required this.syncUseCase,
    required this.importUseCase,
  }) : super(const SettingsState(isDarkMode: false, username: 'User')) {
    on<LoadSettings>(_onLoad);
    on<ToggleTheme>(_onToggleTheme);
    on<UpdateUsername>(_onUpdateUsername);
    on<SyncData>(_onSyncData);
    on<ImportData>(_onImportData);
  }

  Future<void> _onLoad(LoadSettings event, Emitter<SettingsState> emit) async {
    final isDark = await settingsRepo.isDarkMode();
    final name = await settingsRepo.getUsername();
    emit(state.copyWith(isDarkMode: isDark, username: name));
  }

  Future<void> _onToggleTheme(ToggleTheme event, Emitter<SettingsState> emit) async {
    final newMode = !state.isDarkMode;
    await settingsRepo.setDarkMode(newMode);
    emit(state.copyWith(isDarkMode: newMode));
  }

  Future<void> _onUpdateUsername(UpdateUsername event, Emitter<SettingsState> emit) async {
    await settingsRepo.setUsername(event.username);
    emit(state.copyWith(username: event.username));
  }

  Future<void> _onSyncData(SyncData event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(isSyncingCloud: true, message: null));
    try {
      await syncUseCase();
      emit(state.copyWith(isSyncingCloud: false, message: 'Sync complete!'));
    } catch (e) {
      emit(state.copyWith(isSyncingCloud: false, message: 'Sync failed: $e'));
    }
  }

    Future<void> _onImportData(ImportData event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(isImportingData: true, message: null));
    try {
      await importUseCase();
      emit(state.copyWith(isImportingData: false, message: 'Imported sample tasks!'));
    } catch (e) {
      emit(state.copyWith(isImportingData: false, message: 'Import failed: $e'));
    }
  }
}
