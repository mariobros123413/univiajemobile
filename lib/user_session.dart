import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './vehicle/vehicle_model.dart';

class UserSession with ChangeNotifier {
  int? id;
  int? nroregistro;
  String? correo;
  String? nombre;
  int? celular;
  String? fotoperfil;
  String? carrera;
  String? preferenciasviaje;
  late VehicleModel vehicleModel;

  UserSession({
    this.nroregistro,
    this.nombre,
    this.correo,
    this.celular,
    this.fotoperfil,
    this.carrera,
    this.preferenciasviaje,
  }) {
    vehicleModel = VehicleModel(idusuario: id);
  }

  Future<void> fetchUserData() async {
    final url =
        'https://apiuniviaje-production.up.railway.app/api/usuario/$nroregistro';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final userList = jsonDecode(response.body) as List<dynamic>;
        if (userList.isNotEmpty) {
          final userData = userList[0] as Map<String, dynamic>;
          id = userData['id'];
          correo = userData['correo'];
          nombre = userData['nombre'];
          celular = userData['celular'];
          fotoperfil = userData['fotoperfil'];
          carrera = userData['carrera'];
          preferenciasviaje = userData['preferenciasviaje'];
          vehicleModel.idusuario = id;
          notifyListeners();

          print('User data fetched successfully. ID: $id');
        } else {
          print('No se encontraron datos de usuario');
        }
      } else {
        print(
            'Error en la solicitud: ${response.statusCode} fetchUserData user_session');
      }
    } catch (e) {
      print('Excepción durante la solicitud: $e');
    }
  }
}
