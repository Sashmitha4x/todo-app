import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_style.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';
import 'custom_checkbox.dart';

class TaskItem extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  }) : super(key: key);

  void _showEditDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: task.title,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text('Edit task', style: AppTextStyles.subHeaderRed),
        content: TextField(
          controller: controller,
          style: AppTextStyles.bodyText,
          decoration: const InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color.fromARGB(255, 94, 93, 93),
                fontFamily: 'Gaegu',
                fontSize: 18,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty &&
                  controller.text.trim() != task.title) {
                context.read<TaskProvider>().updateTaskTitle(
                  task.taskId,
                  controller.text.trim(),
                );
              }
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontFamily: 'Gaegu',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          CustomCheckbox(value: task.isCompleted, onChanged: (_) => onToggle()),
          const SizedBox(width: 50),
          Expanded(
            child: Text(
              task.title,
              style: AppTextStyles.header.copyWith(
                fontSize: 22,
                // 1. Dim the text color when completed
                color: task.isCompleted ? Colors.grey.shade500 : AppColors.textPrimary,
                
                // 2. Apply the strikethrough
                decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                
                // 3. Ensure the line itself matches the dim text color
                decorationColor: task.isCompleted ? Colors.grey.shade500 : Colors.transparent,
                
                // 4. Slightly thicken the line so it cuts through the font cleanly
                decorationThickness: 1.0,
              ),
            ),
          ),
          // Only show edit button if task is NOT completed
          if (!task.isCompleted)
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.primaryGreen,
              ),
              onPressed: () => _showEditDialog(context),
            ),
          // Show delete button if task IS completed
          if (task.isCompleted)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
