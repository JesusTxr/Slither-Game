import 'dart:async';
import 'package:flutter/material.dart';
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}
class _LoadingScreenState extends State<LoadingScreen> {
  double _progress = 0.0; // Progreso de 0.0 a 1.0
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    _startLoading();
  }
  void _startLoading() {
    // Un timer que se ejecuta cada 30ms para simular la carga
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        _progress += 0.01; // Incrementa el progreso
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel(); // Detiene el timer
          // Navega al menú
          Navigator.pushReplacementNamed(context, '/menu');
        }
      });
    });
  }
  @override
  void dispose() {
    _timer.cancel(); // Asegúrate de cancelar el timer si la pantalla se destruye
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          // Añadimos padding horizontal para que la barra no toque los bordes
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. La barra de progreso
              LinearProgressIndicator(
                value: _progress, // El valor actual de la barra
                minHeight: 10,
                backgroundColor: Colors.grey[700],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
              ),
              const SizedBox(height: 20),
              
              // 2. El texto del porcentaje
              Text(
                'Cargando... ${(_progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}