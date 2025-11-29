import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EntregaScreen extends StatefulWidget {
  @override
  State<EntregaScreen> createState() => _EntregaScreenState();
}

class _EntregaScreenState extends State<EntregaScreen> {
  late int idAgente;
  late String nombreAgente;
  late Map paquete;

  XFile? fotoTomada;
  Position? posicionActual;

  bool obteniendoUbicacion = false;
  bool enviando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    idAgente = args["id"];
    nombreAgente = args["nombre"];
    paquete = args["paquete"];
  }

 //ubi

  Future<bool> _verificarPermisosUbicacion() async {
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Activa la ubicación del dispositivo")),
      );
      return false;
    }

    LocationPermission permiso = await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permiso de ubicación denegado")),
        );
        return false;
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Permisos de ubicación denegados permanentemente")),
      );
      return false;
    }

    return true;
  }

  Future<void> obtenerUbicacion() async {
    setState(() {
      obteniendoUbicacion = true;
    });

    final ok = await _verificarPermisosUbicacion();
    if (!ok) {
      setState(() {
        obteniendoUbicacion = false;
      });
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        posicionActual = pos;
        obteniendoUbicacion = false;
      });
    } catch (e) {
      setState(() {
        obteniendoUbicacion = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al obtener ubicación: $e")),
      );
    }
  }

  //fotografia

  Future<void> tomarFoto() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? imagen = await picker.pickImage(source: ImageSource.camera);

      if (imagen != null) {
        setState(() {
          fotoTomada = imagen;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al tomar foto: $e")),
      );
    }
  }

  //enviar a api

  Future<void> confirmarEntrega() async {
  if (fotoTomada == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Primero toma una foto de evidencia")),
    );
    return;
  }

  if (posicionActual == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Primero obten la ubicación GPS")),
    );
    return;
  }

  setState(() {
    enviando = true;
  });

  try {
    final url = Uri.parse("http://localhost:8000/entregas");

    final request = http.MultipartRequest("POST", url);

    request.fields["id_paquete"] = paquete["id_paquete"].toString();
    request.fields["id_agente"] = idAgente.toString();
    request.fields["latitud"] = posicionActual!.latitude.toString();
    request.fields["longitud"] = posicionActual!.longitude.toString();

    if (kIsWeb) {
      // Para Flutter Web: leer los bytes directamente
      final bytes = await fotoTomada!.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          "foto",
          bytes,
          filename: "foto_${DateTime.now().millisecondsSinceEpoch}.jpg",
        ),
      );
    } else {
      // Para Android/iOS: usar fromPath
      request.files.add(
        await http.MultipartFile.fromPath("foto", fotoTomada!.path),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    setState(() {
      enviando = false;
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ ${data["mensaje"]}")),
      );

      // Volvemos a la lista de paquetes
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Error al registrar entrega (${response.statusCode})")),
      );
    }
  } catch (e) {
    setState(() {
      enviando = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error al enviar entrega: $e")),
    );
  }
}

 //vista
  @override
  Widget build(BuildContext context) {
    final lat = posicionActual?.latitude;
    final lng = posicionActual?.longitude;

    return Scaffold(
      appBar: AppBar(
        title: Text("Entrega ${paquete["codigo"]}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Agente: $nombreAgente (ID: $idAgente)",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Dirección de entrega:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              paquete["direccion"],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // BOTONES DE ACCIONES
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: obteniendoUbicacion ? null : obtenerUbicacion,
                    icon: const Icon(Icons.location_on),
                    label: Text(
                        obteniendoUbicacion ? "Obteniendo..." : "Obtener GPS"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: tomarFoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Tomar foto"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // MOSTRAR COORDENADAS
            if (posicionActual != null)
              Text(
                "Lat: ${lat!.toStringAsFixed(6)}, Lng: ${lng!.toStringAsFixed(6)}",
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),

            const SizedBox(height: 10),

            // MAPA
            SizedBox(
              height: 250,
              child: (posicionActual == null)
                  ? const Center(
                      child: Text(
                        "Aquí se mostrará el mapa cuando tengas la ubicación.",
                        textAlign: TextAlign.center,
                      ),
                    )
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(lat!, lng!),
                        initialZoom: 17.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.paquexpress.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(lat, lng),
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 20),

            // PREVIEW DE FOTO
            if (fotoTomada != null)
              Center(
                child: Column(
                  children: [
                    const Text(
                      "Foto de evidencia:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    kIsWeb
                        ? Image.network(
                            fotoTomada!.path,
                            height: 200,
                          )
                        : Image.file(
                            File(fotoTomada!.path),
                            height: 200,
                          ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // BOTÓN FINAL
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: enviando ? null : confirmarEntrega,
                child: Text(enviando ? "Enviando..." : "Confirmar entrega"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
