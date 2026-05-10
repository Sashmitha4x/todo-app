import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/text_style.dart';
import '../providers/task_provider.dart';
import '../widgets/task_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _taskController = TextEditingController();

  void _submitTask() {
    if (_taskController.text.trim().isNotEmpty) {
      context.read<TaskProvider>().addTask(_taskController.text);
      _taskController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Task cannot be empty')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'My silly little tasks',
                  style: AppTextStyles.header,
                ),
              ),
              const SizedBox(height: 80),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _taskController,
                      style: AppTextStyles.bodyText,
                      decoration: InputDecoration(
                        hintText: 'add new task',
                        hintStyle: AppTextStyles.header.copyWith(fontSize: 26),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primaryGreen,
                            width: 3.5,
                          ),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 50, 184, 83),
                            width: 4,
                          ),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.only(bottom: 12),
                      ),
                      onSubmitted: (_) => _submitTask(),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/add.svg',
                      width: 20,
                      height: 20,
                    ),
                    onPressed: _submitTask,
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Center(
                child: Text(
                  'task list',
                  style: AppTextStyles.header.copyWith(fontSize: 26, color: AppColors.primaryRed),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer<TaskProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.tasks.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGreen,
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: provider.tasks.length,
                      itemBuilder: (context, index) {
                        final task = provider.tasks[index];
                        return TaskItem(
                          task: task,
                          onToggle: () => provider.toggleTaskStatus(
                            task.taskId,
                            task.isCompleted,
                          ),
                          onDelete: () => provider.deleteTask(task.taskId),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
