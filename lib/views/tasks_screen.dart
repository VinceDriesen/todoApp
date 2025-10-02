import 'package:flutter/material.dart';
import '../data/dao/todolist_dao.dart';
import '../data/models/todoList.dart';
import '../data/models/task.dart';
import '../data/dao/task_dao.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({Key? key, required this.todoListName}) : super(key: key);
  final String todoListName;

  @override
  Widget build(BuildContext context) {
    TodoListDao todoListDao = TodoListDao();
    TaskDao taskDao = TaskDao();

    return FutureBuilder<TodoList?>(
      future: todoListDao.getListByName(todoListName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('TakenAAA in $todoListName')),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('TakenNN in $todoListName')),
            body: Center(child: Text('Error loading list')),
          );
        } else {
          int listId = snapshot.data?.id ?? 0;
          return Scaffold(
            appBar: AppBar(title: Text('Takennn in $todoListName')),
            body: Column(
              children: [
                UncompletedTasks(taskDao: taskDao, listId: listId),
                const Divider(),
                CompletedTasks(taskDao: taskDao, listId: listId),
                const Divider(),
                NewTaskButton(dao: taskDao, listId: listId),
              ],
            ),
          );
        }
      },
    );
  }
}

class UncompletedTasks extends StatelessWidget {
  const UncompletedTasks({
    Key? key,
    required this.listId,
    required this.taskDao,
  }) : super(key: key);
  final TaskDao taskDao;
  final int listId;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
      future: taskDao.getTasksByList(listId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading tasks'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tasks found'));
        } else {
          final tasks = snapshot.data!;
          return Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return TaskOption(task: tasks[index]);
              },
            ),
          );
        }
      },
    );
  }
}

class CompletedTasks extends StatelessWidget {
  const CompletedTasks({Key? key, required this.taskDao, required this.listId})
    : super(key: key);
  final TaskDao taskDao;
  final int listId;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
      future: taskDao.getTasksByList(listId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading tasks'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tasks found'));
        } else {
          final tasks = snapshot.data!;
          return Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return TaskOption(task: tasks[index]);
              },
            ),
          );
        }
      },
    );
  }
}

// https://api.flutter.dev/flutter/material/ListTile-class.html
class TaskOption extends StatelessWidget {
  const TaskOption({Key? key, required this.task}) : super(key: key);
  final Task task;
  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(task.title));
  }
}

class NewTaskButton extends StatelessWidget {
  const NewTaskButton({super.key, required this.dao, required this.listId});
  final TaskDao dao;
  final int listId;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {showNewList(context, dao, listId)},
      borderRadius: BorderRadius.circular(5),
      child: Ink(
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: const [
            Icon(Icons.add, color: Colors.blue, size: 30),
            SizedBox(width: 5),
            Text(
              "Nieuwe lijst",
              style: TextStyle(color: Colors.blue, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  // https://api.flutter.dev/flutter/material/AlertDialog-class.html
  Future<void> showNewList(BuildContext context, TaskDao dao, int listId) {
    final TextEditingController controllerTitle = TextEditingController();
    final TextEditingController controllerDescription = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nieuwe lijst toevoegen'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controllerTitle,
                      decoration: const InputDecoration(
                        hintText: 'Naam van de task',
                      ),
                    ),
                    TextField(
                      controller: controllerDescription,
                      decoration: const InputDecoration(
                        hintText: 'Beschrijving van de task',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDate == null
                                ? 'Geen datum gekozen'
                                : 'Datum: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                          ),
                        ),
                        TextButton(
                          child: const Text('Kies datum'),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedTime == null
                                ? 'Geen tijd gekozen'
                                : 'Tijd: ${selectedTime!.format(context)}',
                          ),
                        ),
                        TextButton(
                          child: const Text('Kies tijd'),
                          onPressed: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedTime = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Toevoegen'),
                  onPressed: () async {
                    final name = controllerTitle.text.trim();
                    final description = controllerDescription.text.trim();
                    if (name.isNotEmpty &&
                        selectedDate != null &&
                        selectedTime != null) {
                      final DateTime dateTime = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedTime!.hour,
                        selectedTime!.minute,
                      );
                      Task newTask = Task(
                        title: name,
                        description: description,
                        listId: listId,
                        dueDate: dateTime,
                      );
                      try {
                        await dao.insertTask(newTask);
                        Navigator.of(context).pop();
                      } catch (e) {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Fout bij toevoegen: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
