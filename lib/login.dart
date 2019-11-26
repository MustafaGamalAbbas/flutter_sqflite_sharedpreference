import 'package:flutter/material.dart';
import 'package:flutter_sqlite/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatelessWidget {
  const Login({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("login"),
      ),
      body: 
          Center(
            child: RawMaterialButton(
            onPressed: () async {
              // print("objecta");
              SharedPreferences prefs = await SharedPreferences.getInstance();
              
              prefs.setBool('loggedin', true);
              //prefs.setInt("integer", 2);
              // print("object");
            
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => MyHomePage(
                          title: "Todo demo",
                        )),
              );
            },
            child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "login to todo App",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan,
                        fontSize: 24),
                  ),
                )),
        ),
          ),
       
    );
  }
}
