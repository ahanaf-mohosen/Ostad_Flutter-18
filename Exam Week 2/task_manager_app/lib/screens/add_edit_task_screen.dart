import 'package:flutter/material.dart';
import '../models/task.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({
    super.key,
    this.task,
  });

  @override
  State<AddEditTaskScreen> createState() =>
      _AddEditTaskScreenState();
}

class _AddEditTaskScreenState
    extends State<AddEditTaskScreen> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController descriptionController;

  bool completed = false;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.task?.title ?? '',
    );

    descriptionController =
        TextEditingController(
          text: widget.task?.description ?? '',
        );

    completed = widget.task?.completed ?? false;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void saveTask() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final task = Task(
      id: widget.task?.id,
      title: titleController.text.trim(),
      description:
      descriptionController.text.trim(),
      completed: completed,
    );

    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Task' : 'Add Task',
        ),
      ),

      body: Form(
        key: formKey,

        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                hintText: 'Enter task title',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),

              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please enter a task title';
                }

                if (value.trim().length < 3) {
                  return 'Title must be at least 3 characters';
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: descriptionController,
              maxLines: 5,

              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter task description',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),

              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please enter a description';
                }

                return null;
              },
            ),

            const SizedBox(height: 10),

            SwitchListTile(
              title: const Text(
                'Completed',
              ),
              subtitle: const Text(
                'Mark this task as completed',
              ),
              value: completed,
              onChanged: (value) {
                setState(() {
                  completed = value;
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: saveTask,
                icon: Icon(
                  isEditing
                      ? Icons.save
                      : Icons.add_task,
                ),
                label: Text(
                  isEditing
                      ? 'Update Task'
                      : 'Create Task',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}