import 'package:flutter/material.dart';
import '../globals.dart'; // Importar las variables globales
import 'menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'changepassword.dart'; // Importa la pantalla de cambio de contraseña

class UserDetails extends StatefulWidget {
  const UserDetails({super.key});

  @override
  UserDetailsState createState() => UserDetailsState();
}

class UserDetailsState extends State<UserDetails> {
  String? fotoUrl;

  @override
  void initState() {
    super.initState();
    _loadFotoUrl(); // Cargar la URL desde SharedPreferences
  }

  //Obtiene Datos
  Future<void> _loadFotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fotoUrl = prefs.getString('fotoURL') ?? ''; // Obtener fotoURL o vacío
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mis Datos", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading:
            false, // Elimina la flecha de regreso // Color de fondo del AppBar
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center, // Centrar horizontalmente
                child: Image.asset(
                  'images/logo.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(
                  height: 15.0), // Espacio entre el label y el ListView
              // Imagen circular
              Center(
                child: CircleAvatar(
                  radius: 50, // Tamaño del avatar
                  backgroundImage: (fotoUrl != null && fotoUrl!.isNotEmpty)
                      ? NetworkImage(fotoUrl!) // Si tiene URL, cargarla
                      : AssetImage('images/login.png')
                          as ImageProvider, // Si no, cargar el asset
                  backgroundColor:
                      Colors.grey[300], // Color de fondo si la imagen no carga
                ),
              ),
              SizedBox(height: 20), // Espaciado
              RichText(
                text: TextSpan(
                  text: "Nombre: ", // Label en estilo normal
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.black, // Color negro para el label
                  ),
                  children: [
                    TextSpan(
                      text: nombre, // Valor en azul claro
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.normal, // Mantiene el peso normal
                        color:
                            Colors.lightBlue, // Color azul claro para el valor
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: "Apellido: ", // Label en estilo normal
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.black, // Color negro para el label
                  ),
                  children: [
                    TextSpan(
                      text: apellido, // Valor en azul claro
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.normal, // Mantiene el peso normal
                        color:
                            Colors.lightBlue, // Color azul claro para el valor
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: "DNI: ", // Label en estilo normal
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.black, // Color negro para el label
                  ),
                  children: [
                    TextSpan(
                      text: dni, // Valor en azul claro
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.normal, // Mantiene el peso normal
                        color:
                            Colors.lightBlue, // Color azul claro para el valor
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: "Fecha Nacimiento: ", // Label en estilo normal
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.black, // Color negro para el label
                  ),
                  children: [
                    TextSpan(
                      text: fechanacimiento, // Valor en azul claro
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.normal, // Mantiene el peso normal
                        color:
                            Colors.lightBlue, // Color azul claro para el valor
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: "Dirección: ", // Label en estilo normal
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.black, // Color negro para el label
                  ),
                  children: [
                    TextSpan(
                      text: direccion, // Valor en azul claro
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.normal, // Mantiene el peso normal
                        color:
                            Colors.lightBlue, // Color azul claro para el valor
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: "Código Postal: ", // Label en estilo normal
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.black, // Color negro para el label
                  ),
                  children: [
                    TextSpan(
                      text: cp, // Valor en azul claro
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.normal, // Mantiene el peso normal
                        color:
                            Colors.lightBlue, // Color azul claro para el valor
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: "Teléfono: ", // Label en estilo normal
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.black, // Color negro para el label
                  ),
                  children: [
                    TextSpan(
                      text: telefono, // Valor en azul claro
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.normal, // Mantiene el peso normal
                        color:
                            Colors.lightBlue, // Color azul claro para el valor
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: "Email: ", // Label en estilo normal
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.black, // Color negro para el label
                  ),
                  children: [
                    TextSpan(
                      text: email, // Valor en azul claro
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.normal, // Mantiene el peso normal
                        color:
                            Colors.lightBlue, // Color azul claro para el valor
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: "Sexo: ", // Label en estilo normal
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.black, // Color negro para el label
                  ),
                  children: [
                    TextSpan(
                      text: (sexo == "M")
                          ? "Masculino"
                          : (sexo == "F")
                              ? "Femenino"
                              : "No especificado", // Conversión de M/F
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.normal, // Mantiene el peso normal
                        color:
                            Colors.lightBlue, // Color azul claro para el valor
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: "Empresa: ", // Label en estilo normal
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.black, // Color negro para el label
                  ),
                  children: [
                    TextSpan(
                      text: empresa, // Valor en azul claro
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.normal, // Mantiene el peso normal
                        color:
                            Colors.lightBlue, // Color azul claro para el valor
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: "CUIL: ", // Label en estilo normal
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.black, // Color negro para el label
                  ),
                  children: [
                    TextSpan(
                      text: cuil, // Valor en azul claro
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.normal, // Mantiene el peso normal
                        color:
                            Colors.lightBlue, // Color azul claro para el valor
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: "Legajo: ", // Label en estilo normal
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.black, // Color negro para el label
                  ),
                  children: [
                    TextSpan(
                      text: legajo, // Valor en azul claro
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.normal, // Mantiene el peso normal
                        color:
                            Colors.lightBlue, // Color azul claro para el valor
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              // Línea separadora horizontal
              Divider(
                thickness: 2, // Grosor de la línea
                color: Colors.grey, // Color de la línea
                indent: 5, // Margen izquierdo
                endIndent: 5, // Margen derecho
              ),
              SizedBox(height: 10),
              // Botón "Cambiar Contraseña"
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChangePassword()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Color de fondo rojo
                    foregroundColor: Colors.white, // Color del texto blanco
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          8), // Bordes redondeados opcionales
                    ),
                  ),
                  child: const Text("Cambiar Contraseña"),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
