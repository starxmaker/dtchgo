import 'package:dtchgo/classes/DAOs.dart';
import 'package:flutter/material.dart';
import '../classes/ApiResource.dart';

import '../widgets/BootstrapCard.dart';

class Login extends StatefulWidget {
    final Function notifier;
    Login({Key? key, required this.notifier}) :super (key: key);
    @override
    _LoginState createState() => _LoginState();

}

class _LoginState extends State<Login> {
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      _loading = true;
    });
    print("hacer login al back");
    Future<UserCredential?> fuc = ApiResource.retrieveSavedCredentials();
    fuc.then((UserCredential? uc) => {
      if (uc == null){
        setState(() {
          _loading = false;
        })
      }else{
        ApiResource.login(uc.username, uc.password, uc.baseUrl).then((value) => {
          print("sesion iniciada"),
              if(value){
                  widget.notifier(true)
              }
        }).catchError((e){
          ApiResource.removeCredentials();
          setState(() {
          _loading = false;
          });
        })
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        child: _loading? CircularProgressIndicator(
          value: null,
          semanticsLabel: 'Loading'
        ) : LoginForm(notifier: widget.notifier)
      ) 
    );
  }
}


class LoginForm extends StatefulWidget {
  final Function notifier;
  const LoginForm({Key? key, required this.notifier}) : super(key :key);
  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  bool _guardarCredenciales = false;
  bool _processing = false;
  TextEditingController _baseUrl = TextEditingController();
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();

  void notifyError(String message){
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red
      ),
    );
  }

  @override
  void initState(){

  }
  @override 
  Widget build(BuildContext context) {
    return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/18),
        alignment: Alignment.center,
        width: double.infinity,
        child: BootstrapCard(
          title: "Autenticarse",
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget> [
                
                Container(
                  margin: EdgeInsets.only(top:10),
                  child: TextField(
                    controller: _baseUrl,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(15),
                      hintText: "URL del servidor",
                      border: OutlineInputBorder(),
                      
                    )
                  )
                ),
                Container(
                  margin: EdgeInsets.only(top:10),
                  child: TextField(
                    controller: _username,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(15),
                      hintText: "Usuario",
                      border: OutlineInputBorder(),
                      
                    )
                  )
                ),
                Container(
                  margin: EdgeInsets.only(top:10),
                  child: TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(15),
                      hintText: "Contraseña",
                      border: OutlineInputBorder(),
                      
                    )
                  )
                ),
                SwitchListTile(
                  title: const Text('Guardar credenciales'),
                  value: _guardarCredenciales,
                  onChanged: (bool value) {
                    setState(() {
                      _guardarCredenciales = value;
                    });
                  }
                ),
              Container(
                margin: EdgeInsets.only(top: 20),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _processing? null : () {
                    if(_processing) return;
                    setState(() { _processing = true;});
                    if(_baseUrl.text.trim().length == 0){
                      notifyError("Debe indicar una URL de servidor");
                      setState(() { _processing = false;});
                      return;
                    }
                    if(_username.text.trim().length == 0){
                      notifyError("Debe indicar su nombre de usuario");
                      setState(() { _processing = false;});
                      return;
                    }
                    if(_password.text.trim().length == 0){
                      notifyError("Debe indicar su contraseña");
                      setState(() { _processing = false;});
                      return;
                    }
                    try {
                      ApiResource.login(_username.text, _password.text, _baseUrl.text)
                        .then((value) => {
                          if(value){
                            if(_guardarCredenciales){
                              ApiResource.saveCredentials(_username.text, _password.text, _baseUrl.text)
                            },
                            widget.notifier(true)
                          }else{
                            notifyError("Credenciales incorrectas"),
                            setState(() { _processing = false;})
                          }
                        })
                        .catchError((e) => {
                          notifyError("Credenciales incorrectas"),
                          setState(() { _processing = false;})
                        });
                    } catch(e){
                      notifyError("Credenciales incorrectas");
                      setState(() { _processing = false;});
                    }

                  },
                  child: const Text('Iniciar sesión'),
                  style: ButtonStyle()
                )
              )
            ]
          )
        )
      )
    )
    );
  }
}

