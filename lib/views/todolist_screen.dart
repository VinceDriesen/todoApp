import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../data/dao/todolist_dao.dart';
import '../data/models/todoList.dart';
import './tasks_screen.dart';

class TodolistScreen extends StatelessWidget {
  const TodolistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TodoListDao todoListDao = TodoListDao();
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade800,
                  blurRadius: 20,
                  spreadRadius: 2,
                  blurStyle: BlurStyle.normal,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "TodoApp",
                  style: TextStyle(
                    color: Colors.grey[900],
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          TodoListOpties(dao: todoListDao),
          const Spacer(),
          NewListButton(dao: todoListDao),
        ],
      ),
    );
  }
}

class NewListButton extends StatelessWidget {
  const NewListButton({super.key, required this.dao});
  final TodoListDao dao;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {showNewList(context, dao)},
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
  Future<void> showNewList(BuildContext context, TodoListDao dao) {
    final TextEditingController controller = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nieuwe lijst toevoegen'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Naam van de lijst'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Toevoegen'),
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  await dao.insertList(TodoList(name: name));
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class TodoListOpties extends StatelessWidget {
  const TodoListOpties({super.key, required this.dao});
  final TodoListDao dao;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder(
        future: dao.getLists(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (asyncSnapshot.hasError) {
            return Text(
              "Fout bij laden: ${asyncSnapshot.error}",
              style: const TextStyle(color: Colors.red),
            );
          }
          final opties = asyncSnapshot.data ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              const TodolistOptie(todolistTitle: "🔆 Mijn dag"),
              const SizedBox(height: 5),
              const TodolistOptie(todolistTitle: "📅 Morgen"),
              const Padding(
                padding: EdgeInsets.all(15.0),
                child: Divider(color: Colors.grey),
              ),
              // https://techdynasty.medium.com/listview-builder-in-flutter-e54a8fa2c7a0
              Expanded(
                child: ListView.builder(
                  itemCount: opties.length,
                  itemBuilder: (BuildContext context, int index) {
                    return TodolistOptie(todolistTitle: opties[index].name);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TodolistOptie extends StatelessWidget {
  const TodolistOptie({super.key, required this.todolistTitle});
  final String todolistTitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskScreen(todoListName: todolistTitle),
          ),
        ),
      },
      child: Ink(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // color: Colors.grey[200],
        ),
        padding: EdgeInsets.only(left: 15, top: 5, right: 5, bottom: 5),
        child: Text(todolistTitle, style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
