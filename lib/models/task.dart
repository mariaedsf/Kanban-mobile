enum TaskStatus {
  todo,
  inProgress,
  done,
}

extension TaskStatusExtension on TaskStatus {
  String get getStatusText {
    switch (this) {
      case TaskStatus.todo:
        return 'A Fazer';
      case TaskStatus.inProgress:
        return 'Fazendo';
      case TaskStatus.done:
        return 'Feito';
    }
  }
}

enum TaskPriority {
  low,
  medium,
  high,
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String userId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.dueDate,
    required this.userId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: TaskStatus.values.firstWhere(
        (status) => status.toString() == 'TaskStatus.${json['status']}',
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
        (priority) => priority.toString() == 'TaskPriority.${json['priority']}',
        orElse: () => TaskPriority.medium,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'userId': userId,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? dueDate,
    String? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      userId: userId ?? this.userId,
    );
  }

  String getPriorityColor() {
    switch (priority) {
      case TaskPriority.high:
        return '#FF4444';
      case TaskPriority.medium:
        return '#FFA500';
      case TaskPriority.low:
        return '#4CAF50';
    }
  }

  String getStatusText() {
    switch (status) {
      case TaskStatus.todo:
        return 'A Fazer';
      case TaskStatus.inProgress:
        return 'Fazendo';
      case TaskStatus.done:
        return 'Feito';
    }
  }

  String getPriorityText() {
    switch (priority) {
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.medium:
        return 'Média';
      case TaskPriority.low:
        return 'Baixa';
    }
  }
}