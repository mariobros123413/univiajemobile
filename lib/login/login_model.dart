// ignore_for_file: unused_import

import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';
import '../../main.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginModel {
  int nroregistro;
  String password;

  LoginModel({required this.nroregistro, required this.password});

  TextEditingController nroRegistroController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void dispose() {
    nroRegistroController.dispose();
    passwordController.dispose();
  }

  /// Additional helper methods are added here.
}
