import 'package:flutter/material.dart';
import 'menu.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../globals.dart'; // Importar las variables globales

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  NotificationsState createState() => NotificationsState();
}

class NotificationsState extends State<Notifications> {
  List<dynamic> invoices = [];
  bool _isLoading = false; // Indicador de carga

  @override
  void initState() {
    super.initState();
    fetchInvoices();
  }

  Future<void> fetchInvoices() async {
    final url =
        'https://www.emicardigital.com.ar/recibodigital/api/notificaciones';
    final token_ = '$token';
    final propietario_ = '$propietario';

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'Propietario': propietario_.replaceFirst("Propietario_", ""),
          'Token': token_
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          invoices = jsonDecode(response.body);
          final control = invoices[0];
          if (control['Count'] == 0) {
            _showMessage('No hay notificaciones');
            invoices = [];
            setState(() {
              _isLoading = false;
            });
          }
        });
      } else {
        // Manejar errores
        _showMessage('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Manejar excepciones
      _showMessage('Exception: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alertas", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false, // Elimina la flecha de regreso
      ),
      body: Padding(
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
            const SizedBox(height: 1.0), // Espacio entre el label y el ListView
            Expanded(
              child: _isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator()) // Se muestra mientras carga
                  : invoices.isEmpty
                      ? Center(
                          child: Text(
                              'No hay notificaciones')) // Mensaje si no hay datos
                      : ListView.builder(
                          itemCount: invoices.length,
                          itemBuilder: (context, index) {
                            final invoice = invoices[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      leading: Image.asset(
                                        'images/icono_notificacion.png',
                                        width: 50,
                                        height: 50,
                                      ),
                                      title: Text(
                                        '${invoice['Titulo'] ?? 'N/A'}',
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              '${invoice['Mensaje'] ?? 'N/A'}'),
                                          Text(
                                              'Fecha: ${formatFechaRecibo(invoice['Fecha'] ?? 'N/A')}'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            8.0), // Espacio entre el contenido y los botones
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
