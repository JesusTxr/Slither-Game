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
    
    final game = SlitherGame(roomCode: roomCode);
    
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'GameOver': (context, game) => _buildGameOverOverlay(context, game as SlitherGame),
              'WaitingForPlayers': (context, game) => _buildWaitingOverlay(context),
              'GameEnd': (context, game) => _buildGameEndOverlay(context, game as SlitherGame),
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
          // Widget de ranking (solo en multijugador)
          if (isMultiplayer)
            Positioned(
              top: 80,
              left: 10,
              child: _RankingDisplay(game: game),
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
  
  Widget _buildGameEndOverlay(BuildContext context, SlitherGame game) {
    final ranking = game.ranking;
    final winner = ranking.isNotEmpty ? ranking[0] : null;
    final isPlayerWinner = winner != null && winner['playerId'] == game.networkService?.playerId;
    
    return Container(
      color: Colors.black87,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isPlayerWinner ? '🏆' : '🏁',
                  style: const TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 20),
                Text(
                  isPlayerWinner ? '¡GANASTE!' : '¡JUEGO TERMINADO!',
                  style: TextStyle(
                    color: isPlayerWinner ? const Color(0xFFFFD700) : Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                if (winner != null)
                  Text(
                    '🏆 Ganador: ${winner['nickname']}',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 30),
                const Text(
                  'RANKING FINAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ...ranking.asMap().entries.map((entry) {
                  final index = entry.key;
                  final player = entry.value;
                  final isCurrentPlayer = player['playerId'] == game.networkService?.playerId;
                  
                  String medal = '';
                  Color? bgColor;
                  if (index == 0) {
                    medal = '🥇';
                    bgColor = const Color(0xFFFFD700).withOpacity(0.2);
                  } else if (index == 1) {
                    medal = '🥈';
                    bgColor = const Color(0xFFC0C0C0).withOpacity(0.2);
                  } else if (index == 2) {
                    medal = '🥉';
                    bgColor = const Color(0xFFCD7F32).withOpacity(0.2);
                  }
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrentPlayer 
                        ? const Color(0xFF00ff88).withOpacity(0.2)
                        : bgColor ?? Colors.black45,
                      borderRadius: BorderRadius.circular(10),
                      border: isCurrentPlayer 
                        ? Border.all(color: const Color(0xFF00ff88), width: 2)
                        : null,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Text(
                            medal.isNotEmpty ? medal : '${index + 1}.',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            player['nickname'],
                            style: TextStyle(
                              color: isCurrentPlayer ? const Color(0xFF00ff88) : Colors.white,
                              fontSize: 20,
                              fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        Text(
                          '${player['score']} pts',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
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
        ),
      ),
    );
  }
}

// Widget para mostrar ranking en tiempo real
class _RankingDisplay extends StatefulWidget {
  final SlitherGame game;
  
  const _RankingDisplay({required this.game});
  
  @override
  State<_RankingDisplay> createState() => _RankingDisplayState();
}

class _RankingDisplayState extends State<_RankingDisplay> {
  @override
  void initState() {
    super.initState();
    // Actualizar cada segundo
    Future.delayed(const Duration(seconds: 1), _update);
  }
  
  void _update() {
    if (mounted) {
      setState(() {});
      Future.delayed(const Duration(seconds: 1), _update);
    }
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    final top3 = widget.game.ranking.take(3).toList();
    final remainingTime = widget.game.remainingSeconds;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF00ff88).withOpacity(0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Temporizador más compacto
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_outlined, color: Color(0xFF00ff88), size: 14),
              const SizedBox(width: 4),
              Text(
                _formatTime(remainingTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Línea separadora sutil
          Container(
            height: 1,
            width: 100,
            color: const Color(0xFF00ff88).withOpacity(0.3),
          ),
          const SizedBox(height: 6),
          // Top 3 compacto
          ...top3.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            final isCurrentPlayer = player['playerId'] == widget.game.networkService?.playerId;
            
            String medal = '';
            if (index == 0) medal = '🥇';
            else if (index == 1) medal = '🥈';
            else if (index == 2) medal = '🥉';
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    medal,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 80),
                    child: Text(
                      player['nickname'],
                      style: TextStyle(
                        color: isCurrentPlayer ? const Color(0xFF00ff88) : Colors.white,
                        fontSize: 11,
                        fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.w500,
                        shadows: isCurrentPlayer ? [
                          const Shadow(
                            color: Color(0xFF00ff88),
                            blurRadius: 4,
                          ),
                        ] : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${player['score']}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
