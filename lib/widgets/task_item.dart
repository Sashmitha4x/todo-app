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

          return AlertDialog(
            backgroundColor: AppColors.background,
            title: const Text('Edit task', style: AppTextStyles.subHeaderRed),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    style: AppTextStyles.bodyText,
                    decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primaryGreen,
                          width: 2,
                        ),
                      ),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),

                  // Show the image preview (either the newly picked one, or the existing one)
                  if (tempNewImageBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        tempNewImageBytes!,
                        height: 100,
                        width: MediaQuery.of(
                          context,
                        ).size.width, // Fix applied here
                        fit: BoxFit.cover,
                      ),
                    )
                  else if (task.imageUrl != null && !tempRemoveImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        task.imageUrl!,
                        height: 100,
                        width: MediaQuery.of(
                          context,
                        ).size.width, // Fix applied here
                        fit: BoxFit.cover,
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Image action buttons
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
                          ),
                        ),
                        onPressed: pickNewImage,
                      ),
                      const Spacer(),
                      // Only show remove button if there is an image to remove
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
                ],
              ),
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
                  if (controller.text.trim().isNotEmpty) {
                    // Replaced updateTaskTitle with the new editTask method
                    context.read<TaskProvider>().editTask(
                      task.taskId,
                      controller.text.trim(),
                      newImageBytes: tempNewImageBytes,
                      removeImage: tempRemoveImage,
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
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment
            .start, // Aligns checkbox to the top if there is an image
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 4.0,
            ), // Keeps checkbox centered with the first line of text
            child: CustomCheckbox(
              value: task.isCompleted,
              onChanged: (_) => onToggle(),
            ),
          ),
          const SizedBox(width: 50),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTextStyles.header.copyWith(
                    fontSize: 22,
                    // 1. Dim the text color when completed
                    color: task.isCompleted
                        ? Colors.grey.shade500
                        : AppColors.textPrimary,

                    // 2. Apply the strikethrough
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,

                    // 3. Ensure the line itself matches the dim text color
                    decorationColor: task.isCompleted
                        ? Colors.grey.shade500
                        : Colors.transparent,

                    // 4. Slightly thicken the line so it cuts through the font cleanly
                    decorationThickness: 1.0,
                  ),
                ),
                // Show the uploaded image if the task has one
                if (task.imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        task.imageUrl!,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 140,
                          width: double.infinity,
                          color: Colors.grey.shade200,
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
