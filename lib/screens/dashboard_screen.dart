import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImageBytes;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _selectedImageBytes = bytes);
    }
  }

  void _submitTask() async {
    if (_taskController.text.trim().isNotEmpty) {
      // Pass the image bytes to the provider
      await context.read<TaskProvider>().addTask(
            _taskController.text,
            imageBytes: _selectedImageBytes,
          );
      _taskController.clear();
      setState(() => _selectedImageBytes = null); // Clear image preview
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
              // Wrapped the Row in a Column to stack the image preview below it
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _taskController,
                          style: AppTextStyles.bodyText,
                          decoration: InputDecoration(
                            hintText: 'add new task',
                            hintStyle:
                                AppTextStyles.header.copyWith(fontSize: 26),
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
                      const SizedBox(width: AppSizes.paddingSmall),
                      IconButton(
                        icon: const Icon(
                          Icons.image_outlined,
                          color: Colors.grey,
                          size: 28,
                        ),
                        onPressed: _pickImage,
                      ),
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
                  // Image Preview before uploading
                  if (_selectedImageBytes != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              _selectedImageBytes!,
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: -10,
                            top: -10,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedImageBytes = null),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppColors.background,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.cancel,
                                  color: AppColors.primaryRed,
                                  size: 22,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 50),
              Center(
                child: Text(
                  'task list',
                  style: AppTextStyles.header.copyWith(
                    fontSize: 26,
                    color: AppColors.primaryRed,
                  ),
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
                      physics: const BouncingScrollPhysics(),
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