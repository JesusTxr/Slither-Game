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
  
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    playerId = null;
  }
}

