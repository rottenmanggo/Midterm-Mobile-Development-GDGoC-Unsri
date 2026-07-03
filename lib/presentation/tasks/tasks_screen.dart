import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../data/models/task_model.dart';
import '../auth/auth_provider.dart';
import 'tasks_provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _addTask(String userId) async {
    final title = _taskController.text.trim();
    if (title.isEmpty) return;

    final error = await context.read<TasksProvider>().createTask(
          userId: userId,
          title: title,
        );

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
    } else {
      _taskController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tasks = context.watch<TasksProvider>();
    final user = auth.user;

    if (user == null) return const SizedBox.shrink();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Tasks',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Stay organized 📋',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          // Add task input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _addTask(user.uid),
                    decoration: InputDecoration(
                      hintText: 'Add a new task...',
                      prefixIcon: const Icon(Icons.add_task_rounded,
                          size: 20, color: AppColors.textMuted),
                      suffixIcon: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _taskController,
                        builder: (_, value, __) {
                          return value.text.trim().isEmpty
                              ? const SizedBox.shrink()
                              : IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  color: AppColors.textMuted,
                                  onPressed: () => _taskController.clear(),
                                );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      tasks.isLoading ? null : () => _addTask(user.uid),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    minimumSize: const Size(52, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: tasks.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Tasks list
          Expanded(
            child: StreamBuilder<List<TaskModel>>(
              stream: context.read<TasksProvider>().tasksStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Error loading tasks',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        ShimmerLine(height: 60),
                        SizedBox(height: 10),
                        ShimmerLine(height: 60),
                        SizedBox(height: 10),
                        ShimmerLine(height: 60),
                      ],
                    ),
                  );
                }

                final taskList = snapshot.data ?? [];
                if (taskList.isEmpty) {
                  return _EmptyTasksState();
                }

                final pending = taskList.where((t) => !t.isCompleted).toList();
                final done = taskList.where((t) => t.isCompleted).toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  children: [
                    if (pending.isNotEmpty) ...[
                      _sectionHeader('To Do (${pending.length})'),
                      ...pending.map((task) => _TaskTile(task: task)),
                    ],
                    if (done.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _sectionHeader('Completed (${done.length})'),
                      ...done.map((task) => _TaskTile(task: task)),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final TaskModel task;

  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.redAccent, size: 24),
      ),
      onDismissed: (_) async {
        final error = await context.read<TasksProvider>().deleteTask(task.id);
        if (error != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? AppColors.cardGreen.withValues(alpha: 0.4)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: task.isCompleted
                ? AppColors.fabGreen
                : AppColors.divider,
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: GestureDetector(
            onTap: () => context
                .read<TasksProvider>()
                .toggleTask(task.id, !task.isCompleted),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? AppColors.cardGreen
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted
                      ? AppColors.textGreen
                      : AppColors.divider,
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: AppColors.textGreen)
                  : null,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              color: task.isCompleted
                  ? AppColors.textGreen.withValues(alpha: 0.6)
                  : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              decoration:
                  task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.close_rounded,
                size: 16,
                color: task.isCompleted
                    ? AppColors.textGreen.withValues(alpha: 0.4)
                    : AppColors.textMuted),
            onPressed: () =>
                context.read<TasksProvider>().deleteTask(task.id),
          ),
        ),
      ),
    );
  }
}

class _EmptyTasksState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: AppColors.cardGreen,
                shape: BoxShape.circle,
              ),
              child: const Center(
                  child: Text('✅', style: TextStyle(fontSize: 40))),
            ),
            const SizedBox(height: 24),
            const Text(
              'All clear!',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'No tasks yet. Add something\nto get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
