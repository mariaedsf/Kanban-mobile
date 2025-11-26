import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskService {
  static const String _tasksKey = 'kanban_tasks';
  
  Future<List<Task>> getTasks(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString(_tasksKey);
    
    if (tasksJson == null) {
      return [];
    }
    
    final List<dynamic> tasksList = json.decode(tasksJson);
    return tasksList
        .map((taskJson) => Task.fromJson(taskJson))
        .where((task) => task.userId == userId)
        .toList();
  }
  
  Future<Task> addTask(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString(_tasksKey);
    
    List<Task> tasks = [];
    if (tasksJson != null) {
      final List<dynamic> tasksList = json.decode(tasksJson);
      tasks = tasksList.map((taskJson) => Task.fromJson(taskJson)).toList();
    }
    
    tasks.add(task);
    await _saveTasks(tasks);
    
    return task;
  }
  
  Future<Task> updateTask(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString(_tasksKey);
    
    List<Task> tasks = [];
    if (tasksJson != null) {
      final List<dynamic> tasksList = json.decode(tasksJson);
      tasks = tasksList.map((taskJson) => Task.fromJson(taskJson)).toList();
    }
    
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await _saveTasks(tasks);
    }
    
    return task;
  }
  
  Future<bool> deleteTask(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString(_tasksKey);
    
    if (tasksJson == null) {
      return false;
    }
    
    List<Task> tasks = [];
    final List<dynamic> tasksList = json.decode(tasksJson);
    tasks = tasksList.map((taskJson) => Task.fromJson(taskJson)).toList();
    
    tasks.removeWhere((task) => task.id == taskId);
    await _saveTasks(tasks);
    
    return true;
  }
  
  Future<List<Task>> getTasksByStatus(String userId, TaskStatus status) async {
    final allTasks = await getTasks(userId);
    return allTasks.where((task) => task.status == status).toList();
  }
  
  Future<void> _saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = json.encode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString(_tasksKey, tasksJson);
  }
  
  Future<void> clearAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
  }
}