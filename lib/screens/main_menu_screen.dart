import 'package:flutter/material.dart';
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        // 'Stack' permite poner widgets uno encima de otro
        fit: StackFit.expand, // Para que el fondo ocupe todo
        children: [
          // ----------------------------------------------------
          // AQUI VA TU FONDO
          // (Puedes poner un Container con un color o una
          // Image.asset('tu_fondo_galactico.png') aquí)
          Container(color: Colors.black), // Fondo negro por ahora
          // ----------------------------------------------------
          
          // 2. Los botones, centrados
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Título
                const Text(
                  'SLITHER GAME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                
                // Botón Modo Solo
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/game', arguments: {'multiplayer': false});
                  },
                  child: const Text('Modo Solo', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20),
                
                // Botón Multijugador (va al menú de salas)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    backgroundColor: const Color(0xFF0088ff),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/multiplayer');
                  },
                  child: const Text('Multijugador', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 40),
                
                // Instrucciones
                const Text(
                  'Usa el joystick para moverte',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
