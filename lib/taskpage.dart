import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testjob/jsonTodo.dart';
import 'package:testjob/theme.dart';
import 'package:provider/provider.dart';



class App extends StatefulWidget {
  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  late TextEditingController textController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool valText = true;
  List<TodoInfo> todos = [];


  @override
  void initState() {
    textController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
    readTodos();
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void submitAddTodo() {
    if (formKey.currentState?.validate() ?? false) {
      final todoString = textController.text;
      if (todoString.isNotEmpty) {
        var todo = TodoInfo(todoText: todoString.trim(), todoCheck: false);
        addTodo(todo);
        textController.clear();
      }
    }
  }

  void removeTodoAt(int index) {
    setState(() {
      todos = [...todos]..removeAt(index);
      writeTodos(todos);
    });
  }

  void updateTodoAt(int index, TodoInfo todo) {
    setState(() {
      todos[index] = todo;
      writeTodos(todos);
    });
  }

  void addTodo(TodoInfo todo) {
    setState(() {
      todos = [todo, ...todos];
      writeTodos(todos);
    });
  }

  Future<void> writeTodos(data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('todLists', jsonEncode(data));
  }

  void readTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final List rawList = jsonDecode(prefs.getString('todLists') ?? '[]');
    if (rawList.isNotEmpty) {
      for (var rawTodo in rawList) {
        final todo = TodoInfo.fromJson(rawTodo);
        todos.add(todo);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: Provider.of<ThemeModel>(context).currentTheme,
        home:Scaffold(
          appBar: AppBar(
            title: Text("Список задач"),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Provider.of<ThemeModel>(context).currentTheme==ThemeData.dark()?Icons.wb_sunny  :Icons.dark_mode, color: Provider.of<ThemeModel>(context).currentTheme==ThemeData.dark()?Colors.white :Colors.black,),
                  onPressed: () => {
                    Provider.of<ThemeModel>(context,listen: false).toggleTheme()

                  })
            ],
//backgroundColor: Colors.orange[500],
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Tasks",
                        style: TextStyle(
                          fontSize: 70.0,
                          fontWeight: FontWeight.bold,
                          color:Provider.of<ThemeModel>(context).currentTheme==ThemeData.dark()?Colors.white:Colors.black
                        ),
                      ),
                      IconButton(
                        color: Provider.of<ThemeModel>(context).currentTheme==ThemeData.dark()?Colors.white:Colors.black,
                        iconSize: 70,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.fromLTRB(30.0, 10.0, 30, 10.0),
                        icon: const Icon(Icons.add_outlined),
                        onPressed:   ()  {
                          if (textController.text.replaceAll(" ", "").isNotEmpty) {
                            setState(() {
                              submitAddTodo();
                              valText = true;
                            });
                          }
                          else
                          {
                            setState(() {
                              valText = false;
                            });
                          }
                        }
                      )
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.height * 0.45,
                  child: TextFormField(
                      style: TextStyle(fontSize: 22.0),
                      controller: textController,
                      autofocus: true,
                  ),
                ),
                Align(
                    child: (valText == false)
                        ? Align(
                        child: Text(("Задача пуста"),
                            style: TextStyle(
                                fontSize: 25.0, color: Colors.red)),
                        alignment: Alignment.center)
                        : Align(
                        child: Text(
                          (""),
                        ),
                        alignment: Alignment.center)),
                Expanded(child: _rTodos())
              ],
            ),
          ),
        ));
  }

  Widget _rTodos() {
    var wgs = <Widget>[];
    for (int i = 0; i < todos.length; i++) {
      var todo = todos[i];
      wgs.add(
          GestureDetector(
              child: Dismissible(
                key: Key(todo.todoText ),
                child: CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  value: todo.todoCheck,
                  title: Text(todo.todoText, style: TextStyle(fontSize: 22.0)),
                  onChanged: (checkValue) =>
                      updateTodoAt(i, todo..todoCheck = checkValue ?? false),
                ),
                background: Container(
                  child: Icon(Icons.delete),
                  alignment: Alignment.centerRight,
                  color: Colors.redAccent,
                ),
                direction: DismissDirection.endToStart,
                movementDuration:
                const Duration(milliseconds: 200),
                onDismissed: (dismissDirection) {
                  removeTodoAt(i);
                  wgs.remove(widget);
                },
              )));
    }
    return ListView(children: wgs);
  }
}

