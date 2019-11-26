import 'package:flutter/material.dart';
import 'package:flutter_sqlite/input_dialog.dart';
import 'package:flutter_sqlite/login.dart';
import 'package:flutter_sqlite/todo_sqlite_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: //Login()
            FutureBuilder<bool>(
          future: checkIfLoggedin(),
          builder: (context, response) {
            if (response.data == true)
              return MyHomePage(
                title: "Todo Demo",
              );
            else
              return Login();
          },
        ));
  }

  Future<bool> checkIfLoggedin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.containsKey('loggedin');
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ToDoSQliteProvider sQliteProvider = ToDoSQliteProvider();
  @override
  void initState() {
    openDatabase();
    super.initState();
  }

  void openDatabase() async {
    var status = await sQliteProvider.open("todo.db");
    if (status) {
      setState(() {});
    }
  }

  void _addTodo() async {
    final output = await showDialog<String>(
        context: context,
        builder: (BuildContext context) => SimpleInputDialog(
              title: "Add Todo",
            ));

    var todo = await sQliteProvider.insert(Todo(title:output, done: false));
    print(todo.id);
    /*int count = await sQliteProvider.getCount();
    print("count " + count.toString());
    List<Todo> todos = await sQliteProvider.getAllTodos();
    for (var todo in todos) {
      print(todo.toMap());
    }
*/
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    sQliteProvider.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Todo>>(
          future: sQliteProvider.getAllTodos(),
          builder: (context, snapshot) {
            if (snapshot.hasData)
              return Padding(
                padding: EdgeInsets.all(8),
                child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) => GestureDetector(
                          onTap: () {
                            updateTodo(snapshot.data[index]);
                          },
                          onLongPress: () {
                            deleteTodo(snapshot.data[index]);
                          },
                          child: Card(
                            elevation: 6,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 16, bottom: 16),
                              child: Stack(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      snapshot.data[index].title,
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: snapshot.data[index].done
                                          ? Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 32,
                                            )
                                          : Icon(
                                              Icons.check_circle_outline,
                                              color: Colors.green,
                                              size: 32,
                                            ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )),
              );
            else {
              return Text("No Data received");
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  updateTodo(Todo updatedTodo) async {
    updatedTodo.done = !updatedTodo.done;

    int value = await sQliteProvider.update(updatedTodo);
    if (value == 1) {
      setState(() {});
    }
  }

  deleteTodo(todo) async {
    int value = await sQliteProvider.delete(todo.id);
    if (value == 1) {
      // rebuild the UI
      setState(() {});
    }
  }
}
