library;

import 'package:intl/intl.dart';

String? id;
String? nombre;
String? apellido;
String? dni;
String? token;
String? propietario;
String? tokenfirebase;
String? fechanacimiento;
String? direccion;
String? cp;
String? telefono;
String? email;
String? sexo;
String? empresa;
String? cuil;
String? legajo;
int? idconversacion;

void resetGlobalVariables() {
  id = '';
  nombre = '';
  apellido = '';
  dni = '';
  token = '';
  propietario = '';
  tokenfirebase = '';
  fechanacimiento = '';
  direccion = '';
  cp = '';
  telefono = '';
  email = '';
  sexo = '';
  empresa = '';
  cuil = '';
  legajo = '';
  idconversacion = 0;
}

String formatFechaRecibo(String fecha) {
  try {
    // Parsear la fecha del formato recibido
    DateTime parsedDate = DateTime.parse(fecha);
    // Formatear la fecha al formato DD/MM/AAAA
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  } catch (e) {
    // Si ocurre un error, devolver un valor predeterminado
    return 'Fecha inválida';
  }
}
