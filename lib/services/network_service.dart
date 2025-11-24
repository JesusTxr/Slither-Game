import 'dart:async';
import 'dart:convert';
import 'package:flame/components.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NetworkService {
  WebSocketChannel? _channel;
  String? playerId;
  final String serverUrl;
  
  // Callbacks para eventos del servidor
  Function(Map<String, dynamic>)? onInit;
  Function(Map<String, dynamic>)? onPlayerJoined;
  Function(Map<String, dynamic>)? onPlayerLeft;
  Function(Map<String, dynamic>)? onPlayerMove;
  Function(Map<String, dynamic>)? onPlayerUpdate;
  Function(Map<String, dynamic>)? onFoodEaten;
  Function(Map<String, dynamic>)? onFoodUpdate;
  Function(Map<String, dynamic>)? onGameStart;  // 🎮 Nuevo callback para inicio de juego
  Function(Map<String, dynamic>)? onPlayerDied;  // 💀 Callback para muerte de jugador
  Function(Map<String, dynamic>)? onPlayerRespawn;  // 🔄 Callback para respawn de jugador
  Function(Map<String, dynamic>)? onAllPlayersReady;  // 👥 Callback cuando todos los jugadores están listos
  Function(Map<String, dynamic>)? onRankingUpdate;  // 🏆 Callback para actualizaciones de ranking
  Function(Map<String, dynamic>)? onGameEnd;  // 🏁 Callback para fin de juego
  Function(Map<String, dynamic>)? onPowerUpSpawned;  // 🎁 Callback para nuevo power-up
  Function(String)? onPowerUpCollected;  // 🎁 Callback cuando alguien recoge un power-up
  Function(Map<String, dynamic>)? onPlayerFrozen;  // ❄️ Callback cuando un jugador es congelado
  Function(Map<String, dynamic>)? onPlayerShrunk;  // 📏 Callback cuando un jugador es reducido
  Function(Map<String, dynamic>)? onBombExploded;  // 💣 Callback cuando explota una bomba
  Function(Map<String, dynamic>)? onDashUsed;  // 🎯 Callback cuando se usa Dash
  
  bool get isConnected => _channel != null;
  
  NetworkService({this.serverUrl = 'ws://localhost:8080'});
  
  Future<void> connect() async {
    try {
      print('Conectando al servidor: $serverUrl');
      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
      
      // Escuchar mensajes del servidor
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          print('Error en WebSocket: $error');
          disconnect();
        },
        onDone: () {
          print('Conexión cerrada');
          disconnect();
        },
      );
      
      print('Conectado al servidor');
    } catch (e) {
      print('Error conectando: $e');
      rethrow;
    }
  }
  
  void _handleMessage(dynamic message) {
    try {
      var data = jsonDecode(message);
      var type = data['type'];
      
      switch (type) {
        case 'init':
          playerId = data['playerId'];
          onInit?.call(data);
          break;
        case 'playerJoined':
          onPlayerJoined?.call(data);
          break;
        case 'playerLeft':
          onPlayerLeft?.call(data);
          break;
        case 'playerMove':
          onPlayerMove?.call(data);
          break;
        case 'playerUpdate':
          onPlayerUpdate?.call(data);
          break;
        case 'foodEaten':
          onFoodEaten?.call(data);
          break;
        case 'foodUpdate':
          onFoodUpdate?.call(data);
          break;
        case 'gameStart':
          print('🎮 Mensaje de inicio de juego recibido');
          onGameStart?.call(data);
          break;
        case 'playerDied':
          print('💀 Mensaje de muerte de jugador recibido');
          onPlayerDied?.call(data);
          break;
        case 'playerRespawn':
          print('🔄 Mensaje de respawn de jugador recibido');
          onPlayerRespawn?.call(data);
          break;
        case 'allPlayersReady':
          print('👥 Todos los jugadores están listos');
          onAllPlayersReady?.call(data);
          break;
        case 'rankingUpdate':
          onRankingUpdate?.call(data);
          break;
        case 'gameEnd':
          print('🏁 Juego terminado');
          onGameEnd?.call(data);
          break;
        case 'powerUpSpawned':
          print('🎁 Nuevo power-up spawneado');
          onPowerUpSpawned?.call(data);
          break;
        case 'powerUpCollected':
          print('🎁 Power-up recogido por ${data["playerId"]}');
          onPowerUpCollected?.call(data['powerUpId']);
          break;
        case 'playerFrozen':
          print('❄️ Jugador congelado: ${data["playerId"]}');
          onPlayerFrozen?.call(data);
          break;
        case 'playerShrunk':
          print('📏 Jugador reducido: ${data["playerId"]}');
          onPlayerShrunk?.call(data);
          break;
        case 'bombExploded':
          print('💣 Bomba explotada por ${data["playerId"]}');
          onBombExploded?.call(data);
          break;
        case 'dashUsed':
          print('🎯 Dash usado por ${data["playerId"]}');
          onDashUsed?.call(data);
          break;
        default:
          print('Tipo de mensaje desconocido: $type');
      }
    } catch (e) {
      print('Error procesando mensaje: $e');
    }
  }
  
  void sendMove(Vector2 position, Vector2 direction) {
    if (!isConnected) return;
    
    _channel!.sink.add(jsonEncode({
      'type': 'move',
      'x': position.x,
      'y': position.y,
      'directionX': direction.x,
      'directionY': direction.y,
    }));
  }
  
  void sendFoodEaten(String foodId, int score, int bodyLength) {
    if (!isConnected) return;
    
    _channel!.sink.add(jsonEncode({
      'type': 'eat',
      'foodId': foodId,
      'score': score,
      'bodyLength': bodyLength,
    }));
  }
  
  void sendNickname(String nickname) {
    if (!isConnected) return;
    
    _channel!.sink.add(jsonEncode({
      'type': 'nickname',
      'nickname': nickname,
    }));
  }
  
  void sendRoomCode(String roomCode) {
    if (!isConnected) return;
    
    _channel!.sink.add(jsonEncode({
      'type': 'joinRoom',
      'roomCode': roomCode,
    }));
  }
  
  void sendPlayerReady(bool isReady) {
    if (!isConnected) return;
    
    _channel!.sink.add(jsonEncode({
      'type': 'playerReady',
      'isReady': isReady,
    }));
  }
  
  void sendStartGame(String roomCode) {
    if (!isConnected) return;
    
    _channel!.sink.add(jsonEncode({
      'type': 'startGame',
      'roomCode': roomCode,
    }));
  }
  
  void sendPlayerDeath() {
    if (!isConnected) return;
    
    print('💀 Notificando al servidor sobre la muerte');
    _channel!.sink.add(jsonEncode({
      'type': 'playerDeath',
    }));
  }
  
  void sendPlayerRespawn(double x, double y) {
    if (!isConnected) return;
    
    print('🔄 Notificando al servidor sobre el respawn');
    _channel!.sink.add(jsonEncode({
      'type': 'playerRespawn',
      'x': x,
      'y': y,
    }));
  }
  
  // 🎁 Notificar al servidor cuando se recoge un power-up
  void sendPowerUpCollected(String powerUpId) {
    if (!isConnected) return;
    
    print('🎁 Notificando al servidor sobre recolección de power-up: $powerUpId');
    _channel!.sink.add(jsonEncode({
      'type': 'powerUpCollected',
      'powerUpId': powerUpId,
    }));
  }
  
  // ❄️ Notificar al servidor sobre el uso de Freeze
  void sendPowerUpFreeze(List<String> affectedPlayerIds) {
    if (!isConnected) return;
    
    print('❄️ Notificando al servidor sobre Freeze: ${affectedPlayerIds.length} jugadores afectados');
    _channel!.sink.add(jsonEncode({
      'type': 'powerUpFreeze',
      'affectedPlayers': affectedPlayerIds,
    }));
  }
  
  // 📏 Notificar al servidor sobre el uso de Shrink Ray
  void sendPowerUpShrinkRay(Map<String, int> affectedPlayers) {
    if (!isConnected) return;
    
    print('📏 Notificando al servidor sobre Shrink Ray: ${affectedPlayers.length} jugadores afectados');
    _channel!.sink.add(jsonEncode({
      'type': 'powerUpShrinkRay',
      'affectedPlayers': affectedPlayers,
    }));
  }
  
  // 💣 Notificar al servidor sobre el uso de Bomb
  void sendPowerUpBomb(Map<String, int> affectedPlayers) {
    if (!isConnected) return;
    
    print('💣 Notificando al servidor sobre Bomb: ${affectedPlayers.length} jugadores afectados');
    _channel!.sink.add(jsonEncode({
      'type': 'powerUpBomb',
      'affectedPlayers': affectedPlayers,
    }));
  }
  
  // 🎯 Notificar al servidor sobre el uso de Dash
  void sendPowerUpDash(double startX, double startY, double endX, double endY) {
    if (!isConnected) return;
    
    print('🎯 Notificando al servidor sobre Dash');
    _channel!.sink.add(jsonEncode({
      'type': 'powerUpDash',
      'startX': startX,
      'startY': startY,
      'endX': endX,
      'endY': endY,
    }));
  }
  
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    playerId = null;
  }
}

