import 'package:flutter/material.dart';
import 'menu.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../globals.dart'; // Importar las variables globales
import 'package:url_launcher/url_launcher.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  SearchState createState() => SearchState();
}

class SearchState extends State<Search> {
  List<dynamic> invoices = [];
  bool _isLoading = false; // Indicador de carga

  @override
  void initState() {
    super.initState();
    fetchInvoices();
  }

  Future<void> fetchInvoices() async {
    final url = 'https://www.emicardigital.com.ar/recibodigital/api/recibos';
    final token_ = '$token';

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'token': token_}),
      );

      if (response.statusCode == 200) {
        setState(() {
          invoices = jsonDecode(response.body);
          final control = invoices[0];
          if (control['Count'] == 0) {
            _showMessage('No hay recibos para consultar');
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

  Future<void> firmarPDF(String id) async {
    final url = 'https://www.emicardigital.com.ar/recibodigital/api/firma';
    final token_ = '$token';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'Id': id, 'Token': token_}),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData['Success'] == true) {
          final downloadUrl = responseData['URL'];
          if (await canLaunchUrl(Uri.parse(downloadUrl))) {
            await launchUrl(Uri.parse(downloadUrl),
                mode: LaunchMode.externalApplication);
            _showMessage('Firmando Recibo N°: $id');
          } else {
            _showMessage('No se pudo descargar el archivo');
          }
        } else {
          _showMessage('Error: ${responseData['URL']}');
        }
      } else {
        _showMessage('Error: ${responseData['URL']}');
      }
    } catch (e) {
      _showMessage('Error al realizar la solicitud: $e');
    }
  }

  Future<void> descargarPDF(String id) async {
    final url = 'https://www.emicardigital.com.ar/recibodigital/api/descarga';
    final token_ = '$token';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'Id': id, 'Token': token_}),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData['Success'] == true) {
          final downloadUrl = responseData['URL'];
          if (await canLaunchUrl(Uri.parse(downloadUrl))) {
            await launchUrl(Uri.parse(downloadUrl),
                mode: LaunchMode.externalApplication);
            _showMessage('Descargando Recibo N°: $id');
          } else {
            _showMessage('No se pudo descargar el archivo');
          }
        } else {
          _showMessage('No se encontró el archivo');
        }
      } else {
        _showMessage('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Error al realizar la solicitud: $e');
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
        title: Text("Recibos Digitales", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false, // Elimina la flecha de regreso
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo de la empresa
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
                              'No hay recibos disponibles')) // Mensaje si no hay datos
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
                                        'images/icono_pdf.png',
                                        width: 50,
                                        height: 50,
                                      ),
                                      title: Text(
                                        'Período: ${invoice['Periodo'] ?? 'N/A'}  ${invoice['SAC'] == '' ? '' : ' - Liquidación: ${invoice['SAC']}'}',
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'N° Recibo: ${invoice['Id'] ?? 'N/A'} - Fecha: ${formatFechaRecibo(invoice['Fecha_Recibo'] ?? 'N/A')}'),
                                          Text(
                                              'Estado: ${invoice['Estado_Firma'] == 1 ? 'Firmado' : 'Pendiente de Firma'}'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            8.0), // Espacio entre el contenido y los botones
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            // Acción para el botón "Visualizar"
                                            final id = invoice['Id'].toString();
                                            descargarPDF(id);
                                          },
                                          child: const Text('Visualizar'),
                                        ),
                                        const SizedBox(
                                            width:
                                                16.0), // Espacio entre los botones
                                        ElevatedButton(
                                          onPressed: () {
                                            // Acción para el botón "Firmar"
                                            final id = invoice['Id'].toString();
                                            firmarPDF(id);
                                          },
                                          child:
                                              const Text('Firmar y Descargar'),
                                        ),
                                      ],
                                    ),
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
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
