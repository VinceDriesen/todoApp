import 'package:flutter/material.dart';
import '../data/dao/todolist_dao.dart';
import '../data/models/todoList.dart';

class AddTodoListDialog extends StatelessWidget {
  final TodoListDao todoDao;
  final VoidCallback? onListAdded;

  const AddTodoListDialog({super.key, required this.todoDao, this.onListAdded});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return AlertDialog(
      backgroundColor: Colors.grey[850],
      title: const Text(
        "Nieuwe lijst toevoegen",
        style: TextStyle(color: Colors.white),
      ),
      content: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: "Naam van de lijst",
          hintStyle: TextStyle(color: Colors.white54),
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Annuleer", style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () async {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              await todoDao.insertList(TodoList(name: name));
              Navigator.of(context).pop();
              if (onListAdded != null) {
                onListAdded!(); // callback om UI te refreshen
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Lijst '$name' toegevoegd!")),
              );
            }
          },
          child: const Text("Toevoegen", style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }

  /// Helper functie om het dialog te openen
  // static Future<void> show(BuildContext context,
  //     {required TodoListDao todoDao, VoidCallback? onListAdded}) {
  //   return showDialog(
  //     context: context,
  //     builder: (context) => AddTodoListDialog(
  //       todoDao: todoDao,
  //       onListAdded: onListAdded,
  //     ),
  //   );
  // }
  static Future<void> show(BuildContext context,
      {required TodoListDao todoDao, VoidCallback? onListAdded}) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Your Name'),
        content: TextField(
          decoration: InputDecoration(hintText: 'Enter your name'),
        )
      ),
    );
  }
}
