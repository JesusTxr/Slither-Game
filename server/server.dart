import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';

// Clase para representar un jugador
class Player {
  final String id;
  final WebSocketChannel channel;
  double x;
  double y;
  double directionX;
  double directionY;
  int bodyLength;
  int score;
  String? nickname;
  String? roomCode;  // Sala a la que pertenece
  bool isReady;      // Si está listo en el lobby
  
  Player({
    required this.id,
    required this.channel,
    this.x = 0,
    this.y = 0,
    this.directionX = 1,
    this.directionY = 0,
    this.bodyLength = 5,
    this.score = 0,
    this.nickname,
    this.roomCode,
    this.isReady = false,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'x': x,
    'y': y,
    'directionX': directionX,
    'directionY': directionY,
    'bodyLength': bodyLength,
    'score': score,
    'nickname': nickname ?? 'Player',
    'isReady': isReady,
  };
}

// Clase para representar una sala
class GameRoom {
  final String code;
  String hostId; // No final para poder cambiar el host si se desconecta
  final List<String> playerIds;
  bool isStarted;
  final Map<String, Food> foods;
  final DateTime createdAt;
  final Set<String> playersInGame; // Jugadores que ya se conectaron al juego
  int expectedPlayers; // Cuántos jugadores se esperan en el juego
  DateTime? gameStartTime; // Cuando comenzó el juego
  Timer? gameTimer; // Timer del juego
  bool isGameEnded; // Si el juego terminó
  static const int gameDurationSeconds = 300; // 5 minutos
  
  GameRoom({
    required this.code,
    required this.hostId,
    List<String>? playerIds,
    this.isStarted = false,
    Map<String, Food>? foods,
    DateTime? createdAt,
    Set<String>? playersInGame,
    this.expectedPlayers = 0,
    this.gameStartTime,
    this.gameTimer,
    this.isGameEnded = false,
  }) : playerIds = playerIds ?? [hostId],
       foods = foods ?? {},
       createdAt = createdAt ?? DateTime.now(),
       playersInGame = playersInGame ?? {};
       
  int get remainingSeconds {
    if (gameStartTime == null || isGameEnded) return 0;
    final elapsed = DateTime.now().difference(gameStartTime!).inSeconds;
    final remaining = gameDurationSeconds - elapsed;
    return remaining > 0 ? remaining : 0;
  }
}

// Clase para representar comida
class Food {
  final String id;
  final double x;
  final double y;
  final int color;
  
  Food({
    required this.id,
    required this.x,
    required this.y,
    required this.color,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'x': x,
    'y': y,
    'color': color,
  };
}

class SlitherServer {
  final Map<String, Player> players = {};
  final Map<String, GameRoom> rooms = {};  // Salas de juego
  final uuid = Uuid();
  final double worldWidth = 6000;
  final double worldHeight = 6000;
  final int maxFoodPerRoom = 2000;
  
  void start() async {
    // Configurar el handler de WebSocket
    var handler = webSocketHandler((WebSocketChannel webSocket) {
      print('Nueva conexión establecida');
      handleConnection(webSocket);
    });
    
    // Obtener puerto de la variable de entorno (para Render) o usar 8080 por defecto
    final portEnv = Platform.environment['PORT'];
    final port = portEnv != null ? int.parse(portEnv) : 8080;
    
    // Iniciar el servidor
    var server = await io.serve(handler, '0.0.0.0', port);
    print('🚀 Servidor escuchando en ws://${server.address.host}:${server.port}');
    print('✅ Sistema de salas activado');
    print('📡 Puerto: $port ${portEnv != null ? "(desde PORT env)" : "(por defecto)"}');
    
    // Timer para regenerar comida en cada sala
    Timer.periodic(Duration(seconds: 2), (timer) {
      regenerateFood();
    });
    
    // Timer para limpiar salas vacías
    Timer.periodic(Duration(minutes: 5), (timer) {
      cleanEmptyRooms();
    });
  }
  
  void handleConnection(WebSocketChannel webSocket) {
    var playerId = uuid.v4();
    var random = Random();
    
    // Crear nuevo jugador (sin sala inicialmente)
    var player = Player(
      id: playerId,
      channel: webSocket,
      x: 1500 + random.nextDouble() * 3000,
      y: 1500 + random.nextDouble() * 3000,
    );
    players[playerId] = player;
    
    print('🎮 Jugador conectado: $playerId (Total: ${players.length})');
    
    // Escuchar mensajes del cliente
    webSocket.stream.listen(
      (message) {
        handleMessage(playerId, message);
      },
      onDone: () {
        handleDisconnection(playerId);
      },
      onError: (error) {
        print('Error en conexión $playerId: $error');
        handleDisconnection(playerId);
      },
    );
  }
  
  void handleMessage(String playerId, dynamic message) {
    try {
      var data = jsonDecode(message);
      var player = players[playerId];
      if (player == null) return;
      
      switch (data['type']) {
        case 'joinRoom':
          handleJoinRoom(playerId, data['roomCode']);
          break;
          
        case 'createRoom':
          handleCreateRoom(playerId, data['roomCode']);
          break;
          
        case 'playerReady':
          handlePlayerReady(playerId, data['isReady']);
          break;
          
        case 'startGame':
          handleStartGame(data['roomCode']);
          break;
          
        case 'move':
          player.x = data['x'];
          player.y = data['y'];
          player.directionX = data['directionX'];
          player.directionY = data['directionY'];
          broadcastToRoom(player.roomCode, {
            'type': 'playerMove',
            'playerId': playerId,
            'x': player.x,
            'y': player.y,
            'directionX': player.directionX,
            'directionY': player.directionY,
          }, exclude: playerId);
          break;
          
        case 'eat':
          handleFoodEaten(playerId, data);
          break;
          
        case 'nickname':
          player.nickname = data['nickname'];
          broadcastPlayerUpdate(player);
          break;
          
        case 'playerDeath':
          handlePlayerDeath(playerId);
          break;
          
        case 'playerRespawn':
          handlePlayerRespawn(playerId, data);
          break;
      }
    } catch (e) {
      print('Error procesando mensaje: $e');
    }
  }
  
  void handleJoinRoom(String playerId, String roomCode) {
    var player = players[playerId];
    if (player == null) return;
    
    // Buscar o crear la sala
    var room = rooms[roomCode];
    if (room == null) {
      // Crear nueva sala si no existe
      room = GameRoom(
        code: roomCode,
        hostId: playerId,
      );
      rooms[roomCode] = room;
      generateFoodForRoom(roomCode);
      print('🏠 Sala creada: $roomCode por $playerId');
    } else {
      // Unirse a sala existente
      if (!room.playerIds.contains(playerId)) {
        room.playerIds.add(playerId);
        print('🚪 Jugador $playerId se unió a sala $roomCode');
      }
    }
    
    player.roomCode = roomCode;
    
    // Enviar estado inicial al jugador
    sendInitToPlayer(player, room);
    
    // Notificar a otros en la sala
    broadcastToRoom(roomCode, {
      'type': 'playerJoined',
      'player': player.toJson(),
    }, exclude: playerId);
  }
  
  void handleCreateRoom(String playerId, String roomCode) {
    // Igual que join pero marca como host
    handleJoinRoom(playerId, roomCode);
  }
  
  void handlePlayerReady(String playerId, bool isReady) {
    var player = players[playerId];
    if (player == null) return;
    
    player.isReady = isReady;
    
    // Notificar a todos en la sala con el objeto completo del jugador
    // Esto asegura que el nickname y otros datos se envíen correctamente
    broadcastPlayerUpdate(player);
  }
  
  void handleStartGame(String roomCode) {
    var room = rooms[roomCode];
    if (room == null) return;
    
    room.isStarted = true;
    // Establecer cuántos jugadores se esperan (los que están en el lobby)
    room.expectedPlayers = room.playerIds.length;
    room.playersInGame.clear();  // Limpiar lista de jugadores en el juego
    print('🎮 Juego iniciado en sala $roomCode');
    print('👥 Esperando ${room.expectedPlayers} jugadores en el juego');
    
    // Obtener toda la comida de la sala
    var roomFoods = room.foods.values.map((f) => f.toJson()).toList();
    
    // Notificar a todos en la sala con la comida sincronizada
    broadcastToRoom(roomCode, {
      'type': 'gameStart',
      'roomCode': roomCode,
      'foods': roomFoods,  // 🔑 Enviar comida sincronizada a todos
    });
    
    print('🍎 Enviadas ${roomFoods.length} comidas a todos los jugadores en sala $roomCode');
  }
  
  void sendInitToPlayer(Player player, GameRoom room) {
    // Obtener jugadores de la sala
    var roomPlayers = players.values
        .where((p) => p.roomCode == room.code)
        .map((p) => p.toJson())
        .toList();
    
    // Obtener comida de la sala
    var roomFoods = room.foods.values.map((f) => f.toJson()).toList();
    
    player.channel.sink.add(jsonEncode({
      'type': 'init',
      'playerId': player.id,
      'x': player.x,
      'y': player.y,
      'roomCode': room.code,
      'hostId': room.hostId,  // 🔑 IMPORTANTE: ID del host
      'players': roomPlayers,
      'foods': roomFoods,
      'gameStarted': room.isStarted,  // 🔑 Indicar si el juego ya comenzó
    }));
    
    // Si el juego ya comenzó, trackear que este jugador se conectó
    if (room.isStarted) {
      room.playersInGame.add(player.id);
      print('👤 Jugador ${player.id} conectado al juego (${room.playersInGame.length}/${room.expectedPlayers})');
      
      // Verificar si todos los jugadores están conectados
      checkAllPlayersReady(room);
    }
  }
  
  void checkAllPlayersReady(GameRoom room) {
    if (room.playersInGame.length >= room.expectedPlayers && room.expectedPlayers > 0) {
      print('✅ Todos los jugadores conectados en sala ${room.code}. ¡Comenzando juego!');
      
      // Iniciar el temporizador del juego
      startGameTimer(room);
      
      // Notificar a todos que pueden comenzar
      broadcastToRoom(room.code, {
        'type': 'allPlayersReady',
        'remainingSeconds': room.remainingSeconds,
      });
    }
  }
  
  void startGameTimer(GameRoom room) {
    if (room.gameStartTime != null) return; // Ya iniciado
    
    room.gameStartTime = DateTime.now();
    print('⏱️ Temporizador iniciado para sala ${room.code}: ${GameRoom.gameDurationSeconds} segundos');
    
    // Timer que envía actualizaciones cada segundo
    room.gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (room.isGameEnded) {
        timer.cancel();
        return;
      }
      
      final remaining = room.remainingSeconds;
      
      // Enviar actualización de tiempo y ranking
      sendRankingUpdate(room);
      
      // Si el tiempo terminó, finalizar el juego
      if (remaining <= 0) {
        timer.cancel();
        endGame(room);
      }
    });
  }
  
  void sendRankingUpdate(GameRoom room) {
    // Obtener ranking de jugadores
    final ranking = getRanking(room);
    
    broadcastToRoom(room.code, {
      'type': 'rankingUpdate',
      'remainingSeconds': room.remainingSeconds,
      'ranking': ranking,
    });
  }
  
  List<Map<String, dynamic>> getRanking(GameRoom room) {
    // Obtener todos los jugadores de la sala y ordenarlos por score
    final roomPlayers = players.values
        .where((p) => p.roomCode == room.code)
        .toList();
    
    roomPlayers.sort((a, b) => b.score.compareTo(a.score));
    
    return roomPlayers.map((p) => {
      'playerId': p.id,
      'nickname': p.nickname ?? 'Player',
      'score': p.score,
    }).toList();
  }
  
  void endGame(GameRoom room) {
    if (room.isGameEnded) return;
    
    room.isGameEnded = true;
    room.gameTimer?.cancel();
    
    print('🏁 Juego terminado en sala ${room.code}');
    
    // Obtener ranking final
    final ranking = getRanking(room);
    final winner = ranking.isNotEmpty ? ranking[0] : null;
    
    print('🏆 Ganador: ${winner?['nickname']} con ${winner?['score']} puntos');
    
    // Notificar a todos los jugadores
    broadcastToRoom(room.code, {
      'type': 'gameEnd',
      'ranking': ranking,
      'winner': winner,
    });
  }
  
  void handleFoodEaten(String playerId, Map<String, dynamic> data) {
    var player = players[playerId];
    if (player == null || player.roomCode == null) return;
    
    var room = rooms[player.roomCode];
    if (room == null) return;
    
    var foodId = data['foodId'];
    if (room.foods.containsKey(foodId)) {
      room.foods.remove(foodId);
      player.score = data['score'];
      player.bodyLength = data['bodyLength'];
      
      // Notificar a todos en la sala
      broadcastToRoom(player.roomCode!, {
        'type': 'foodEaten',
        'foodId': foodId,
        'playerId': playerId,
        'score': player.score,
        'bodyLength': player.bodyLength,
      });
    }
  }
  
  void handleDisconnection(String playerId) {
    var player = players.remove(playerId);
    if (player != null) {
      print('👋 Jugador desconectado: $playerId (Total: ${players.length})');
      
      // Remover de la sala
      if (player.roomCode != null) {
        var room = rooms[player.roomCode];
        if (room != null) {
          room.playerIds.remove(playerId);
          
          // Notificar a otros en la sala
          broadcastToRoom(player.roomCode!, {
            'type': 'playerLeft',
            'playerId': playerId,
          });
          
          // Si era el host y quedan jugadores, asignar nuevo host
          if (room.hostId == playerId && room.playerIds.isNotEmpty) {
            room.hostId = room.playerIds.first;
            print('👑 Nuevo host en sala ${room.code}: ${room.hostId}');
          }
        }
      }
    }
  }
  
  void generateFoodForRoom(String roomCode) {
    var room = rooms[roomCode];
    if (room == null) return;
    
    var random = Random();
    for (int i = 0; i < 1500; i++) {
      var food = Food(
        id: uuid.v4(),
        x: random.nextDouble() * worldWidth,
        y: random.nextDouble() * worldHeight,
        color: (255 << 24) | 
               (random.nextInt(256) << 16) | 
               (random.nextInt(256) << 8) | 
               random.nextInt(256),
      );
      room.foods[food.id] = food;
    }
    print('🍎 Generadas ${room.foods.length} comidas para sala $roomCode');
  }
  
  void regenerateFood() {
    for (var room in rooms.values) {
      if (room.foods.length < maxFoodPerRoom && room.isStarted) {
        var random = Random();
        int toGenerate = min(10, maxFoodPerRoom - room.foods.length);
        
        for (int i = 0; i < toGenerate; i++) {
          var food = Food(
            id: uuid.v4(),
            x: random.nextDouble() * worldWidth,
            y: random.nextDouble() * worldHeight,
            color: (255 << 24) | 
                   (random.nextInt(256) << 16) | 
                   (random.nextInt(256) << 8) | 
                   random.nextInt(256),
          );
          room.foods[food.id] = food;
        }
        
        if (toGenerate > 0) {
          broadcastToRoom(room.code, {
            'type': 'foodUpdate',
            'foods': room.foods.values.map((f) => f.toJson()).toList(),
          });
        }
      }
    }
  }
  
  void cleanEmptyRooms() {
    var toRemove = <String>[];
    for (var entry in rooms.entries) {
      if (entry.value.playerIds.isEmpty) {
        toRemove.add(entry.key);
      }
    }
    
    for (var code in toRemove) {
      final room = rooms.remove(code);
      room?.gameTimer?.cancel(); // Cancelar timer si existe
      print('🧹 Sala vacía eliminada: $code');
    }
  }
  
  void broadcastToRoom(String? roomCode, Map<String, dynamic> data, {String? exclude}) {
    if (roomCode == null) return;
    
    var message = jsonEncode(data);
    var room = rooms[roomCode];
    if (room == null) return;
    
    for (var playerId in room.playerIds) {
      if (exclude != null && playerId == exclude) continue;
      
      var player = players[playerId];
      if (player != null) {
        try {
          player.channel.sink.add(message);
        } catch (e) {
          print('Error enviando a $playerId: $e');
        }
      }
    }
  }
  
  void handlePlayerDeath(String playerId) {
    var player = players[playerId];
    if (player == null || player.roomCode == null) return;
    
    print('💀 Jugador $playerId murió en sala ${player.roomCode}');
    
    // Notificar a todos los demás jugadores en la sala
    broadcastToRoom(player.roomCode!, {
      'type': 'playerDied',
      'playerId': playerId,
    });
    
    // Nota: NO desconectamos al jugador, solo notificamos su muerte
    // El cliente manejará la lógica de game over
  }
  
  void handlePlayerRespawn(String playerId, Map<String, dynamic> data) {
    var player = players[playerId];
    if (player == null || player.roomCode == null) return;
    
    // Actualizar posición del jugador
    player.x = data['x'];
    player.y = data['y'];
    player.score = 0;  // Reiniciar puntuación
    
    print('🔄 Jugador $playerId reapareció en sala ${player.roomCode} en (${player.x.toInt()}, ${player.y.toInt()})');
    
    // Notificar a todos los jugadores en la sala (incluyendo al que reaparece)
    broadcastToRoom(player.roomCode!, {
      'type': 'playerRespawn',
      'playerId': playerId,
      'x': player.x,
      'y': player.y,
      'score': player.score,
      'nickname': player.nickname,
    });
  }
  
  void broadcastPlayerUpdate(Player player) {
    if (player.roomCode != null) {
      broadcastToRoom(player.roomCode!, {
        'type': 'playerUpdate',
        'player': player.toJson(),
      });
    }
  }
}

void main() {
  var server = SlitherServer();
  server.start();
}
