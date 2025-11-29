import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/paquetes.dart';
import 'screens/entrega.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/login",
      routes: {
        "/login": (context) => LoginScreen(),
        "/paquetes": (context) => PaquetesScreen(),
        "/entrega": (context) => EntregaScreen(),
      },
    );
  }
}
