import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart'
    as gmf;
import 'package:univiaje/home/home_widget.dart';

import '../flutter_flow/flutter_flow_icon_button.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'ruta_model.dart';
export 'ruta_model.dart';
import 'package:location/location.dart';

class RutaWidget extends StatefulWidget {
  const RutaWidget({Key? key}) : super(key: key);

  @override
  _RutaWidgetState createState() => _RutaWidgetState();
}

class _RutaWidgetState extends State<RutaWidget> {
  late RutaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  gm.LatLng? _pickupLatLng;
  TimeOfDay? _selectedTime;

  late Location location;
  Set<gm.Marker> _markers = {};
  gm.CameraPosition _initialCameraPosition = gm.CameraPosition(
    target: gm.LatLng(0, 0),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _model = Provider.of<RutaModel>(context, listen: false);
    _model
        .fetchApiData(); // Llamar al método fetchApiData para obtener los datos de la ruta

    // Inicializar la instancia de Location
    location = Location();

    // Solicitar permisos de ubicación al iniciar el widget
    requestLocationPermission();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> requestLocationPermission() async {
    final permissionStatus = await location.requestPermission();
    if (permissionStatus != PermissionStatus.granted) {
      // Los permisos de ubicación no están otorgados, maneja esta situación
      // según los requisitos de tu aplicación.
      // Por ejemplo, podrías mostrar un mensaje al usuario o redirigirlo a la configuración de permisos.
    } else {
      // Los permisos de ubicación están otorgados, puedes iniciar la obtención de ubicación.
      startLocationUpdates();
    }
  }

  Future<void> _delayedPop(BuildContext context) async {
    unawaited(
      Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          ),
          transitionDuration: Duration.zero,
          barrierDismissible: false,
          barrierColor: Colors.black45,
          opaque: false,
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context)
      ..pop()
      ..pop();
  }

  Future<void> startLocationUpdates() async {
    location.onLocationChanged.listen((LocationData currentLocation) {
      if (mounted) {
        setState(() {
          // Actualizar la posición del marcador
          final marker = gm.Marker(
            markerId: gm.MarkerId('currentLocation'),
            position: gm.LatLng(
              currentLocation.latitude!,
              currentLocation.longitude!,
            ),
          );

          _markers = {marker}; // Actualizar el conjunto de marcadores

          // Actualizar la posición de la cámara inicial
          _initialCameraPosition = gm.CameraPosition(
            target: gm.LatLng(
              currentLocation.latitude!,
              currentLocation.longitude!,
            ),
            zoom: 14,
          );

          // Puedes ajustar el nivel de zoom y la posición de la cámara aquí si lo deseas
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_model.unfocusNode),
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Consumer<RutaModel>(
                    builder: (context, model, _) {
                      if (model.inicioLatLng == null ||
                          model.finalLatLng == null) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        final inicioLatLng = gmf.LatLng(
                          model.inicioLatLng!.latitude,
                          model.inicioLatLng!.longitude,
                        );
                        final finalLatLng = gmf.LatLng(
                          model.finalLatLng!.latitude,
                          model.finalLatLng!.longitude,
                        );
                        final List<gmf.LatLng> waypointsList =
                            _model.waypointsList?.map((latLng) {
                                  return gmf.LatLng(
                                      latLng.latitude, latLng.longitude);
                                }).toList() ??
                                [];
                        final List<gmf.LatLng> polylinePoints = [
                          inicioLatLng,
                          ...waypointsList,
                          finalLatLng
                        ];

                        // Agregar marcadores para "Inicio" y "Final"
                        final inicioMarker = gm.Marker(
                          markerId: gm.MarkerId('inicioMarker'),
                          position: inicioLatLng,
                          infoWindow: gm.InfoWindow(title: 'Inicio'),
                        );
                        final finalMarker = gm.Marker(
                          markerId: gm.MarkerId('finalMarker'),
                          position: finalLatLng,
                          infoWindow: gm.InfoWindow(title: 'Final'),
                        );

                        // Actualizar el conjunto de marcadores
                        _markers = {inicioMarker, finalMarker};
                        return Expanded(
                          // Agrega el Expanded widget aquí

                          child: gm.GoogleMap(
                            initialCameraPosition: gm.CameraPosition(
                              target: _pickupLatLng ??
                                  inicioLatLng, // Usar la posición del nuevo punto seleccionado si está presente, de lo contrario usar la posición inicial
                              zoom: _pickupLatLng != null
                                  ? 16.0
                                  : 14.0, // Ajustar el nivel de zoom si hay un nuevo punto seleccionado
                            ),

                            polylines: {
                              gmf.Polyline(
                                polylineId: gmf.PolylineId('ruta'),
                                color: Colors.blue,
                                width: 3,
                                points: polylinePoints,
                              ),
                            },
                            onTap: (gm.LatLng latLng) {
                              setState(() {
                                _pickupLatLng = latLng;
                              });
                            },
                            markers: {
                              ..._markers,
                              if (_pickupLatLng != null)
                                gm.Marker(
                                  markerId: gm.MarkerId('pickupMarker'),
                                  position: _pickupLatLng!,
                                  icon:
                                      gm.BitmapDescriptor.defaultMarkerWithHue(
                                          gm.BitmapDescriptor.hueGreen),
                                  onTap: () {
                                    setState(() {
                                      _pickupLatLng =
                                          null; // Eliminar el punto seleccionado al hacer tap en el marcador
                                    });
                                  },
                                ),
                            },
                            myLocationEnabled:
                                true, // Habilitar la ubicación actual
                            myLocationButtonEnabled:
                                true, // Habilitar el botón de ubicación actual
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: FlutterFlowIconButton(
                      borderColor: Color(0xFF050317),
                      borderRadius: 20.0,
                      borderWidth: 1.0,
                      buttonSize: 40.0,
                      fillColor: Color(0xFF0C0202),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      onPressed: () async {
                        _delayedPop(context);
                      },
                    ),
                  ),
                ],
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 44.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        color: Colors.transparent,
                        elevation: 3.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.96,
                          height: 200.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                5.0, 12.0, 5.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Información de la ruta',
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        fontFamily: 'Readex Pro',
                                        color: Colors.black,
                                        fontSize: 20.0,
                                      ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 4.0, 0.0, 8.0),
                                  child: Text(
                                    'Parada Intermedia: ',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          color: Color(0xFF1D2429),
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 2.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Text(
                                          _model.paradaintermedia ??
                                              'Na', // Utiliza la propiedad correspondiente del modelo
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  height: 3.0,
                                  thickness: 1.0,
                                  color: FlutterFlowTheme.of(context).accent4,
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 12.0, 0.0, 20.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 0.0, 8.0),
                                            child: Text(
                                              'Asientos',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Outfit',
                                                        color:
                                                            Color(0xFF2C3A42),
                                                      ),
                                            ),
                                          ),
                                          Text(
                                            _model.asientos.toString(),
                                            style: FlutterFlowTheme.of(context)
                                                .headlineLarge,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 0.0, 8.0),
                                            child: Text(
                                              'Destino',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Outfit',
                                                        color:
                                                            Color(0xFF57636C),
                                                      ),
                                            ),
                                          ),
                                          Text(
                                            _model.destino ?? 'Na',
                                            style: FlutterFlowTheme.of(context)
                                                .headlineLarge
                                                .override(
                                                  fontFamily: 'Outfit',
                                                  fontSize: 18.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return Container(
                                                padding: EdgeInsets.all(16),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Seleccionar Hora',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(height: 16),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        showTimePicker(
                                                          context: context,
                                                          initialTime:
                                                              TimeOfDay.now(),
                                                        ).then((selectedTime) {
                                                          setState(() {
                                                            _selectedTime =
                                                                selectedTime;
                                                          });
                                                        });
                                                      },
                                                      child: Text(
                                                          'Seleccionar Hora'),
                                                    ),
                                                    SizedBox(height: 16),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        String? ubicacion;
                                                        ubicacion =
                                                            _pickupLatLng
                                                                .toString()
                                                                .replaceAll(
                                                                    'LatLng(',
                                                                    '')
                                                                .replaceAll(
                                                                    ')', '');
                                                        print(
                                                            'ubicacion: $ubicacion');
// Obtener la fecha actual del dispositivo
                                                        DateTime now =
                                                            DateTime.now();

                                                        // Crear una instancia de DateTime con la fecha actual y la hora seleccionada
                                                        DateTime
                                                            selectedDateTime =
                                                            DateTime(
                                                          now.year,
                                                          now.month,
                                                          now.day,
                                                          _selectedTime!.hour,
                                                          _selectedTime!.minute,
                                                        );

                                                        // Formatear la fecha y hora seleccionada en el formato deseado "yyyy-mm-dd hh:mm"
                                                        String
                                                            formattedDateTime =
                                                            DateFormat(
                                                                    'yyyy-MM-dd HH:mm')
                                                                .format(
                                                                    selectedDateTime);

                                                        // Enviar la petición
                                                        _model.crearPeticion(
                                                            formattedDateTime,
                                                            ubicacion);

                                                        // Mostrar el modal de "OK"
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title:
                                                                  Text('Éxito'),
                                                              content: Text(
                                                                  'La petición se realizó con éxito.'),
                                                              actions: [
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context); // Cerrar el modal de "OK"
                                                                  },
                                                                  child: Text(
                                                                      'OK'),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Text('Enviar'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 8.0),
                                              child: Text(
                                                'Hacer Petición',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Outfit',
                                                          color:
                                                              Color(0xFF57636C),
                                                        ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_outlined,
                                              color: Color(0xFF0C0202),
                                              size: 40.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
