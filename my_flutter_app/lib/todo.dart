import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<TodoItem> _todoList = [];
  bool _viewCompleted = false;
  String _searchTerm = "";
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = true;
  int? _selectedTodoId;

  @override
  void initState() {
    super.initState();
    _fetchTodoList();
  }

  Future<void> _fetchTodoList() async {
    final response = await http.get(Uri.parse("http://127.0.0.1:8000/api/todos/"));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _todoList = data.map((item) => TodoItem.fromJson(item)).toList();
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load todo list');
    }
  }

  Future<void> _addTodo() async {
    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/api/todos/"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': _titleController.text,
        'description': _descriptionController.text,
        'completed': false,
      }),
    );
    if (response.statusCode == 201) {
      _titleController.clear();
      _descriptionController.clear();
      _fetchTodoList();
    }
  }

  void _toggleTodoComplete(TodoItem todo) async {
    final updatedTodo = TodoItem(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      completed: !todo.completed,
    );

    final response = await http.put(
      Uri.parse('http://127.0.0.1:8000/api/todos/${todo.id}/'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(updatedTodo.toJson()),
    );

    if (response.statusCode == 200) {
      _fetchTodoList();
    } else {
      throw Exception('Failed to update todo status');
    }
  }

  Future<void> _deleteTodo(TodoItem todo) async {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/api/todos/${todo.id}/'),
    );

    if (response.statusCode == 204) {
      _fetchTodoList();
    } else {
      throw Exception('Failed to delete todo');
    }
  }

  Future<void> _updateTodo(TodoItem todo) async {
    final response = await http.put(
      Uri.parse('http://127.0.0.1:8000/api/todos/${todo.id}/'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(todo.toJson()),
    );

    if (response.statusCode == 200) {
      _fetchTodoList();
    } else {
      throw Exception('Failed to update todo');
    }
  }

  void _toggleViewCompleted(bool? status) {
    if (status != null) {
      setState(() {
        _viewCompleted = status;
      });
    }
  }

  void _setSearchTerm(String term) {
    setState(() {
      _searchTerm = term;
    });
  }

  void _editTodoDialog(TodoItem todo) {
    _selectedTodoId = todo.id;
    _titleController.text = todo.title;
    _descriptionController.text = todo.description;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateTodo(TodoItem(
                  id: _selectedTodoId!,
                  title: _titleController.text,
                  description: _descriptionController.text,
                  completed: false,
                ));
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: _setSearchTerm,
                    decoration: InputDecoration(
                      labelText: 'Search Todos',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _viewCompleted,
                      onChanged: _toggleViewCompleted,
                    ),
                    Text('Show Completed Todos'),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _todoList.length,
                    itemBuilder: (context, index) {
                      final todo = _todoList[index];
                      if (_viewCompleted || !todo.completed) {
                        if (todo.title.toLowerCase().contains(_searchTerm.toLowerCase())) {
                          return TodoListItem(
                            todo: todo,
                            toggleTodoComplete: _toggleTodoComplete,
                            deleteTodo: _deleteTodo,
                            editTodo: _editTodoDialog,
                          );
                        }
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Add Todo'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _addTodo();
                      Navigator.of(context).pop();
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class TodoListItem extends StatelessWidget {
  final TodoItem todo;
  final Function(TodoItem) toggleTodoComplete;
  final Function(TodoItem) deleteTodo;
  final Function(TodoItem) editTodo;

  TodoListItem({required this.todo, required this.toggleTodoComplete, required this.deleteTodo, required this.editTodo});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      margin: EdgeInsets.symmetric(vertical: 2.0),
      child: ListTile(
        title: Text(todo.title),
        subtitle: Text(todo.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: todo.completed,
              onChanged: (_) => toggleTodoComplete(todo),
            ),
            IconButton(
              onPressed: () => editTodo(todo),
              icon: Icon(Icons.edit),
              color: Colors.blue,
            ),
            IconButton(
              onPressed: () => deleteTodo(todo),
              icon: Icon(Icons.delete),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class TodoItem {
  final int id;
  final String title;
  final String description;
  final bool completed;

  TodoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
    };
  }
}
