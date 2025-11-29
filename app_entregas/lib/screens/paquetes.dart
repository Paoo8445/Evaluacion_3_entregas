import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaquetesScreen extends StatefulWidget {
  @override
  State<PaquetesScreen> createState() => _PaquetesScreenState();
}

class _PaquetesScreenState extends State<PaquetesScreen> {
  late int idAgente;
  late String nom;
  bool cargando = true;
  List paquetes = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Recibimos el idAgente que mandó el login
    final args = ModalRoute.of(context)!.settings.arguments as Map;

    idAgente = args["id"];
    nom = args["nombre"];

    // Llama a la API
    cargarPaquetes();
  }

  Future<void> cargarPaquetes() async {
    setState(() {
      cargando = true;
    });

    final url = Uri.parse("http://localhost:8000/paquetes/$idAgente");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        paquetes = data;// lista que viene del backend
        cargando = false;
      });
    } else {
      setState(() {
        cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al obtener paquetes")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paquetes de $nom (ID: $idAgente)"),
      ),
      body: cargando
          ? Center(child: CircularProgressIndicator())
          : paquetes.isEmpty
              ? Center(
                  child: Text(
                    "No hay paquetes pendientes.",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: paquetes.length,
                  itemBuilder: (context, index) {
                    final paquete = paquetes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: SizedBox(
                        height: 80, // ⬅️ le damos más altura a la fila
                        child: ListTile(
                          // ya no es necesario isThreeLine, pero puedes dejarlo si quieres
                          title: Text(paquete["codigo"]),
                          subtitle: Text(paquete["direccion"]),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(paquete["estado"]),
                              const SizedBox(height: 4),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  minimumSize: const Size(0, 26), // más bajito para que quepa
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    "/entrega",
                                    arguments: {
                                      "id": idAgente,
                                      "nombre": nom,
                                      "paquete": paquete,
                                    },
                                  );
                                },
                                child: const Text("Entregar", style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
