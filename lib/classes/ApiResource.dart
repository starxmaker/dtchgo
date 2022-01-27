import 'dart:convert';

import "./responses.dart";
import 'package:dio/dio.dart' as DIO;
import '../classes/DAOs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiResource {
  static String cookieToken = "";
  static String csrfToken = "";
  static String baseUrl = "";
  static final _storage = new FlutterSecureStorage();
  static Future<UserCredential?> retrieveSavedCredentials() async{
    try{
      String username = await ApiResource._storage.read(key: "username") as String;
      String password = await ApiResource._storage.read(key: "password") as String;
      String baseUrl = await ApiResource._storage.read(key: "baseUrl") as String;
      UserCredential uc = new UserCredential(username, password, baseUrl);
      return uc;
    }catch(e){
      print("no se obtuvieron credenciales");
      return null;
    }
  }
  static Future<bool> saveCredentials(String username, String password, String baseUrl) async {
    try{
      await ApiResource._storage.write(key: "username", value: username);
      await ApiResource._storage.write(key: "password", value: password);
      await ApiResource._storage.write(key: "baseUrl", value: baseUrl);
      return true;
    }catch(e){
      return false;
    }
  }
  static Future<void> saveReservatationPreference(bool reserve) async {
    try{
      await ApiResource._storage.write(key: "reserve", value: reserve.toString());
      print("guardado");
    }catch(e){
      
    }
  }
  static Future<bool> retrieveReservatationPreference() async {
    try{
      String rawReserve = await ApiResource._storage.read(key: "reserve") as String;
      return rawReserve == 'true';

      
    }catch(e){
      print(e);
      return false;
    }
  }
  static Future<bool> removeCredentials()async {
    try{
      await ApiResource._storage.deleteAll();
      return true;
    }catch(e){
      return false;
    }
  }
  static Future<bool> login(String user, String password, String baseurl) async {
    ApiResource.baseUrl = baseurl;
    String url = baseurl+"/usuarios/login";
    if(!url.startsWith("http")) return false;
    try{
      var cuerpo = {
        "username": user,
        "password": password
      };
      var response  = await DIO.Dio().post(url, data: cuerpo).catchError((e) {
        print("error");
        return false;
      });
      LoginResponse lr = LoginResponse.fromJson(response.data);
      ApiResource.csrfToken = lr.csrfToken;
      ApiResource.cookieToken = ApiResource._obtainNewCookieToken(response.headers['Set-Cookie'] as List<String>);
      return true;
    } on DIO.DioError catch (e) {
      print (e);
      print("no se realizó login");
      return false;
    }
  }

  static String _obtainNewCookieToken (List<String> cookies){
    String first = cookies[0];
    String tokens = first.split(";")[0];
    return tokens.split("=")[1];
  }

  static Future<int> getCantidadNumerosDisponibles() async {
    String url = "https://dtch.herokuapp.com/telefonos/available";
    try {
      var response = await DIO.Dio().get(url,
      options: DIO.Options(headers: {
        "csrfToken": csrfToken,
        "Cookie": "token="+cookieToken
      }));
      
      AvailableResponse ar = AvailableResponse.fromJson(response.data);
      if(response.headers['Set-Cookie'] != null){
        ApiResource.cookieToken = ApiResource._obtainNewCookieToken(response.headers['Set-Cookie'] as List<String>);
      }
      return ar.quantity;
    } catch (e){
      print("no funcionó");
      print(e);
      return 0;

    }
  }

  static Future<bool> guardarNumero(String direccion, String codigo_pais, String codigo_region, String numero, int fuente, bool esFijo, bool reservado) async {
    String url = "https://dtch.herokuapp.com/telefonos/";
    try {
      var params =  {
        "direccion": direccion,
        "codigo_pais": int.parse(codigo_pais),
        "codigo_region": esFijo? int.parse(codigo_region) : "",
        "numero": numero,
        "grupo": 0,
        "fuente": fuente,
        "tipo": esFijo? 0 : 1,
        "publicador": 0,
        "reserve": reservado
      }; 
      var response = await DIO.Dio().post(url,
        options: DIO.Options(headers: {
          "csrfToken": csrfToken,
          "Cookie": "token="+cookieToken
        }),
        data: jsonEncode(params)
      );
      
      if(response.headers['Set-Cookie'] != null){
        ApiResource.cookieToken = ApiResource._obtainNewCookieToken(response.headers['Set-Cookie'] as List<String>);
      }
      return true;
    } catch (e){
      print("no funcionó");
      print(e);
      return false;

    }
  }


  static Future<List<Fuente>> getFuentes() async {
    String url = "https://dtch.herokuapp.com/fuentes/getAll";
    try {
      var response = await DIO.Dio().get(url,
      options: DIO.Options(headers: {
        "csrfToken": csrfToken,
        "Cookie": "token="+cookieToken
      }));
      List<dynamic> fuentesRaw = response.data as List<dynamic>;
      List<Fuente> fuentes = <Fuente>[];
      fuentesRaw.forEach((element) {
        fuentes.add(Fuente.fromJson(element));
      });
      if(response.headers['Set-Cookie'] != null){
        ApiResource.cookieToken = ApiResource._obtainNewCookieToken(response.headers['Set-Cookie'] as List<String>);
      }
      return fuentes;
    } catch (e){
      print("no funcionó");
      print(e);
      return <Fuente> [];
    }
  }
  static Future<bool> checkNumeroExistance(String numero) async {
    String url = "https://dtch.herokuapp.com/telefonos/checkExistance/"+numero;
    try {
      var response = await DIO.Dio().get(url,
      options: DIO.Options(headers: {
        "csrfToken": csrfToken,
        "Cookie": "token="+cookieToken
      }));
      Map<String, dynamic> json = response.data;
      bool existe = json['exists'];
      if(response.headers['Set-Cookie'] != null){
        ApiResource.cookieToken = ApiResource._obtainNewCookieToken(response.headers['Set-Cookie'] as List<String>);
      }
      print(existe);
      return existe;
    } catch (e){
      print("no funcionó");
      print(e);
      return true;
    }
  }
}