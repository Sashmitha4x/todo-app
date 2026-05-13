import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      await context.read<TaskProvider>().addTask(
        _taskController.text,
        imageBytes: _selectedImageBytes,
      );
      _taskController.clear();
      setState(() => _selectedImageBytes = null);
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Task cannot be empty',
            style: TextStyle(fontFamily: 'Gaegu', fontSize: 18),
          ),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLarge,
            vertical: 10,
          ),
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
              const SizedBox(height: 40),

              // UPGRADED INPUT AREA: Soft floating card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _taskController,
                            style: AppTextStyles.bodyText,
                            decoration: InputDecoration(
                              hintText: 'add new task...',
                              hintStyle: AppTextStyles.header.copyWith(
                                fontSize: 24,
                                color: Colors.grey.shade400,
                              ),
                              border:
                                  InputBorder.none, // Removed harsh underline
                              isDense: true,
                            ),
                            onSubmitted: (_) => _submitTask(),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.image_outlined,
                              color: Colors.grey,
                              size: 26,
                            ),
                            onPressed: _pickImage,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: SvgPicture.asset(
                              'assets/icons/add.svg',
                              width: 20,
                              height: 20,
                            ),
                            onPressed: _submitTask,
                          ),
                        ),
                      ],
                    ),

                    // Image Preview
                    if (_selectedImageBytes != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                _selectedImageBytes!,
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: -8,
                              top: -8,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedImageBytes = null),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.cancel,
                                    color: AppColors.primaryRed,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              Center(
                child: Text(
                  'task list',
                  style: AppTextStyles.header.copyWith(
                    fontSize: 26,
                    color: AppColors.primaryRed,
                  ),
                ),
              ),
              const SizedBox(height: 16),

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

                    // UPGRADED EMPTY STATE
                    if (provider.tasks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.task_alt,
                              size: 60,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "All caught up!",
                              style: AppTextStyles.header.copyWith(
                                color: Colors.grey.shade400,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: provider.tasks.length,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 20, top: 8),
                      itemBuilder: (context, index) {
                        final task = provider.tasks[index];
                        return TaskItem(
                              task: task,
                              onToggle: () => provider.toggleTaskStatus(
                                task.taskId,
                                task.isCompleted,
                              ),
                              onDelete: () => provider.deleteTask(task.taskId),
                            )
                            // THIS IS THE NEW ANIMATION MAGIC
                            .animate()
                            .fade(duration: 300.ms)
                            .slideY(
                              begin: 0.2,
                              end: 0,
                              duration: 300.ms,
                              curve: Curves.easeOutQuad,
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
