class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final bool isDone;
  final int listId; // foreign key

  Task({
    this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.isDone = false,
    required this.listId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone ? 1 : 0, // SQLite heeft geen bool
      'listId': listId,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isDone: map['isDone'] == 1,
      listId: map['listId'],
      description: map['description'] ?? '',
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
    );
  }
}
