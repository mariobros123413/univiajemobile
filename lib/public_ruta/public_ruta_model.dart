import '../flutter_flow/flutter_flow_icon_button.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart'
    as gm;
import 'package:http/http.dart' as http;
import 'package:google_map_polyline_new/google_map_polyline_new.dart';

// import '/backend/backend.dart';

class PublicRutaModel extends ChangeNotifier {
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
  DateTime? datePicked1;
  DateTime? datePicked2;
  PublicRutaModel(
      {this.id,
      this.idusuarioconductor,
      this.inicio,
      this.finals,
      this.asientos,
      this.destino,
      this.paradaintermedia});

  Future<void> updateRoute(List<gmf.LatLng> routePoints) async {
    final directionsResponse = await http.get(
      Uri.parse('https://maps.googleapis.com/maps/api/directions/json'
          '?destination=${routePoints.last.latitude},${routePoints.last.longitude}'
          '&origin=${routePoints.first.latitude},${routePoints.first.longitude}'
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
          final gmf.LatLng originLatLng = gmf.LatLng(
              routePoints.first.latitude, routePoints.first.longitude);
          final gmf.LatLng destinationLatLng =
              gmf.LatLng(routePoints.last.latitude, routePoints.last.longitude);

          final List<gmf.LatLng> waypoints =
              (await googleMapPolyline.getCoordinatesWithLocation(
            origin: originLatLng,
            destination: destinationLatLng,
            mode: RouteMode.driving,
          ))!
                  .cast<gmf.LatLng>();
          waypointsList = waypoints;
        }
      }
    } else {
      // Manejar el caso en que no se obtenga la polilínea correctamente
    }
  }

  Future<void> createRuta() async {
    final url =
        'https://apiuniviaje-production.up.railway.app/api/ruta/$idusuarioconductor';
    print(idusuarioconductor);
    print('inicio: $inicioLatLng');
    try {
      final body = <String, dynamic>{
        'horariosalida': horasalidaController.text,
        'horarioregreso': horaregresoController.text,
        'paradaintermedia': paradaintermediaController.text,
        'asientos': asientosController.text,
        // 'destino': datePicked1 != null
        //     ? DateFormat('yyyy-MM-dd').format(datePicked1!)
        //     : '',
        'destino': destinoController.text,
        'inicio': this.inicio,
        'final': this.finals,
        'estado': true.toString(),
      };
      print('Body de la solicitud: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200) {
        print('Datos de la ruta Creada');
        // notifyListeners();
      } else {
        print('Error en la solicitud: ${response.statusCode} createRuta');
      }
    } catch (e) {
      print('Excepción durante la solicitud createRuta: $e');
    }
  }

  // Completer<GoogleMapController> _controllerCompleter =
  //     Completer<GoogleMapController>();

  /// Initialization and disposal methods.
  LatLng? googleMapsCenter;
  void initState(BuildContext context) {}

  void dispose() {}

  /// Action blocks are added here.
  final paradaintermediaController = TextEditingController();
  final horasalidaController = TextEditingController();
  final horaregresoController = TextEditingController();
  final asientosController = TextEditingController();
  final destinoController = TextEditingController();

  /// Additional helper methods are added here.
}
