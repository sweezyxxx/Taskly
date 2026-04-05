import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../blocs/task_detail_bloc.dart';
import '../../app/di/injection.dart';

class CreateTaskScreen extends StatefulWidget {
  final TaskEntity? taskToEdit;

  const CreateTaskScreen({super.key, this.taskToEdit});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _title = widget.taskToEdit!.title;
      _description = widget.taskToEdit!.description;
      _priority = widget.taskToEdit!.priority;
      _dueDate = widget.taskToEdit!.dueDate;
    }
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _dueDate = date);
    }
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final bool isEditing = widget.taskToEdit != null;
      final task = TaskEntity(
        id: isEditing ? widget.taskToEdit!.id : const Uuid().v4(),
        title: _title,
        description: _description,
        status: isEditing ? widget.taskToEdit!.status : TaskStatus.todo,
        priority: _priority,
        createdAt: isEditing ? widget.taskToEdit!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
        dueDate: _dueDate,
        isSynced: false,
      );

      context.read<TaskDetailBloc>().add(
        SaveTaskEvent(task, isEditing: isEditing),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TaskDetailBloc>(),
      child: BlocConsumer<TaskDetailBloc, TaskDetailState>(
        listener: (context, state) {
          if (state is TaskDetailSuccess) {
            context.pop();
          } else if (state is TaskDetailError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.taskToEdit != null ? 'Edit Task' : 'Create Task',
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    initialValue: _title,
                    decoration: const InputDecoration(labelText: 'Task Title'),
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Enter a title' : null,
                    onSaved: (v) => _title = v!.trim(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    onSaved: (v) => _description = v ?? '',
                  ),
                  const SizedBox(height: 24),

                  Text('Priority', style: GoogleFonts.outfit(fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: TaskPriority.values
                        .map(
                          (p) => ChoiceChip(
                            label: Text(p.name.toUpperCase()),
                            selected: _priority == p,
                            selectedColor: AppColors.primary.withValues(
                              alpha: 0.2,
                            ),
                            onSelected: (_) => setState(() => _priority = p),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  Text('Deadline', style: GoogleFonts.outfit(fontSize: 16)),
                  const SizedBox(height: 8),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    leading: const Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      _dueDate == null
                          ? 'Set a deadline'
                          : DateFormat('MMM d, yyyy').format(_dueDate!),
                    ),
                    trailing: _dueDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _dueDate = null),
                          )
                        : null,
                    onTap: _pickDueDate,
                  ),
                  const SizedBox(height: 48),

                  ElevatedButton(
                    onPressed: state is TaskDetailSaving
                        ? null
                        : () => _submit(context),
                    child: state is TaskDetailSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            widget.taskToEdit != null
                                ? 'Save Changes'
                                : 'Create Task',
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
