import 'package:flutter/material.dart';
import '../classes/DAOs.dart';
import '../classes/ApiResource.dart';

import '../widgets/BootstrapCard.dart';

class PhoneForm extends StatefulWidget {
  const PhoneForm({Key? key}) : super(key :key);
  @override
  PhoneFormState createState() => PhoneFormState();
}

class PhoneFormState extends State<PhoneForm> {
  var numeroFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _esTelefono = false;
  bool _reserved = false;
  int _cantidadTelefonos = 0;
  int _fuente = 6;
  bool _processing = false;
  TextEditingController _codigoPais = TextEditingController(text: '56');
  TextEditingController _codigoArea = TextEditingController(text: '51');
  TextEditingController _numero = TextEditingController();
  TextEditingController _sector = TextEditingController();
  List<Fuente> _fuentes = <Fuente> [];
  bool checkNumeroFormat(){
    try {
      String numero = _numero.text;
      int.parse(numero);
      if(_esTelefono){
        return numero.trim().length == 7;
      }else{
        return numero.trim().length == 9;
      }
    } catch(e){
      return false;
    }
  }
  Future<bool> checkNumeroExistance (){
    String numero = _numero.text;
    Future<bool> existe = ApiResource.checkNumeroExistance(numero);
    return existe;
  }

  void notifyError(String message){
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red
      ),
    );
  }

  void notifySuccess(String message){
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green
      ),
    );
  }

  void cleanForm(){
    _numero.text = "";
  }

  void cargarNumerosDisponibles(){
    Future<int> cantidadNumeros = ApiResource.getCantidadNumerosDisponibles();
    cantidadNumeros.then((value) => {
      setState(() {
        _cantidadTelefonos = value;
      })
    });
  }
  @override
  void initState(){
    
    Future<List<Fuente>> fuentes = ApiResource.getFuentes();
    cargarNumerosDisponibles();

    ApiResource.retrieveReservatationPreference().then((value) => {
      setState(() {
        _reserved = value;
      })
    });
    
    numeroFocusNode.addListener(() {
      if(!numeroFocusNode.hasFocus) {
        if(!checkNumeroFormat()) {
          
          notifyError("Formato incorrecto");
        }else {
          checkNumeroExistance().then((existe) => {
            if(existe){
              notifyError("N??mero ya existe")
            }else{
              notifySuccess("N??mero disponible")
            }
          });
        }
      }
    });

    
    fuentes.then((value) => {
      setState((){
        _fuentes = value;
      })
    });
  }
  @override 
  Widget build(BuildContext context) {
    return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/18),
        alignment: Alignment.center,
        width: double.infinity,
        child: BootstrapCard(
          title: "Nuevo registro",
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget> [
                SwitchListTile(
                  title: const Text('??Es tel??fono fijo?'),
                  value: _esTelefono,
                  onChanged: (bool value) {
                    setState(() {
                      _esTelefono = value;
                    });
                  }
                ),
                Container(
                  margin: EdgeInsets.only(top:10),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: 
                        TextField(
                            controller: _codigoPais,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.all(15),
                              prefix: Text("Pa??s "),
                              border: OutlineInputBorder()
                            )
                          )
                        ),
                      if(_esTelefono) Expanded(child:
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        child:
                        TextField(
                          controller: _codigoArea,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.all(15),
                            prefix: Text("??rea "),
                            border: OutlineInputBorder()
                          ),
                        )
                      )
                      )
                    ],
                  )
                ),
                Container(
                  margin: EdgeInsets.only(top:10),
                  child: TextField(
                    controller: _numero,
                    focusNode: numeroFocusNode,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(15),
                      hintText: "N??mero",
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: _numero.clear,
                        icon: Icon(Icons.clear),
                      )
                    )
                  )
                ),
                Container(
                  margin: EdgeInsets.only(top:10),
                  child: TextField(
                    controller: _sector,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.all(15),
                      hintText: "Sector",
                      border: OutlineInputBorder()
                    ),
                  )
                ),
                Container(
                  margin: EdgeInsets.only(top:10),
                  child: DropdownButtonFormField<String>(
                  onChanged: (String? changedValue) {
                    setState(() {
                      _fuente = int.parse(changedValue as String);
                    });
                  },
                  value: _fuente.toString(),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.all(15),
                    hintText: "Fuente",
                    border: OutlineInputBorder()
                  ),
                  items: _fuentes.map((Fuente fuente) {
                    return DropdownMenuItem<String>(
                      value: fuente.value.toString(),
                      child: new Text(fuente.label as String),
                    );
                  }).toList(),
                )
              ),
               SwitchListTile(
                  title: const Text('Reservar n??mero'),
                  value: _reserved,
                  onChanged: (bool value) {
                    setState(() {
                      _reserved = value;
                    });
                    ApiResource.saveReservatationPreference(value);
                  }
                ),
              Container(
                margin: EdgeInsets.only(top: 20),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _processing? null : () {
                    if(_processing) return;
                    setState(() { _processing = true;});
                    print(_processing);
                    RegExp _numeric = RegExp(r'^-?[0-9]+$');
                    if(_codigoPais.text.trim().length == 0 || !_numeric.hasMatch(_codigoPais.text)){
                      notifyError("C??digo de pa??s inv??lido");
                      setState(() { _processing = false;});
                      return;
                    }
                    if(_esTelefono && _codigoArea.text.trim().length == 0 || !_numeric.hasMatch(_codigoArea.text)){
                      notifyError("C??digo de ??rea inv??lido");
                      setState(() { _processing = false;});
                      return;
                    }
                    if (_sector.text.trim().length == 0){
                      notifyError("Sector inv??lido");
                      setState(() { _processing = false;});
                      return;
                    }
                    if(_numero.text.trim().length == 0 || !_numeric.hasMatch(_numero.text)){
                      notifyError("N??mero con formato incorrecto");
                      setState(() { _processing = false;});
                      return;
                    }else{
                      if(!checkNumeroFormat()) {
                        notifyError("Formato incorrecto");
                        setState(() { _processing = false;});
                        return;
                      }else {
                        checkNumeroExistance().then((existe) => {
                          if(existe){
                            notifyError("N??mero ya existe"),
                            setState(() { _processing = false;})
                          }else{
                            //seguir
                            ApiResource.guardarNumero(_sector.text, _codigoPais.text, _codigoArea.text, _numero.text, _fuente, _esTelefono, _reserved).then((result) => {
                              if(result){
                                notifySuccess("N??mero ingresado"),
                                cleanForm(),
                                cargarNumerosDisponibles()
                              }else{
                                notifyError("No se pudo ingresar el n??mero")
                              },
                              setState(() { _processing = false;})
                            })
                          }
                        });
                      }
                    }
                  },
                  child: const Text('Guardar'),
                  style: ButtonStyle()
                )
              ),
               FlatButton(
                  onPressed: (){
                    cargarNumerosDisponibles();
                  },
                  child: 
                  RichText(
                  text: TextSpan(
                    children: [
                      TextSpan (
                        text: "N??meros disponibles: "+_cantidadTelefonos.toString()+" ",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      WidgetSpan(
                        child: Icon(Icons.cached, size: 14, color: Colors.white),
                      )
                    ],
                  ),
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