import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  TaskService() : _tasks = FirebaseFirestore.instance.collection('tasks');

  final CollectionReference<Map<String, dynamic>> _tasks;

  Future<List<Task>> getTasks(String userId) async {
    final snapshot = await _tasks.where('userId', isEqualTo: userId).get();
    return snapshot.docs.map(Task.fromFirestore).toList();
  }

  Future<Task> addTask(Task task) async {
    final docRef = task.id.isNotEmpty ? _tasks.doc(task.id) : _tasks.doc();
    final newTask = task.copyWith(id: docRef.id, createdAt: DateTime.now());
    await docRef.set(newTask.toFirestore());
    return newTask;
  }

  Future<Task> updateTask(Task task) async {
    await _tasks.doc(task.id).set(task.toFirestore(), SetOptions(merge: true));
    return task;
  }

  Future<bool> deleteTask(String taskId) async {
    await _tasks.doc(taskId).delete();
    return true;
  }

  Future<List<Task>> getTasksByStatus(String userId, TaskStatus status) async {
    final snapshot = await _tasks
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: _statusToString(status))
        .get();
    return snapshot.docs.map(Task.fromFirestore).toList();
  }

  Future<void> clearAllTasks(String userId) async {
    final snapshot = await _tasks.where('userId', isEqualTo: userId).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  String _statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'todo';
      case TaskStatus.inProgress:
        return 'inProgress';
      case TaskStatus.done:
        return 'done';
    }
  }
}
