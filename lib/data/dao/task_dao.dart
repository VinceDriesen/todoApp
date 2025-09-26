import '../database/app_database.dart';
import '../models/task.dart';

class TaskDao {
  Future<int> insertTask(Task task) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasksByList(int listId) async {
    final db = await AppDatabase.instance.database;
    final result = await db.query(
      'tasks',
      where: 'listId = ?',
      whereArgs: [listId],
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await AppDatabase.instance.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await AppDatabase.instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
