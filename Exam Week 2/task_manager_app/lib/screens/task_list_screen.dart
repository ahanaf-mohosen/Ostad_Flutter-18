import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/api_service.dart';
import '../widgets/task_card.dart';
import 'add_edit_task_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ApiService apiService = ApiService();

  List<Task> tasks = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await apiService.getTasks();

      if (!mounted) return;

      setState(() {
        tasks = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load tasks.';
      });
    }
  }

  Future<void> addTask() async {
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditTaskScreen(),
      ),
    );

    if (result == null) return;

    try {
      final created = await apiService.createTask(result);

      if (!mounted) return;

      setState(() {
        tasks.insert(0, created);
      });

      showMessage('Task created successfully');
    } catch (e) {
      showMessage('Failed to create task');
    }
  }

  Future<void> editTask(Task task) async {
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTaskScreen(task: task),
      ),
    );

    if (result == null) return;

    try {
      final updated = await apiService.updateTask(result);

      if (!mounted) return;

      final index =
      tasks.indexWhere((item) => item.id == updated.id);

      if (index != -1) {
        setState(() {
          tasks[index] = updated;
        });
      }

      showMessage('Task updated successfully');
    } catch (e) {
      showMessage('Failed to update task');
    }
  }

  Future<void> deleteTask(Task task) async {
    if (task.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text(
            'Are you sure you want to delete this task?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await apiService.deleteTask(task.id!);

      if (!mounted) return;

      setState(() {
        tasks.removeWhere(
              (item) => item.id == task.id,
        );
      });

      showMessage('Task deleted successfully');
    } catch (e) {
      showMessage('Failed to delete task');
    }
  }

  void toggleTask(Task task) async {
    final updated = task.copyWith(
      completed: !task.completed,
    );

    try {
      await apiService.updateTask(updated);

      if (!mounted) return;

      setState(() {
        final index =
        tasks.indexWhere((item) => item.id == task.id);

        if (index != -1) {
          tasks[index] = updated;
        }
      });
    } catch (e) {
      showMessage('Failed to update task');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: RefreshIndicator(
        onRefresh: loadTasks,
        child: buildBody(),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: addTask,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .7,
            child: Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    errorMessage!,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 15),

                  FilledButton.icon(
                    onPressed: loadTasks,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (tasks.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .7,
            child: const Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No tasks available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 100,
      ),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return TaskCard(
          task: task,

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskDetailScreen(
                  task: task,
                  onEdit: () {
                    Navigator.pop(context);
                    editTask(task);
                  },
                ),
              ),
            );
          },

          onDelete: () => deleteTask(task),

          onToggle: () => toggleTask(task),
        );
      },
    );
  }
}