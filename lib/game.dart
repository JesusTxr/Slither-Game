import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:slither_game/components/background.dart';
import 'package:slither_game/components/body_segment.dart';
import 'package:slither_game/components/food.dart';
import 'package:slither_game/components/joystick.dart';
import 'package:slither_game/components/player_head.dart';
import 'package:slither_game/components/remote_player.dart';
import 'package:slither_game/config/game_config.dart';
import 'package:slither_game/services/network_service.dart';

class SlitherGame extends FlameGame with PanDetector, HasCollisionDetection {
  final Vector2 worldSize = Vector2(6000, 6000); // Mapa más grande
  Vector2 targetDirection = Vector2(1, 0); // Empezar moviéndose a la derecha
  int score = 0; // Puntos acumulados
  int bodyLength = 5; // Longitud inicial del cuerpo
  final double baseRadius = 10;
  double get currentRadius => baseRadius + (bodyLength * 0.1);
  final List<BodySegment> body = [];
  PlayerHead? _playerHead;
  PlayerHead get playerHead => _playerHead!;
  set playerHead(PlayerHead value) => _playerHead = value;
  final int initialFoodCount = 1500; // Más comida inicial
  final int maxFoodCount = 2000; // Límite de comida en el mapa
  
  // Control de regeneración de comida
  double _foodSpawnTimer = 0;
  final double _foodSpawnInterval = 1.5; // Generar comida cada 1.5 segundos
  final int _foodPerSpawn = 10; // Cuántas comidas generar por vez

  // World y CameraComponent modernos
  late final World world;
  late final CameraComponent cameraComponent;
  VirtualJoystick? joystick;
  
  // Multijugador
  NetworkService? networkService;
  final Map<String, RemotePlayer> remotePlayers = {};
  double _networkUpdateTimer = 0;
  final double _networkUpdateInterval = 0.05; // Enviar actualización cada 50ms
  bool isMultiplayer = false;
  String? roomCode;  // 🔑 Código de sala para multijugador

  // Constructor
  SlitherGame({this.roomCode});

  @override
  Future<void> onLoad() async {
    // Verificar si es modo multijugador
    isMultiplayer = GameConfig.isMultiplayer;
    
    // 1. Crear el mundo
    world = World();
    await add(world);

    // 2. Fondo (detrás de todo)
    await world.add(Background()..priority = -1);

    // 3. Si es multijugador, conectar al servidor
    if (isMultiplayer) {
      await _initializeMultiplayer();
    }
    
    // Asegurarse de que el playerHead esté inicializado (fallback si el servidor falló)
    if (_playerHead == null) {
      final Vector2 worldCenter = worldSize / 2;
      playerHead = PlayerHead(startPosition: worldCenter);
      await world.add(playerHead);
      print('✅ PlayerHead inicializado en modo solo (fallback)');
    }

    // 4. Crear la cámara y configurarla para seguir al jugador
    cameraComponent = CameraComponent(world: world);
    cameraComponent.viewfinder.anchor = Anchor.center;
    cameraComponent.follow(playerHead);
    
    // 5. Configurar los límites del mundo de la cámara
    cameraComponent.setBounds(
      Rectangle.fromLTRB(0, 0, worldSize.x, worldSize.y),
    );
    
    await add(cameraComponent);

    // 6. Agregar el joystick virtual al viewport de la cámara
    joystick = VirtualJoystick(
      position: Vector2(100, 100), // Posición temporal, se ajustará en onGameResize
    );
    cameraComponent.viewport.add(joystick!);

    // 7. Comida (solo en modo solo o si el servidor falló)
    if (!isMultiplayer) {
      print('🍎 Generando ${initialFoodCount} orbes de comida...');
      for (int i = 0; i < initialFoodCount; i++) {
        spawnFood();
      }
      print('✅ Comida generada correctamente');
    } else {
      print('🌐 Modo multijugador: esperando comida del servidor...');
    }
  }
  
  Future<void> _initializeMultiplayer() async {
    print('🔄 Inicializando modo multijugador...');
    print('🌐 Intentando conectar a: ${GameConfig.serverUrl}');
    print('🔑 Código de sala: $roomCode');
    
    if (roomCode == null || roomCode!.isEmpty) {
      print('❌ Error: No hay código de sala para multijugador');
      return;
    }
    
    networkService = NetworkService(serverUrl: GameConfig.serverUrl);
    
    // Configurar callbacks
    networkService!.onInit = _handleServerInit;
    networkService!.onPlayerJoined = _handlePlayerJoined;
    networkService!.onPlayerLeft = _handlePlayerLeft;
    networkService!.onPlayerMove = _handlePlayerMove;
    networkService!.onFoodEaten = _handleFoodEaten;
    networkService!.onFoodUpdate = _handleFoodUpdate;
    networkService!.onPlayerDied = _handlePlayerDied;
    
    try {
      await networkService!.connect();
      print('✅ Conectado al servidor multijugador');
      
      // Enviar nickname (asegurar que no esté vacío)
      final nickname = GameConfig.playerNickname ?? 'Player';
      print('📤 Enviando nickname: $nickname');
      networkService!.sendNickname(nickname);
      
      // Pequeña espera para que el servidor procese el nickname
      await Future.delayed(Duration(milliseconds: 100));
      
      // Enviar código de sala para unirse
      print('📤 Enviando código de sala: $roomCode');
      networkService!.sendRoomCode(roomCode!);
      
      // Dar tiempo para que el servidor envíe el mensaje init
      await Future.delayed(Duration(milliseconds: 500));
      
      // Verificar si recibimos datos del servidor
      if (_playerHead == null) {
        print('⚠️ No se recibió respuesta del servidor');
        throw Exception('Servidor no respondió');
      }
    } catch (e) {
      print('❌ Error conectando al servidor: $e');
      print('📴 Cambiando a modo solo...');
      // Fallback a modo solo si no se puede conectar
      isMultiplayer = false;
      networkService?.disconnect();
      networkService = null;
    }
  }
  
  void _handleServerInit(Map<String, dynamic> data) {
    print('✅ Recibido init del servidor');
    // Crear jugador local en la posición del servidor
    final startPos = Vector2(data['x'], data['y']);
    playerHead = PlayerHead(startPosition: startPos);
    world.add(playerHead);
    print('🎮 Jugador creado en posición: $startPos');
    
    // Cargar jugadores existentes
    final players = data['players'] as List;
    print('👥 Jugadores existentes: ${players.length}');
    for (var playerData in players) {
      final playerId = playerData['id'];
      if (playerId != networkService!.playerId) {
        _addRemotePlayer(playerData);
      }
    }
    
    // Cargar comida del servidor
    final foods = data['foods'] as List;
    print('🍎 Comida recibida del servidor: ${foods.length} orbes');
    for (var foodData in foods) {
      _addServerFood(foodData);
    }
    print('✅ Comida agregada al mundo');
  }
  
  void _handlePlayerJoined(Map<String, dynamic> data) {
    print('Jugador unido: ${data['player']['id']}');
    _addRemotePlayer(data['player']);
  }
  
  void _handlePlayerLeft(Map<String, dynamic> data) {
    final playerId = data['playerId'];
    print('Jugador desconectado: $playerId');
    final player = remotePlayers.remove(playerId);
    player?.removeFromParent();
  }
  
  void _handlePlayerMove(Map<String, dynamic> data) {
    final playerId = data['playerId'];
    final player = remotePlayers[playerId];
    if (player != null) {
      player.updatePosition(Vector2(data['x'], data['y']));
    }
  }
  
  void _handleFoodEaten(Map<String, dynamic> data) {
    final foodId = data['foodId'];
    // Buscar y remover la comida
    final foods = world.children.whereType<Food>();
    for (var food in foods) {
      if (food.id == foodId) {
        food.removeFromParent();
        break;
      }
    }
    
    // Si el que comió fue otro jugador, actualizar su tamaño
    final playerId = data['playerId'];
    if (playerId != networkService!.playerId) {
      final player = remotePlayers[playerId];
      if (player != null) {
        player.score = data['score'];
        player.bodyLength = data['bodyLength'];
      }
    }
  }
  
  void _handleFoodUpdate(Map<String, dynamic> data) {
    // Agregar nueva comida del servidor
    final foods = data['foods'] as List;
    for (var foodData in foods) {
      _addServerFood(foodData);
    }
  }
  
  void _handlePlayerDied(Map<String, dynamic> data) {
    final playerId = data['playerId'];
    print('💀 Jugador $playerId ha muerto');
    
    // Remover al jugador remoto del juego
    final player = remotePlayers.remove(playerId);
    if (player != null) {
      player.removeFromParent();
      print('✅ Jugador remoto $playerId removido del juego');
    }
  }
  
  void _addRemotePlayer(Map<String, dynamic> playerData) {
    final playerId = playerData['id'];
    if (!remotePlayers.containsKey(playerId)) {
      final player = RemotePlayer(
        playerId: playerId,
        nickname: playerData['nickname'] ?? 'Player',
        position: Vector2(playerData['x'], playerData['y']),
        bodyLength: playerData['bodyLength'] ?? 5,
        score: playerData['score'] ?? 0,
      );
      remotePlayers[playerId] = player;
      world.add(player);
    }
  }
  
  void _addServerFood(Map<String, dynamic> foodData) {
    final foodId = foodData['id'];
    // Verificar que no existe ya
    final existingFoods = world.children.whereType<Food>();
    for (var food in existingFoods) {
      if (food.id == foodId) {
        print('⚠️ Comida $foodId ya existe, saltando...');
        return;
      }
    }
    
    try {
      final food = Food(
        position: Vector2(foodData['x'].toDouble(), foodData['y'].toDouble()),
        id: foodId,
        color: Color(foodData['color']),
      );
      world.add(food);
    } catch (e) {
      print('❌ Error agregando comida: $e');
      print('Datos recibidos: $foodData');
    }
  }

  void spawnFood() {
    Vector2 position = Vector2(
      Random().nextDouble() * worldSize.x,
      Random().nextDouble() * worldSize.y,
    );
    world.add(Food(position: position));
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    // Convierte la posición del toque a coordenadas del mundo
    final localPosition = cameraComponent.viewport.globalToLocal(info.eventPosition.global);
    final worldPosition = cameraComponent.viewfinder.localToGlobal(localPosition);
    // Calcula la dirección desde el jugador hacia el punto tocado
    targetDirection = (worldPosition - playerHead.position).normalized();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Reposicionar el joystick si ya existe
    if (joystick != null) {
      joystick!.position = Vector2(100, size.y - 100);
    }
  }

  // Método para hacer crecer al gusano cuando come
  void eatFood({String? foodId}) {
    score++; // Aumentar puntuación
    
    // Crecer 1 segmento cada 3 puntos (crecimiento más lento)
    if (score % 3 == 0) {
      bodyLength++;
    }
    
    // Notificar al servidor en modo multijugador
    if (isMultiplayer && networkService != null && foodId != null) {
      networkService!.sendFoodEaten(foodId, score, bodyLength);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Hacer crecer el cuerpo según bodyLength
    if (body.length < bodyLength) {
      final segment = BodySegment(
        position: playerHead.position,
        ownerId: networkService?.playerId,  // Marcar mis propios segmentos
      );
      world.add(segment);
      body.add(segment);
    }

    // Actualizar posiciones de los segmentos del cuerpo
    if (playerHead.pathPoints.isNotEmpty) {
      for (var i = 0; i < body.length; i++) {
        final pointIndex = playerHead.pathPoints.length - 1 - (i * 3);
        if (pointIndex >= 0) {
          body[i].position = playerHead.pathPoints[pointIndex];
        }
      }
    }

    // Limpiar puntos antiguos del camino
    final lastSegmentIndex =
        playerHead.pathPoints.length - 1 - ((body.length - 1) * 3);
    if (lastSegmentIndex > 10) {
      playerHead.pathPoints.removeRange(0, lastSegmentIndex - 10);
    }

    // Enviar actualización de posición al servidor (solo en multijugador)
    if (isMultiplayer && networkService != null) {
      _networkUpdateTimer += dt;
      if (_networkUpdateTimer >= _networkUpdateInterval) {
        _networkUpdateTimer = 0;
        networkService!.sendMove(playerHead.position, targetDirection);
      }
    }

    // Sistema de regeneración gradual de comida (solo en modo solo)
    if (!isMultiplayer) {
      _foodSpawnTimer += dt;
      if (_foodSpawnTimer >= _foodSpawnInterval) {
        _foodSpawnTimer = 0;
        
        int currentFoodCount = world.children.whereType<Food>().length;
        if (currentFoodCount < maxFoodCount) {
          // Generar solo unas pocas comidas a la vez
          int toSpawn = min(_foodPerSpawn, maxFoodCount - currentFoodCount);
          for (int i = 0; i < toSpawn; i++) {
            spawnFood();
          }
        }
      }
    }
  }
  
  // Método llamado cuando el jugador muere
  void onPlayerDeath() {
    print('💀 ¡Has muerto! Chocaste con otro jugador');
    
    // Notificar al servidor (en multijugador)
    if (isMultiplayer && networkService != null) {
      networkService!.sendPlayerDeath();
    }
    
    // Remover el jugador y su cuerpo del juego
    playerHead.removeFromParent();
    for (var segment in body) {
      segment.removeFromParent();
    }
    body.clear();
    
    // Mostrar pantalla de Game Over
    overlays.add('GameOver');
    
    // Pausar el juego (detener el update)
    pauseEngine();
  }
  
  @override
  void onRemove() {
    // Desconectar del servidor al cerrar el juego
    networkService?.disconnect();
    super.onRemove();
  }
}
