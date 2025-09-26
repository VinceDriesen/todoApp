import 'dart:ffi';

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
    TaskDao dao = TaskDao();
    print("yeet");
    print(todoList.name);
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
                          fontSize: 20
                      ),
                    ),
                  ),
                  TasksList(taskDao: dao, list: todoList,),
                  const SizedBox(height: 30),
                  const Center(
                    child: Text(
                      'Completed',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20
                      ),
                    ),
                  ),
                  const CompletedList(),
                ],
              ),
            ),
            const TodoButton(), // knop staat nu echt onderaan en full-width
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
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[500],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class CompletedList extends StatelessWidget {
  const CompletedList({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[500],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class TodoButton extends StatelessWidget {
  const TodoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: 30,
        child: ElevatedButton(
          onPressed: () => (),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: const Text(
            "Voeg lijst toe",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
