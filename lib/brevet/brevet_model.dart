// ignore_for_file: unused_import

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:univiaje/user_session.dart';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import '../flutter_flow/flutter_flow_model.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:http_parser/http_parser.dart';

class BrevetModel extends ChangeNotifier {
  int? id;
  int? ci;
  String? nombre;
  String? foto;
  String? catlicencia;
  DateTime? fecexpedicion;
  DateTime? fecvencimiento;
  bool isDataLoaded = false;
  DateTime? datePicked1;
  DateTime? datePicked2;
  String? imageUrl;

  @override
  BrevetModel(
      {this.id,
      this.ci,
      this.nombre,
      this.foto,
      this.catlicencia,
      this.fecexpedicion,
      this.fecvencimiento});

  Future<void> fetchBrevetData(BuildContext context) async {
    final url = 'https://apiuniviaje-production.up.railway.app/api/brevet/$id';
    try {
      final response = await http.get(Uri.parse(url));
      print(response.body.toString());
      if (response.statusCode == 200) {
        final userList = jsonDecode(response.body) as List<dynamic>;
        if (userList.isNotEmpty) {
          final userData = userList[0] as Map<String, dynamic>;
          id = userData['id'];
          ci = userData['ci'];
          nombre = userData['nombre'];
          foto = userData['foto'];
          catlicencia = userData['catlicencia'];
          final fecexpedicion = userData['fecexpedicion'];
          final fecvencimiento = userData['fecvencimiento'];
          isDataLoaded = true;

          // Mostrar los datos en el body
          if (foto != null && foto!.isNotEmpty) {
            // Cargar la imagen desde la API si la variable foto no está vacía
            final imageBytes = await base64.decode(foto!);
            // Cargar la imagen decodificada utilizando Image.memory
            uploadedLocalFile = await FFUploadedFile(bytes: imageBytes);
          } else {
            // La variable foto es null o está vacía, asignar una imagen de muestra
            final placeholderUrl =
                'https://img.freepik.com/vector-gratis/plantilla-licencia-conducir-diseno-plano_23-2149944210.jpg?w=2000';
            final placeholderResponse =
                await http.get(Uri.parse(placeholderUrl));
            if (placeholderResponse.statusCode == 200) {
              // Decodificar los bytes de la imagen de muestra de internet
              final placeholderBytes = placeholderResponse.bodyBytes;
              // Cargar la imagen de muestra utilizando Image.memory
              uploadedLocalFile = FFUploadedFile(bytes: placeholderBytes);
            }
          }

          print('object fetch brevetdata: $id');

          ciController.text = ci.toString();
          nombreController.text = nombre ?? '';
          catlicenciaController.text = catlicencia.toString();
          datePicked1 = DateTime.parse(fecexpedicion);
          datePicked2 = DateTime.parse(fecvencimiento);
          print(ciController.text.toString());
          print('Brevet data fetched successfully. ID: $id');
        } else {
          print('No se encontraron datos del brevet');
          if (hasDuplicateBrevets() != true) {
            createBrevet();
          }
        }
      } else {
        print('Error en la solicitud: ${response.statusCode} getBrevet');
      }
    } catch (e) {
      print('Excepción durante la solicitud getBrevet: $e');
    }
  }

// ...

  Future<void> updateBrevetData() async {
    final url = 'https://apiuniviaje-production.up.railway.app/api/brevet/$id';
    print(id);
    try {
      final body = <String, dynamic>{
        'ci': ciController.text ?? '',
        'nombre': nombreController.text ?? '',
        'foto': '', // Actualizar la foto más adelante
        'catlicencia': catlicenciaController.text?.toString() ?? '',
        'fecexpedicion': datePicked1 != null
            ? DateFormat('yyyy-MM-dd').format(datePicked1!)
            : '',
        'fecvencimiento': datePicked2 != null
            ? DateFormat('yyyy-MM-dd').format(datePicked2!)
            : '',
      };
      print('Body de la solicitud: $body');

      if (uploadedLocalFile != null && uploadedLocalFile.bytes != null) {
        final encodedImage = await base64.encode(uploadedLocalFile.bytes!);
        body['foto'] = encodedImage;
      }

      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200) {
        print('Datos del brevet actualizados');
        // notifyListeners();
      } else {
        print('Error en la solicitud: ${response.statusCode} updateBrevet');
      }
    } catch (e) {
      print('Excepción durante la solicitud updateBrevet: $e');
    }
  }

  Future<void> createBrevet() async {
    print('createbrevet id: $id');
    final url =
        'https://apiuniviaje-production.up.railway.app/api/brevetcreate/$id';
    print(ci);

    try {
      final response = await http.post(Uri.parse(url));
      print(response.body.toString());
      if (response.statusCode == 200) {
        // El vehículo se creó correctamente
        print('Brevet creado correctamente');
        // notifyListeners();
      } else {
        print('Error en la solicitud: ${response.statusCode} createBrevet');
      }
    } catch (e) {
      print('Excepción durante la solicitud createBrevet: $e');
    }
  }

  Future<bool> hasDuplicateBrevets() async {
    final url = 'https://apiuniviaje-production.up.railway.app/api/brevet/$id';
    print('hasduplicadebrevets id: $id');
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final userList = jsonDecode(response.body) as List<dynamic>;
        final filteredList =
            userList.where((userData) => userData['id'] == id).toList();
        return filteredList.length > 0;
      } else {
        print(
            'Error en la solicitud: ${response.statusCode} hasduplicadebrevets');
      }
    } catch (e) {
      print('Excepción durante la solicitud hasDuplicateBrevets: $e');
    }

    return false; // Si hay algún error en la solicitud, se asume que no hay duplicados
  }
  // late BrevetModel BrevetModel;

  final unfocusNode = FocusNode();
  bool isDataUploading = false;
  FFUploadedFile uploadedLocalFile =
      FFUploadedFile(bytes: Uint8List.fromList([]));

  final ciController = TextEditingController();
  final nombreController = TextEditingController();
  final catlicenciaController = TextEditingController();
  final fecexpedicionController = TextEditingController();
  final fecvencimientoController = TextEditingController();

  TextEditingController? textController4;

  void dispose() {
    // nroplacaController.dispose();
    // modeloController.dispose();
    // anioController.dispose();
    // capacidadController.dispose();
    // fotovehiculoController.dispose();
    // caracteristicasespecialesController.dispose();
    textController4?.dispose();
  }
}
