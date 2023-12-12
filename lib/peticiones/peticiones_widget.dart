import 'dart:convert';

import '../flutter_flow/flutter_flow_icon_button.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart'
    as gmf;
import 'package:location/location.dart';

import '../flutter_flow/flutter_flow_widgets.dart';
import '../user_session.dart';
import 'peticiones_model.dart';
export 'peticiones_model.dart';

class PeticionesWidget extends StatefulWidget {
  const PeticionesWidget({Key? key}) : super(key: key);

  @override
  _PeticionesWidgetState createState() => _PeticionesWidgetState();
}

class _PeticionesWidgetState extends State<PeticionesWidget> {
  late PeticionesModel _model;
  late UserSession _modelU;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isModalVisible = false;
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _model = Provider.of<PeticionesModel>(context, listen: false);
    _modelU = Provider.of<UserSession>(context, listen: false);
    _model.idusuariconductor = _modelU.id;

    _model.fetchApiSolicitud();
  }

  @override
  void dispose() {
    _model.dispose();
    _unfocusNode.dispose(); // Liberar el FocusNode

    super.dispose();
  }

  Future<void> _refreshPeticiones() async {
    // Lógica para cargar nuevas solicitudes aquí
    _model.fetchApiSolicitud();
    // Esperar un tiempo simulado de 2 segundos (reemplazar con tu lógica de carga real)
    await Future.delayed(Duration(seconds: 2));

    // Actualizar el estado para mostrar las nuevas solicitudes
    setState(() {
      // Actualizar las solicitudes en el modelo o cargar las nuevas solicitudes aquí
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_model.unfocusNode),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30,
            borderWidth: 1,
            buttonSize: 60,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF14181B),
              size: 30,
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Navegar hacia atrás
            },
          ),
          title: Text(
            'Solicitudes de Viaje',
            style: FlutterFlowTheme.of(context).headlineLarge.override(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.normal,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: RefreshIndicator(
            onRefresh: _refreshPeticiones,
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                  child: Text(
                    'Universitarios :',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Readex Pro',
                          color: Color(0xFF606A85),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _model.apiDataList?.length ?? 0,
                  itemBuilder: (context, index) {
                    final cardData = _model.apiDataList![index];
                    return Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Color(0x4D9489F5),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color(0xFF6F61EF),
                                    width: 2,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(2),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(40),
                                    child: Image.memory(
                                      base64Decode(cardData.foto ?? ''),
                                      width: double.infinity,
                                      height: 220,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      8, 0, 0, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cardData.nombre ?? '',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Readex Pro',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 4, 0, 0),
                                        child: AutoSizeText(
                                          cardData.preferenciasviaje ?? '',
                                          textAlign: TextAlign.start,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                color: Color(0xFF606A85),
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 4, 0, 0),
                                        child: AutoSizeText(
                                          cardData.destino ?? '',
                                          textAlign: TextAlign.start,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                color: Color(0xFF606A85),
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 4, 0, 0),
                                        child: AutoSizeText(
                                          cardData.puntuacion ?? '',
                                          textAlign: TextAlign.start,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                color: Color(0xFF606A85),
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0, 4, 0, 0),
                                        child: AutoSizeText(
                                          cardData.preferenciasviaje ?? '',
                                          textAlign: TextAlign.start,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Readex Pro',
                                                color: Color(0xFF606A85),
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            cardData.horadeseadaviaje
                                                .toString(),
                                            textAlign: TextAlign.start,
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  fontFamily: 'Readex Pro',
                                                  color: Color(0xFF606A85),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              final ubicacion =
                                                  cardData.ubicacion;
                                              showModalBottomSheet(
                                                context: context,
                                                builder: (context) =>
                                                    _buildMapModal(
                                                        ubicacion as gm.LatLng?,
                                                        cardData
                                                            .idusuariopasajero,
                                                        cardData.idruta),
                                              );
                                            },
                                            child: Icon(
                                              Icons.chevron_right,
                                              color: Color(0xFF606A85),
                                              size: 24,
                                            ),
                                          ),
                                        ],
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
                  },
                ),
                Divider(
                  thickness: 1,
                  color: FlutterFlowTheme.of(context).accent4,
                ),
                FFButtonWidget(
                  onPressed: () {
                    print('Button pressed ...');
                  },
                  text: 'Terminar Rutas',
                  options: FFButtonOptions(
                    height: 40,
                    padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                    iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Readex Pro',
                          color: Colors.white,
                        ),
                    elevation: 3,
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapModal(
      gm.LatLng? ubicacionrecogida, int? idusuariopasajero, int? idruta) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa'),
      ),
      body: Column(
        children: [
          Expanded(
            child: gm.GoogleMap(
              initialCameraPosition: gm.CameraPosition(
                target: ubicacionrecogida ?? gm.LatLng(0, 0),
                zoom: 14.0,
              ),
              markers: {
                gm.Marker(
                  markerId: gm.MarkerId('pickupMarker'),
                  position: ubicacionrecogida ?? gm.LatLng(0, 0),
                ),
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _model.updateSolicitud(idusuariopasajero, idruta);
              Navigator.pop(context);
            },
            child: Text('Aceptar solicitud'),
          ),
        ],
      ),
    );
  }
}
