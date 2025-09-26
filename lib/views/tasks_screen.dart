import 'package:flutter/material.dart';
import '../data/dao/todolist_dao.dart';
import '../data/models/todoList.dart';
import '../data/models/task.dart';
import '../data/dao/task_dao.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key, required this.todoList});
  final TodoList todoList;

  @override
  Widget build(BuildContext context) {
    final TaskDao dao = TaskDao();

    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: Text(
          todoList.name,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Tasks',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  TasksList(taskDao: dao, list: todoList),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Completed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  CompletedList(taskDao: dao, list: todoList),
                ],
              ),
            ),
            TodoButton(taskDao: dao, list: todoList),
          ],
        ),
      ),
    );
  }
}

class TasksList extends StatelessWidget {
  final TaskDao taskDao;
  final TodoList list;

  const TasksList({super.key, required this.taskDao, required this.list});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
      future: taskDao.getTasksByList(list.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text(
            "Fout bij laden: ${snapshot.error}",
            style: const TextStyle(color: Colors.red),
          );
        }

        final tasks = snapshot.data?.where((t) => !t.isDone).toList() ?? [];

        if (tasks.isEmpty) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[500],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'Geen actieve taken',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[500],
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.title, style: const TextStyle(color: Colors.white)),
                subtitle: task.description.isNotEmpty
                    ? Text(task.description, style: const TextStyle(color: Colors.white70))
                    : null,
              );
            },
          ),
        );
      },
    );
  }
}

class CompletedList extends StatelessWidget {
  final TaskDao taskDao;
  final TodoList list;

  const CompletedList({super.key, required this.taskDao, required this.list});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
      future: taskDao.getTasksByList(list.id!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final tasks = snapshot.data?.where((t) => t.isDone).toList() ?? [];

        return Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[500],
            borderRadius: BorderRadius.circular(10),
          ),
          child: tasks.isEmpty
              ? const Center(child: Text('Geen voltooide taken', style: TextStyle(color: Colors.white)))
              : ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.title, style: const TextStyle(color: Colors.white)),
                subtitle: task.description.isNotEmpty
                    ? Text(task.description, style: const TextStyle(color: Colors.white70))
                    : null,
              );
            },
          ),
        );
      },
    );
  }
}

class TodoButton extends StatelessWidget {
  final TaskDao taskDao;
  final TodoList list;

  const TodoButton({super.key, required this.taskDao, required this.list});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => openDialog(context, taskDao, list),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text(
            "Voeg task toe",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }

  Future<void> openDialog(BuildContext context, TaskDao taskDao, TodoList list) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    DateTime? selectedDate;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nieuwe task toevoegen'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Titel', hintText: 'Voer titel in'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedDate != null
                            ? "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}"
                            : "Kies een datum",
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() => selectedDate = date);
                      },
                      child: const Text("Selecteer"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Beschrijving',
                    hintText: 'Voer beschrijving in',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuleer')),
            TextButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final description = descriptionController.text.trim();

                if (title.isNotEmpty && selectedDate != null) {
                  final task = Task(
                    title: title,
                    description: description,
                    dueDate: selectedDate!,
                    listId: list.id!,
                  );
                  await taskDao.insertTask(task);

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Task '$title' toegevoegd!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Vul alle velden in!")),
                  );
                }
              },
              child: const Text('Toevoegen'),
            ),
          ],
        ),
      ),
    );
  }
}
