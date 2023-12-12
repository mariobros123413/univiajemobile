// ignore_for_file: must_call_super

import 'dart:convert';
import 'package:flutter/widgets.dart';
// import 'package:univiaje/user_session.dart';

// import '../flutter_flow/flutter_flow_model.dart';
// import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
// import '../flutter_flow/flutter_flow_widgets.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class VehicleModel extends ChangeNotifier {
  int? id;
  int? idusuario;
  String? nroplaca;
  String? modelo;
  int? anio;
  int? capacidad;
  String? fotovehiculo;
  String? caracteristicasespeciales;
  bool isDataLoaded = false;

  @override
  VehicleModel({
    this.id,
    this.idusuario,
    this.nroplaca,
    this.modelo,
    this.anio,
    this.capacidad,
    this.fotovehiculo,
    this.caracteristicasespeciales,
  });

  Future<void> fetchVehicleData() async {
    final url =
        'https://apiuniviaje-production.up.railway.app/api/vehiculo/$idusuario';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final userList = jsonDecode(response.body) as List<dynamic>;
        print('userlist: $userList');
        if (userList.isNotEmpty) {
          final userData = userList[0] as Map<String, dynamic>;
          id = userData['id'];
          idusuario = userData['idusuario'];
          nroplaca = userData['nroplaca'];
          modelo = userData['modelo'];
          anio = userData['anio'];
          capacidad = userData['capacidad'];
          fotovehiculo = userData['fotovehiculo'];
          caracteristicasespeciales = userData['caracteristicasespeciales'];
          isDataLoaded = true;

          // Actualizar los controladores con los nuevos valores
          nroplacaController.text = nroplaca.toString();
          modeloController.text = modelo ?? '';
          anioController.text = anio.toString();
          capacidadController.text = capacidad?.toString() ?? '';
          fotovehiculoController.text = fotovehiculo?.toString() ?? '';
          caracteristicasespecialesController.text =
              caracteristicasespeciales ?? '';
          print('Vehicle data fetched successfully. ID: $id');

          // notifyListeners();
        } else {
          print('No se encontraron datos del vehiculo');
          if (hasDuplicateVehicles() != true) {
            createVehicle();
          }
        }
      } else {
        print('Error en la solicitud: ${response.statusCode} getVehiculo');
      }
    } catch (e) {
      print('Excepción durante la solicitud getVehiculo: $e');
    }
  }

  Future<void> updateVehicleData() async {
    final url =
        'https://apiuniviaje-production.up.railway.app/api/vehiculo/$idusuario';
    print('idusuario updateveichle: $idusuario');
    // print('datos para updatevehicledata: ')
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'nroplaca': nroplacaController.text,
          'modelo': modeloController.text,
          'anio': anioController.text.toString(),
          'capacidad': capacidadController.text.toString(),
          // 'fotovehiculo': fotovehiculoController.text,
          'caracteristicasespeciales': caracteristicasespecialesController.text,
        },
      );
      if (response.statusCode == 200) {
        notifyListeners();
      } else {
        print('Error en la solicitud: ${response.statusCode} updateVehiculo');
      }
    } catch (e) {
      print('Excepción durante la solicitud updateVehiculo: $e');
    }
  }

  Future<void> createVehicle() async {
    final url =
        'https://apiuniviaje-production.up.railway.app/api/vehiculocreate/$idusuario';
    print(idusuario);

    try {
      final response = await http.post(Uri.parse(url));
      print(response.body.toString());
      if (response.statusCode == 200) {
        // El vehículo se creó correctamente
        print('Vehículo creado correctamente');
        // notifyListeners();
      } else {
        print('Error en la solicitud: ${response.statusCode} createVehicle');
      }
    } catch (e) {
      print('Excepción durante la solicitud createVehicle: $e');
    }
  }

  Future<bool> hasDuplicateVehicles() async {
    final url =
        'https://apiuniviaje-production.up.railway.app/api/vehiculo/$idusuario';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final userList = jsonDecode(response.body) as List<dynamic>;
        final filteredList = userList
            .where((userData) => userData['idusuario'] == idusuario)
            .toList();
        return filteredList.length > 0;
      } else {
        print(
            'Error en la solicitud: ${response.statusCode} hasDuplicateVehicles');
      }
    } catch (e) {
      print('Excepción durante la solicitud getVehiculo: $e');
    }

    return false; // Si hay algún error en la solicitud, se asume que no hay duplicados
  }
  // late VehicleModel vehicleModel;

  final nroplacaController = TextEditingController();
  final modeloController = TextEditingController();
  final anioController = TextEditingController();
  final capacidadController = TextEditingController();
  final fotovehiculoController = TextEditingController();
  final caracteristicasespecialesController = TextEditingController();
  void dispose() {
    nroplacaController.dispose();
    modeloController.dispose();
    anioController.dispose();
    capacidadController.dispose();
    fotovehiculoController.dispose();
    caracteristicasespecialesController.dispose();
  }
}
