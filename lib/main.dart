

import 'package:dtchgo/classes/ApiResource.dart';
import 'package:flutter/material.dart';
import './views/PhoneForm.dart';
import './views/Login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    String title = "DTCH Go";
    return MaterialApp(
      title: title,
      theme: ThemeData.dark(),
      home: MainView(),
    );
  }
}

class MainView extends StatefulWidget {
  MainView({Key? key}) : super(key: key);
  @override
  MainViewState createState() => MainViewState();
}



class MainViewState extends State<MainView> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;

  static const List<Widget> _widgetOptions = <Widget>[
    PhoneForm(),
    Text("En construcción"),
    Text("En construcción")
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text("DTCH Go"),
        actions: _isLoggedIn?  <Widget>[
          PopupMenuButton<String>(
            onSelected: (String){
              setState(() {
                _isLoggedIn = false;
              });
              ApiResource.removeCredentials();
            },
            itemBuilder: (BuildContext context) {
              return {'Cerrar sesión'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ] : null,
      ),
      body: _isLoggedIn? _widgetOptions.elementAt(_selectedIndex) : Login(notifier: (result) {
        setState(() {
          _isLoggedIn = result;
        });
      }),
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Agregar número',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Directorio',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}






