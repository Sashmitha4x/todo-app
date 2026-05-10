import 'package:flutter/material.dart';
import '../../core/theme/text_style.dart';
import '../../domain/entities/task_entity.dart';
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          CustomCheckbox(
            value: task.isCompleted,
            onChanged: (_) => onToggle(),
          ),
          const SizedBox(width: 50),
          Expanded(
            child: Text(
              task.title,
              style: AppTextStyles.header.copyWith(
                fontSize: 22,
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
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