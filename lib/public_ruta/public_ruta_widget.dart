import 'dart:async';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart'
    as gmf;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;

import '../flutter_flow/flutter_flow_icon_button.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../peticiones/peticiones_widget.dart';
import '../user_session.dart';
import 'public_ruta_model.dart';
export 'public_ruta_model.dart';
import 'package:location/location.dart';
import 'package:intl/intl.dart';

class PublicRutaWidget extends StatefulWidget {
  const PublicRutaWidget({Key? key}) : super(key: key);

  @override
  _PublicRutaWidgetState createState() => _PublicRutaWidgetState();
}

class _PublicRutaWidgetState extends State<PublicRutaWidget> {
  late PublicRutaModel _model;
  late UserSession _modelU;
  late Location location;
  Set<gm.Marker> _markers = {};
  gm.CameraPosition _initialCameraPosition = gm.CameraPosition(
    target: gm.LatLng(-17.76938946637218, -63.18178082749441),
    zoom: 14,
  );
  final scaffoldKey = GlobalKey<ScaffoldState>();
  gm.LatLng? _startLatLng;
  gm.LatLng? _endLatLng;
  List<gm.LatLng> _waypoints = [];
  String formatDate(DateTime dateTime) {
    final formatter = DateFormat('yyyy/MM/dd HH:mm');
    return formatter.format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    _modelU = Provider.of<UserSession>(context, listen: false);
    _model = Provider.of<PublicRutaModel>(context, listen: false);
    _model.idusuarioconductor = _modelU.id;
    // Inicializar la instancia de Location
    location = Location();

    // Solicitar permisos de ubicación al iniciar el widget
    requestLocationPermission();
    startLocationUpdates();
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

  Future<void> _drawRoute() async {
    if (_startLatLng != null && _endLatLng != null) {
      List<gm.LatLng> routePoints = [
        gm.LatLng(_startLatLng!.latitude, _startLatLng!.longitude),
        gm.LatLng(_endLatLng!.latitude, _endLatLng!.longitude),
      ];

      await _model.updateRoute(routePoints);

      setState(() {
        _waypoints = _model.waypointsList ?? [];
      });
    }
  }

  Future<void> _removeMarker(gm.MarkerId markerId) async {
    setState(() {
      if (_startLatLng != null && markerId.value == 'startMarker') {
        _startLatLng = null;
      } else if (_endLatLng != null && markerId.value == 'endMarker') {
        _endLatLng = null;
      }

      _waypoints =
          _waypoints.where((marker) => markerId.value != markerId).toList();
    });
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
    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context)
      ..pop()
      ..pop();
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
                  Expanded(
                    child: gm.GoogleMap(
                      mapType: gm.MapType.normal,
                      initialCameraPosition: _initialCameraPosition,
                      markers: {
                        if (_startLatLng != null)
                          gm.Marker(
                            markerId: gm.MarkerId('Inicio'),
                            position: _startLatLng!,
                            icon: gm.BitmapDescriptor.defaultMarker,
                            onTap: () => _removeMarker(gm.MarkerId('Inicio')),
                          ),
                        if (_endLatLng != null)
                          gm.Marker(
                            markerId: gm.MarkerId('Final'),
                            position: _endLatLng!,
                            icon: gm.BitmapDescriptor.defaultMarker,
                            onTap: () => _removeMarker(gm.MarkerId('Final')),
                          )
                      },
                      polylines: {
                        gm.Polyline(
                          polylineId: gm.PolylineId('route'),
                          color: Colors.blue,
                          width: 4,
                          points: _waypoints,
                        ),
                      },
                      onTap: (gm.LatLng latLng) {
                        setState(() {
                          if (_startLatLng == null) {
                            _startLatLng = latLng;
                          } else if (_endLatLng == null) {
                            _endLatLng = latLng;
                            _drawRoute();
                          }
                        });
                      },
                      myLocationEnabled: true, // Habilitar la ubicación actual
                      myLocationButtonEnabled:
                          true, // Habilitar el botón de ubicación actual
                    ),
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
                      onPressed: () {
                        _delayedPop(context);
                      },
                    ),
                  ),
                ],
              ),
              Align(
                alignment: AlignmentDirectional(0, 1),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 44),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        color: Colors.transparent,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.96,
                          height: 290,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(5, 12, 5, 12),
                            child: SingleChildScrollView(
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
                                          fontSize: 20,
                                        ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 4, 0, 8),
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
                                        8, 0, 8, 5),
                                    child: TextFormField(
                                        controller:
                                            _model.paradaintermediaController,
                                        autofocus: true,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          labelText: 'Parada Intermedia...',
                                          labelStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium,
                                          hintStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium,
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          errorBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          focusedErrorBorder:
                                              UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 0, 15),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Align(
                                          alignment:
                                              AlignmentDirectional(-1, 0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0, 5, 0, 0),
                                            child: FFButtonWidget(
                                              onPressed: () async {
                                                final _datePicked1Date =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate:
                                                      getCurrentTimestamp,
                                                  firstDate: DateTime(1900),
                                                  lastDate: getCurrentTimestamp,
                                                );
                                                TimeOfDay? _datePicked1Time;
                                                if (_datePicked1Date != null) {
                                                  _datePicked1Time =
                                                      await showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                        TimeOfDay.fromDateTime(
                                                            getCurrentTimestamp),
                                                  );
                                                }
                                                if (_datePicked1Date != null &&
                                                    _datePicked1Time != null) {
                                                  setState(() {
                                                    _model.datePicked1 =
                                                        DateTime(
                                                      _datePicked1Date.year,
                                                      _datePicked1Date.month,
                                                      _datePicked1Date.day,
                                                      _datePicked1Time!.hour,
                                                      _datePicked1Time.minute,
                                                    );
                                                    _model.horasalidaController
                                                            .text =
                                                        formatDate(_model
                                                            .datePicked1!); // Formatea la fecha y hora en un formato deseado
                                                  });
                                                }
                                              },
                                              text: 'Hora Salida',
                                              options: FFButtonOptions(
                                                width: 80,
                                                height: 40,
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 0, 0, 0),
                                                iconPadding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(0, 0, 0, 0),
                                                color: Color(0xFFF9F9F9),
                                                textStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              'Readex Pro',
                                                          color: Colors.black,
                                                        ),
                                                elevation: 3,
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  8, 0, 8, 0),
                                          child: Container(
                                            width: 150,
                                            child: TextFormField(
                                                controller:
                                                    _model.horasalidaController,
                                                readOnly: true,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  hintStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium,
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  focusedBorder:
                                                      InputBorder.none,
                                                  errorBorder: InputBorder.none,
                                                  focusedErrorBorder:
                                                      InputBorder.none,
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 0, 15),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Align(
                                          alignment:
                                              AlignmentDirectional(-1, 0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0, 5, 0, 0),
                                            child: FFButtonWidget(
                                              onPressed: () async {
                                                final _datePicked2Date =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate:
                                                      getCurrentTimestamp,
                                                  firstDate: DateTime(1900),
                                                  lastDate: getCurrentTimestamp,
                                                );
                                                TimeOfDay? _datePicked2Time;
                                                if (_datePicked2Date != null) {
                                                  _datePicked2Time =
                                                      await showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                        TimeOfDay.fromDateTime(
                                                            getCurrentTimestamp),
                                                  );
                                                }
                                                if (_datePicked2Date != null &&
                                                    _datePicked2Time != null) {
                                                  setState(() {
                                                    _model.datePicked2 =
                                                        DateTime(
                                                      _datePicked2Date.year,
                                                      _datePicked2Date.month,
                                                      _datePicked2Date.day,
                                                      _datePicked2Time!.hour,
                                                      _datePicked2Time.minute,
                                                    );
                                                    _model.horaregresoController
                                                            .text =
                                                        formatDate(_model
                                                            .datePicked2!); // Formatea la fecha y hora en un formato deseado
                                                  });
                                                }
                                              },
                                              text: 'Hora Regreso',
                                              options: FFButtonOptions(
                                                width: 80,
                                                height: 40,
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 0, 0, 0),
                                                iconPadding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(0, 0, 0, 0),
                                                color: Color(0xFFF9F9F9),
                                                textStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily:
                                                              'Readex Pro',
                                                          color: Colors.black,
                                                        ),
                                                elevation: 3,
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  8, 0, 8, 0),
                                          child: Container(
                                            width: 150,
                                            child: TextFormField(
                                                controller: _model
                                                    .horaregresoController,
                                                readOnly: true,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  hintStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium,
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  focusedBorder:
                                                      InputBorder.none,
                                                  errorBorder: InputBorder.none,
                                                  focusedErrorBorder:
                                                      InputBorder.none,
                                                ),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            8, 0, 8, 0),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                          child: TextFormField(
                                              controller:
                                                  _model.asientosController,
                                              autofocus: true,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                labelText: 'Asientos...',
                                                labelStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium,
                                                hintStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium,
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                errorBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                focusedErrorBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  8, 0, 8, 0),
                                          child: TextFormField(
                                              controller:
                                                  _model.destinoController,
                                              autofocus: true,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                labelText: 'Destino..',
                                                labelStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium,
                                                hintStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium,
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                errorBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                focusedErrorBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 10, 0, 0),
                                    child: FFButtonWidget(
                                      onPressed: () {
                                        _model.inicio = _startLatLng
                                            .toString()
                                            .replaceAll('LatLng(', '')
                                            .replaceAll(')', '');

                                        _model.finals = _endLatLng
                                            .toString()
                                            .replaceAll('LatLng(', '')
                                            .replaceAll(')', '');
                                        _model.createRuta().then((_) {
                                          const SnackBar(
                                              content:
                                                  Text('Cambios guardados'));
                                        }).catchError((error) {
                                          SnackBar(
                                              content: Text(
                                                  'Error al guardar los cambios'));
                                        });
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PeticionesWidget()),
                                        );
                                      },
                                      text: 'Crear',
                                      options: FFButtonOptions(
                                        height: 40,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            24, 0, 24, 0),
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                0, 0, 0, 0),
                                        color: Color(0xFF39E6EF),
                                        textStyle: FlutterFlowTheme.of(context)
                                            .labelLarge,
                                        elevation: 3,
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
