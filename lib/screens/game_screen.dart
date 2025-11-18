import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game.dart';
import '../config/game_config.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Obtener argumentos
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isMultiplayer = args?['multiplayer'] ?? false;
    final roomCode = args?['roomCode'] as String?;
    
    // Configurar modo de juego
    GameConfig.isMultiplayer = isMultiplayer;
    
    print('🎮 GameScreen - Multiplayer: $isMultiplayer, RoomCode: $roomCode');
    
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: SlitherGame(roomCode: roomCode),
            overlayBuilderMap: {
              'GameOver': (context, game) => _buildGameOverOverlay(context, game as SlitherGame),
              'WaitingForPlayers': (context, game) => _buildWaitingOverlay(context),
            },
          ),
          // Indicador de modo
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isMultiplayer ? '🌐 Multijugador' : '🎮 Modo Solo',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameOverOverlay(BuildContext context, SlitherGame game) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '💀',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 20),
            const Text(
              '¡HAS MUERTO!',
              style: TextStyle(
                color: Colors.red,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Puntuación: ${game.score}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00ff88),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Volver al Menú',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWaitingOverlay(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF00ff88),
              strokeWidth: 6,
            ),
            SizedBox(height: 30),
            Text(
              '⏳ Esperando jugadores...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Todos los jugadores deben conectarse',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
