import 'dart:convert';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart'
    as gmf;

// import '/backend/backend.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';

import '../flutter_flow/flutter_flow_google_map.dart';
import '../flutter_flow/flutter_flow_icon_button.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class RutaModel extends ChangeNotifier {
  FocusNode? unfocusNode; // Declaración con nullable
  int? id;
  int? idusuarioconductor;
  String? inicio;
  String? finals;
  LatLng? inicioLatLng;
  LatLng? finalLatLng;
  int? asientos;
  String? destino;
  String? paradaintermedia;
  // List<RutaModel>? apiDataList; //YA NO LO USO
  LatLng? currentLocation;

  List<gmf.LatLng>? waypointsList;

  RutaModel(
      {this.id,
      this.idusuarioconductor,
      this.inicio,
      this.finals,
      this.asientos,
      this.destino,
      this.paradaintermedia});

  Future<void> fetchApiData() async {
    // Resto del código...

    final response = await http.get(Uri.parse(
        'https://apiuniviaje-production.up.railway.app/api/ruta/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      final userData = data[0] as Map<String, dynamic>;
      id = userData['id'];
      idusuarioconductor = userData['idusuarioconductor'];
      asientos = userData['asientos'];
      destino = userData['destino'];
      paradaintermedia = userData['paradaintermedia'];
      // Obtener el primer elemento de la lista de datos
      final item = data.first;
      print('paradaintermedia: $paradaintermedia');
      // Obtener las coordenadas de inicio y final
      final LatLng inicioLatLng = LatLng(
        double.parse(item['inicio'].split(',')[0]),
        double.parse(item['inicio'].split(',')[1]),
      );
      final LatLng finalLatLng = LatLng(
        double.parse(item['final'].split(',')[0]),
        double.parse(item['final'].split(',')[1]),
      );
      this.inicioLatLng = inicioLatLng;
      this.finalLatLng = finalLatLng;
      // Obtener la ruta utilizando la API de Google Maps Directions
      final directionsResponse = await http.get(
        Uri.parse('https://maps.googleapis.com/maps/api/directions/json'
            '?destination=${finalLatLng.latitude},${finalLatLng.longitude}'
            '&origin=${inicioLatLng.latitude},${inicioLatLng.longitude}'
            '&key=AIzaSyDCTVlXYBc5P3caFSXF8VS-fT7F4OddVTI'),
      );
      final directionsData = json.decode(directionsResponse.body);

      final GoogleMapPolyline googleMapPolyline =
          GoogleMapPolyline(apiKey: 'AIzaSyDCTVlXYBc5P3caFSXF8VS-fT7F4OddVTI');
      if (directionsResponse.statusCode == 200) {
        if (directionsData['routes'] != null &&
            directionsData['routes'].isNotEmpty) {
          final route = directionsData['routes'][0];

          if (route['overview_polyline'] != null &&
              route['overview_polyline']['points'] != null) {
            final gmf.LatLng originLatLng =
                gmf.LatLng(inicioLatLng.latitude, inicioLatLng.longitude);
            final gmf.LatLng destinationLatLng =
                gmf.LatLng(finalLatLng.latitude, finalLatLng.longitude);

            final List<gmf.LatLng> waypoints =
                (await googleMapPolyline.getCoordinatesWithLocation(
              origin: originLatLng,
              destination: destinationLatLng,
              mode: RouteMode.driving,
            ))!
                    .cast<gmf.LatLng>();

            waypointsList = waypoints.cast<gmf.LatLng>();
            // Resto del código...
          } else {
            // Manejar el caso de que no haya puntos de coordenadas en la respuesta
          }
        } else {
          // Manejar el caso de que no haya rutas en la respuesta
        }
      } else {
        // Manejar el caso de error en la respuesta de la API de direcciones
      }
    }
    notifyListeners();
    // Resto del código...
  }

// ...
  Future<void> crearPeticion(
      String? horadeseada, String? ubicacionrecogida) async {
    int? idruta = this.id;
    final url =
        'https://apiuniviaje-production.up.railway.app/api/solicitud/$idusuarioconductor/$idruta';
    print(idusuarioconductor);
    try {
      final body = <String, dynamic>{
        'ubicacionrecogida': ubicacionrecogida,
        'destino': this.destino,
        'horadeseadaviaje': horadeseada,
        'aceptacion': false.toString()
      };
      print('Body de la solicitud: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200) {
        print('Datos de la petición Creada');
        // notifyListeners();
      } else {
        print('Error en la solicitud: ${response.statusCode} crearPeticion');
      }
    } catch (e) {
      print('Excepción durante la solicitud crearPeticion: $e');
    }
  }

  String formatTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }

// ...

// Dentro de tu clase HomeModel:
  String? getFormattedTime(DateTime? dateTime) {
    if (dateTime != null) {
      return formatTime(dateTime);
    }
    return null;
  }

  // State field(s) for GoogleMap widget.
  LatLng? googleMapsCenter;
  final googleMapsController = Completer<GoogleMapController>();

  /// Initialization and disposal methods.

  void initState(BuildContext context) {}

  void dispose() {}

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
