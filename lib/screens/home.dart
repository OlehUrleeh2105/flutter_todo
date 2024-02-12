import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/colors.dart';
import '../model/todo.dart';
import '../widgets/todo_item.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ToDo> todosList = [];
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();

  Future<void> _loadToDoList() async {
    final prefs = await SharedPreferences.getInstance();
    final todoList = prefs.getStringList('todos');
    if (todoList != null) {
      setState(() {
        todosList = todoList
            .map((todo) => ToDo(
                  id: todo.split('|')[0],
                  todoText: todo.split('|')[1],
                  isDone: todo.split('|')[2] == 'true',
                ))
            .toList();
      });
    }
  }

  Future<void> _saveToDoList() async {
    final prefs = await SharedPreferences.getInstance();
    final todoList = todosList
        .map((todo) => "${todo.id}|${todo.todoText}|${todo.isDone}")
        .toList();
    await prefs.setStringList('todos', todoList);
  }

  @override
  void initState() {
    super.initState();
    _loadToDoList().then((_) {
      setState(() {
        _foundToDo = todosList;
        _runFilter('');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: AppBar(
        backgroundColor: tdBGColor,
        title: const Text(
          'Todo',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(
              right: 20,
              left: 20,
              top: 10,
              bottom: 80,
            ),
            child: Column(
              children: [
                searchBox(),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          top: 20,
                          bottom: 20,
                        ),
                      ),
                      for (ToDo todoo in _foundToDo.reversed)
                        ToDoItem(
                          todo: todoo,
                          onToDoChanged: _handleToDoChange,
                          onDeleteItem: _deleteToDoItem,
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                      bottom: 20,
                      right: 20,
                      left: 20,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 10.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _todoController,
                      decoration: const InputDecoration(
                        hintText: 'Add a new todo item',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _addToDoItem(_todoController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tdBlue,
                      minimumSize: const Size(60, 60),
                      elevation: 10,
                    ),
                    child: const Text(
                      '+',
                      style: TextStyle(
                        fontSize: 40,
                        color: tdBGColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
      _saveToDoList();
      _runFilter('');
    });
  }

  void _deleteToDoItem(String id) {
    setState(() {
      todosList.removeWhere((item) => item.id == id);
      _saveToDoList();
    });
  }

  void _addToDoItem(String toDo) {
    if (toDo.isNotEmpty) {
      setState(() {
        todosList.add(ToDo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          todoText: toDo,
        ));
        _saveToDoList();
      });
      _todoController.clear();
    }
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) => item.todoText!
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    results.sort((a, b) {
      if (a.isDone && !b.isDone) {
        return -1;
      } else if (!a.isDone && b.isDone) {
        return 1;
      } else {
        return 0;
      }
    });

    setState(() {
      _foundToDo = results;
    });
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: tdBGColor,
            spreadRadius: 5,
            blurRadius: 7,
          )
        ],
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: tdBlack,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }
}
