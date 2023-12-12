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

class ProfileModel extends ChangeNotifier {
  int? id;
  int? nroregistro;
  String? password;
  String? correo;
  String? nombre;
  int? celular;
  String? fotoperfil;
  String? carrera;
  String? horarioclases;
  String? preferenciasviaje;
  bool isDataLoaded = false;
  String? imageUrl;

  @override
  ProfileModel(
      {this.id,
      this.nroregistro,
      this.password,
      this.correo,
      this.nombre,
      this.celular,
      this.fotoperfil,
      this.carrera,
      this.horarioclases,
      this.preferenciasviaje});

  Future<void> fetchProfileData(BuildContext context) async {
    print('fetchprofile before: $nroregistro');
    final url =
        'https://apiuniviaje-production.up.railway.app/api/usuario/$nroregistro';
    try {
      final response = await http.get(Uri.parse(url));
      print(response.body.toString());
      if (response.statusCode == 200) {
        final userList = jsonDecode(response.body) as List<dynamic>;
        print(userList.toString());
        if (userList.isNotEmpty) {
          final userData = userList[0] as Map<String, dynamic>;
          id = userData['id'];
          nroregistro = int.parse(userData['nroregistro']);
          password = userData['password'];
          correo = userData['correo'];
          nombre = userData['nombre'];
          celular = userData['celular'];
          fotoperfil = userData['fotoperfil'];
          carrera = userData['carrera'];
          horarioclases = userData['horarioclases'];
          preferenciasviaje = userData['preferenciasviaje'];
          isDataLoaded = true;
          //mostrar los datos en el body
          if (fotoperfil != null && fotoperfil!.isNotEmpty) {
            // Cargar la imagen desde la API si la variable foto no está vacía
            final imageBytes = await base64.decode(fotoperfil!);

            // Cargar la imagen decodificada utilizando Image.memory
            uploadedLocalFile = await FFUploadedFile(bytes: imageBytes);
          } else {
            // La variable foto es null o está vacía, asignar una imagen de internet
            final placeholderUrl =
                'https://images.unsplash.com/photo-1531123414780-f74242c2b052?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NDV8fHByb2ZpbGV8ZW58MHx8MHx8&auto=format&fit=crop&w=900&q=60';
            final placeholderResponse =
                await http.get(Uri.parse(placeholderUrl));
            if (placeholderResponse.statusCode == 200) {
              // Decodificar los bytes de la imagen de internet
              final placeholderBytes = await placeholderResponse.bodyBytes;

              // Cargar la imagen de internet utilizando Image.memory
              uploadedLocalFile = await FFUploadedFile(bytes: placeholderBytes);
            }
          }

          print('object fetchprofiledata: $id');

          idController.text = id.toString();
          nroregistroController.text = nroregistro.toString();
          passwordController.text = password ?? '';
          correoController.text = correo ?? '';
          nombreController.text = nombre ?? '';
          celularController.text = celular.toString();
          carreraController.text = carrera ?? '';
          horarioclasesController.text = horarioclases ?? '';
          preferenciasviajeController.text = preferenciasviaje ?? '';
          print(nroregistroController.text.toString());
          print('Perfil data fetched successfully. ID: $id');

          // notifyListeners();
        } else {
          print('No se encontraron datos del usuario');
          // if (hasDuplicateBrevets() != true) {
          //   createUsuario();
          // }
        }
      } else {
        print('Error en la solicitud: ${response.statusCode} getUsuario');
      }
    } catch (e) {
      print('Excepción durante la solicitud getUsuario: $e');
    }
  }

// ...

  Future<void> updateUsuarioData() async {
    final url =
        'https://apiuniviaje-production.up.railway.app/api/usuario/$nroregistro';
    print(id);
    try {
      final body = {
        'id': idController.text,
        'nroregistro': nroregistroController.text,
        'password': passwordController.text,
        'correo': correoController.text,
        'nombre': nombreController.text,
        'celular': celularController.text,
        'fotoperfil': '',
        'carrera': carreraController.text,
        'horarioclases': horarioclasesController.text,
        'preferenciasviaje': preferenciasviajeController.text,
      };
      print('Body de la solicitud: $body');

      if (uploadedLocalFile!.bytes != null) {
        // Si hay una imagen cargada en el contenedor
        final encodedImage = await base64.encode(uploadedLocalFile.bytes!);
        body['fotoperfil'] = await encodedImage;
      }
      // print(body['foto']);
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200) {
        print('Datos del usuario actualizados');
        // notifyListeners();
      } else {
        print('Error en la solicitud: ${response.statusCode} updateUsuario');
      }
    } catch (e) {
      print('Excepción durante la solicitud updateUsuario: $e');
    }
  }

  Future<void> createUsuario() async {
    final url =
        'https://apiuniviaje-production.up.railway.app/api/brevetcreate/$nroregistro';
    print(nroregistro);

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

  // Future<bool> hasDuplicateBrevets() async {
  //   final url = 'https://apiuniviaje-production.up.railway.app/api/usuario/$id';

  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     print(response.body.toString());
  //     if (response.statusCode == 200) {
  //       final userList = jsonDecode(response.body) as List<dynamic>;
  //       final filteredList =
  //           userList.where((userData) => userData['id'] == id).toList();
  //       return filteredList.length > 1;
  //     } else {
  //       print('Error en la solicitud: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Excepción durante la solicitud hasDuplicateBrevets: $e');
  //   }

  //   return false; // Si hay algún error en la solicitud, se asume que no hay duplicados
  // }
  // late BrevetModel BrevetModel;

  final unfocusNode = FocusNode();
  bool isDataUploading = false;
  FFUploadedFile uploadedLocalFile =
      FFUploadedFile(bytes: Uint8List.fromList([]));

  final idController = TextEditingController();
  final nroregistroController = TextEditingController();
  final passwordController = TextEditingController();
  final correoController = TextEditingController();
  final nombreController = TextEditingController();
  final celularController = TextEditingController();
  final carreraController = TextEditingController();
  final horarioclasesController = TextEditingController();
  final preferenciasviajeController = TextEditingController();
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
