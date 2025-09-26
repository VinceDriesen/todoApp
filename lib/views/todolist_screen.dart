import 'package:flutter/material.dart';
import '../data/dao/todolist_dao.dart';
import '../data/models/todoList.dart';
import './tasks_screen.dart';

class TodolistView extends StatelessWidget {
  const TodolistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
            "Todo List",
            style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[800],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TodoDropdown(),
            SizedBox(height: 16),
            Spacer(),
            TodoButton(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class TodoDropdown extends StatelessWidget {
  const TodoDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final vasteOpties = ["🔆 Mijn dag", "📅 Morgen"];
    final todoDao = TodoListDao();

    return FutureBuilder<List<TodoList>>(
      future: todoDao.getLists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text(
            "Fout bij laden: ${snapshot.error}",
            style: const TextStyle(color: Colors.red),
          );
        }

        final dynamischeOpties = snapshot.data ?? [];
        print(dynamischeOpties);
        final opties = [
          ...vasteOpties,
          ...dynamischeOpties.map((list) => list.name),
        ];

        return ListView.builder(
          shrinkWrap: true,
          itemCount: opties.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                opties[index],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              onTap: () async {
                print("Gekozen: ${opties[index]}");

                final TodoList? list = await todoDao.getListByName(opties[index]);
                if (list != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TasksView(
                        todoList: list,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lijst niet gevonden!")),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}

class TodoButton extends StatelessWidget {
  const TodoButton({super.key});

  @override
  Widget build(BuildContext context) {
    final todoDao = TodoListDao();

    return ElevatedButton(
      onPressed: () => openDialog(context, todoDao),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      child: const Text(
        "Voeg lijst toe",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }

  Future<void> openDialog(BuildContext context, TodoListDao todoDao) {
    final TextEditingController controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nieuwe lijst toevoegen'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Naam van de lijst'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuleer'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await todoDao.insertList(TodoList(name: name));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lijst '$name' toegevoegd!")),
                );
              }
            },
            child: const Text('Toevoegen'),
          ),
        ],
      ),
    );
  }
}
