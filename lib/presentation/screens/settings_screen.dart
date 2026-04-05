import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskly/data/services/auth_service.dart';

import '../../app/theme/app_colors.dart';
import '../../app/di/injection.dart';
import '../../domain/repositories/task_repository.dart';
import '../blocs/settings_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state.message != null && state.message!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: Colors.green,
                duration: const Duration(milliseconds: 800),
              ),
            );
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Preferences', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: state.isDarkMode,
                onChanged: (val) => context.read<SettingsBloc>().add(ToggleTheme()),
                secondary: Icon(state.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              ),
              const Divider(),
              

              const SizedBox(height: 24),
              Text('Cloud & Data', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(Icons.cloud_sync, color: AppColors.primary),
                title: const Text('Sync with Cloud'),
                subtitle: const Text('Upload local tasks to Firestore'),
                trailing: state.isSyncingCloud
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.chevron_right),
                onTap: state.isSyncingCloud ? null : () => context.read<SettingsBloc>().add(SyncData()),
              ),
              
              ListTile(
                leading: const Icon(Icons.download, color: AppColors.secondary),
                title: const Text('Import Sample Tasks'),
                subtitle: const Text('Fetch from jsonplaceholder API'),
                trailing: state.isImportingData 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.chevron_right),
                onTap: state.isImportingData ? null : () => context.read<SettingsBloc>().add(ImportData()),
              ),
              const SizedBox(height: 24),
              Text(
                'Account',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout'),
                subtitle: const Text('Sign out from your account'),
                onTap: () => logout(),
              ),
            ],
          );
        },
      ),
    );
  }

  void logout() async {
    // Clear local data before logging out so new user starts with empty/own DB
    await getIt<TaskRepository>().clearLocalData();
    
    final auth = AuthService();
    await auth.signOut();
  }
}
