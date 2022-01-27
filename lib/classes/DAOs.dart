class Fuente {
  late String label;
  late int value;
  Fuente (String label, int value){
    this.label = label;
    this.value = value;
  }
  factory Fuente.fromJson(Map<String, dynamic> json) {
    return Fuente(json['nombre'], json['idFuente']);
  }
}

class UserCredential{
  late String username;
  late String password;
  late String baseUrl;
  UserCredential(String username, String password, String baseUrl){
    this.username = username;
    this.password = password;
    this.baseUrl = baseUrl;
  }
}