import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
    final ImagePicker picker = ImagePicker();

    // Temporary state variables for the dialog
    Uint8List? tempNewImageBytes;
    bool tempRemoveImage = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> pickNewImage() async {
            final XFile? image = await picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 70,
            );
            if (image != null) {
              final bytes = await image.readAsBytes();
              setDialogState(() {
                tempNewImageBytes = bytes;
                tempRemoveImage =
                    false; // Reset remove flag if they pick a new image
              });
            }
          }

          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit task',
                      style: AppTextStyles.header.copyWith(
                        fontSize: 26,
                        color: AppColors.primaryRed,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Upgraded Text Field (Soft background, no harsh borders)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: controller,
                        style: AppTextStyles.bodyText,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        autofocus: true,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Image Preview
                    if (tempNewImageBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          tempNewImageBytes!,
                          height: 120,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        ),
                      )
                    else if (task.imageUrl != null && !tempRemoveImage)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          task.imageUrl!,
                          height: 120,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Image Action Buttons
                    Row(
                      children: [
                        TextButton.icon(
                          icon: const Icon(
                            Icons.image_outlined,
                            color: AppColors.primaryGreen,
                            size: 20,
                          ),
                          label: Text(
                            task.imageUrl == null && tempNewImageBytes == null
                                ? 'Add Image'
                                : 'Change Image',
                            style: const TextStyle(
                              color: AppColors.primaryGreen,
                              fontFamily: 'Gaegu',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: pickNewImage,
                        ),
                        const Spacer(),
                        if ((task.imageUrl != null && !tempRemoveImage) ||
                            tempNewImageBytes != null)
                          TextButton.icon(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            label: const Text(
                              'Remove',
                              style: TextStyle(
                                color: Colors.red,
                                fontFamily: 'Gaegu',
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () {
                              setDialogState(() {
                                tempNewImageBytes = null;
                                tempRemoveImage = true;
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Save and Cancel Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Gaegu',
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (controller.text.trim().isNotEmpty) {
                              context.read<TaskProvider>().editTask(
                                task.taskId,
                                controller.text.trim(),
                                newImageBytes: tempNewImageBytes,
                                removeImage: tempRemoveImage,
                              );
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Gaegu',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0), // Space between cards
      padding: const EdgeInsets.all(16.0), // Inner padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: CustomCheckbox(
              value: task.isCompleted,
              onChanged: (_) => onToggle(),
            ),
          ),
          const SizedBox(width: 16), // Adjusted width for better proportion
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTextStyles.header.copyWith(
                    fontSize: 22,
                    color: task.isCompleted
                        ? Colors.grey.shade400
                        : AppColors.textPrimary,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: task.isCompleted
                        ? Colors.grey.shade400
                        : Colors.transparent,
                    decorationThickness: 1.5,
                  ),
                ),
                if (task.imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        task.imageUrl!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Action Buttons
          if (!task.isCompleted)
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.primaryGreen,
                  size: 22,
                ),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                onPressed: () => _showEditDialog(
                  context,
                ), // Ensure your dialog code is pasted above
              ),
            ),
          if (task.isCompleted)
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 22,
                ),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                onPressed: onDelete,
              ),
            ),
        ],
      ),
    );
  }
}
