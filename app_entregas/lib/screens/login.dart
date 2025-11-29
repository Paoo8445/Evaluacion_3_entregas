import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para leer el correo y contraseña
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool cargando = false; // Para mostrar el círculo de carga


  Future<void> hacerLogin() async {
    setState(() {
      cargando = true;
    });


    final url = Uri.parse("http://localhost:8000/login");

    final body = jsonEncode({
      "email": emailCtrl.text,
      "password": passCtrl.text,
    });

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    setState(() {
      cargando = false;
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      int idAgente = data["id_agente"];
      String nombre = data["nombre"];

      // Navegar a la pantalla de paquetes
      Navigator.pushNamed(
        context,
        "/paquetes",
        arguments: {
          "id": idAgente,
          "nombre": nombre
        }
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Credenciales incorrectas")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Iniciar Sesión")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CAMPO EMAIL
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: "Correo electrónico",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // CAMPO CONTRASEÑA
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),

            // BOTÓN LOGIN
            cargando
                ? CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: hacerLogin,
                      child: Text("Entrar"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
