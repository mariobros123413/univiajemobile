import 'dart:convert';

import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;

class PeticionesModel extends ChangeNotifier {
  int? id;
  int? idusuariopasajero;
  int? idusuariconductor;
  int? idruta;
  String? foto;
  String? preferenciasviaje;

  String? ubicacionrecogida;
  String? destino;
  String? horadeseadaviaje;
  bool? aceptacion;
  String? nombre;
  String? puntuacion;
  List<PeticionesModel>? apiDataList;
  gm.LatLng? ubicacion;
  PeticionesModel(
      {this.id,
      this.idusuariopasajero,
      this.idusuariconductor,
      this.idruta,
      this.foto,
      this.preferenciasviaje,
      this.ubicacionrecogida,
      this.horadeseadaviaje,
      this.aceptacion,
      this.nombre,
      this.destino,
      this.puntuacion,
      this.ubicacion});
  final unfocusNode = FocusNode();

  Future<void> fetchApiSolicitud() async {
    try {
      print(idusuariconductor);
      final response = await http.get(Uri.parse(
          'https://apiuniviaje-production.up.railway.app/api/solicitudes/$idusuariconductor'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        final apiData = data.map((item) {
          final ubicacionRecogida = item['ubicacionrecogida'].toString();
          final ubicacionLatLng = _convertStringToLatLng(ubicacionRecogida);
          print(ubicacionLatLng.toString());
          return PeticionesModel(
            idusuariopasajero: item['idusuariopasajero'],
            preferenciasviaje: item['preferenciasviaje'],
            foto: item['fotoperfil'],
            horadeseadaviaje: item['horadeseadaviaje'].toString(),
            nombre: item['nombre'],
            destino: item['destino'],
            puntuacion: item['puntuacion'].toString(),
            idruta: item['idruta'],
            ubicacionrecogida: ubicacionRecogida,
            ubicacion: ubicacionLatLng,
          );
        }).toList();

        apiDataList = apiData;
      } else {
        print('Error en la solicitud GET PETICIONES: $response.statusCode');
      }
    } catch (error) {
      // Manejar el error de la solicitud HTTP
      print('ERROR fetchApiSolicitud() : $error');
    }
  }

  Future<void> updateSolicitud(int? idusuariopasajero, int? idruta) async {
    final url =
        'https://apiuniviaje-production.up.railway.app/api/solicitud/$idusuariopasajero/$idruta';
    print(idusuariopasajero);
    try {
      final body = <String, dynamic>{
        'aceptacion': true.toString(),
      };
      print('Body de la solicitud: $body');

      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200) {
        print('Datos de la solicitud actualizados');
        // notifyListeners();
      } else {
        print('Error en la solicitud: ${response.statusCode} updateSolicitud');
      }
    } catch (e) {
      print('Excepción durante la solicitud updateSolicitud: $e');
    }
  }

  Future<void> terminarRuta() async {
    final url = 'https://apiuniviaje-production.up.railway.app/api/ruta/$id';
    print(idusuariopasajero);
    try {
      final body = <String, dynamic>{
        'aceptacion': true.toString(),
      };
      print('Body de la solicitud: $body');

      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200) {
        print('Datos de la solicitud actualizados');
        // notifyListeners();
      } else {
        print('Error en la solicitud: ${response.statusCode} updateSolicitud');
      }
    } catch (e) {
      print('Excepción durante la solicitud updateSolicitud: $e');
    }
  }

  gm.LatLng? _convertStringToLatLng(String? ubicacionRecogida) {
    if (ubicacionRecogida == null) return null;
    final parts = ubicacionRecogida.split(',');
    if (parts.length != 2) return null;

    final lat = double.tryParse(parts[0]);
    final lng = double.tryParse(parts[1]);

    if (lat == null || lng == null) return null;

    return gm.LatLng(lat, lng);
  }

  String formatTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }

  /// Initialization and disposal methods.
  String? getFormattedTime(DateTime? dateTime) {
    if (dateTime != null) {
      return formatTime(dateTime);
    }
    return null;
  }

  void initState(BuildContext context) {}

  void dispose() {}

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
