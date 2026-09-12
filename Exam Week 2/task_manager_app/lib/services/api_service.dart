import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  static const String baseUrl =
      'https://jsonplaceholder.typicode.com';

  Future<List<Task>> getTasks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/todos'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .take(20)
          .map((item) => Task(
        id: item['id'],
        title: item['title'] ?? '',
        description: 'Task from API',
        completed: item['completed'] ?? false,
      ))
          .toList();
    }

    throw Exception('Failed to load tasks');
  }

  Future<Task> createTask(Task task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/todos'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      return Task(
        id: data['id'],
        title: task.title,
        description: task.description,
        completed: task.completed,
      );
    }

    throw Exception('Failed to create task');
  }

  Future<Task> updateTask(Task task) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/todos/${task.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return task;
      }
    } catch (_) {
      if (task.id != null && task.id! > 200) {
        return task;
      }
    }

    if (task.id != null && task.id! > 200) {
      return task;
    }

    throw Exception('Failed to update task');
  }

  Future<void> deleteTask(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/todos/$id'),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }
    } catch (_) {
      if (id > 200) return;
    }

    if (id > 200) return;

    throw Exception('Failed to delete task');
  }
}