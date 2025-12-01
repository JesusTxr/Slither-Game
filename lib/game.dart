import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:slither_game/components/background.dart';
import 'package:slither_game/components/body_segment.dart';
import 'package:slither_game/components/dash_trail.dart';
import 'package:slither_game/components/food.dart';
import 'package:slither_game/components/joystick.dart';
import 'package:slither_game/components/minimap.dart';
import 'package:slither_game/components/player_head.dart';
import 'package:slither_game/components/power_up.dart';
import 'package:slither_game/components/remote_player.dart';
import 'package:slither_game/config/game_config.dart';
import 'package:slither_game/config/power_up_types.dart';
import 'package:slither_game/config/snake_skins.dart';
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
  
  // 🎁 Sistema de Power-Ups
  double _powerUpSpawnTimer = 0;
  final double _powerUpSpawnInterval = 20.0; // Nuevo power-up cada 20 segundos
  final int _maxPowerUpsInMap = 5; // Máximo 5 power-ups simultáneos
  PowerUpType? activePowerUp;
  double powerUpRemainingTime = 0;
  double powerUpTotalDuration = 0;
  bool isShieldActive = false;
  bool isGhostMode = false;
  bool isMagnetActive = false;
  double speedMultiplier = 1.0;
  double pointsMultiplier = 1.0;
  double _powerUpCooldown = 0;
  final double _powerUpCooldownDuration = 2.0; // 2 segundos entre power-ups
  bool isFrozen = false; // ❄️ Si el jugador está congelado
  double _frozenTimer = 0; // ❄️ Tiempo restante de congelación

  // World y CameraComponent modernos
  late final World world;
  late final CameraComponent cameraComponent;
  VirtualJoystick? joystick;
  
  // Multijugador
  NetworkService? networkService;
  final Map<String, RemotePlayer> remotePlayers = {};
  double _networkUpdateTimer = 0;
  final double _networkUpdateInterval = 0.016; // 60 FPS - Ultra fluido (REVERTIDO)
  Vector2? _lastSentPosition; // Para detectar cambios significativos
  double _minDistanceToSend = 1.0; // Enviar con cambio muy pequeño (REVERTIDO)
  bool isMultiplayer = false;
  String? roomCode;  // 🔑 Código de sala para multijugador
  bool waitingForPlayers = false;  // 🔑 Esperando a que todos los jugadores se conecten
  
  // 🏆 Sistema de ranking
  List<Map<String, dynamic>> ranking = [];
  int remainingSeconds = 300; // 5 minutos por defecto
  bool gameEnded = false;
  
  // 🎨 Sistema de skins
  SnakeSkin currentSkin = SnakeSkins.classic;

  // Constructor
  SlitherGame({this.roomCode, SnakeSkin? skin}) : currentSkin = skin ?? SnakeSkins.classic;

  @override
  Future<void> onLoad() async {
    // ⚡ FIX: Detectar multijugador por roomCode, no por GameConfig
    // GameConfig.isMultiplayer se resetea con hot reload
    isMultiplayer = roomCode != null && roomCode!.isNotEmpty;
    
    // ⚡ FIX ADICIONAL: También verificar GameConfig como respaldo
    if (!isMultiplayer && GameConfig.isMultiplayer) {
      print('⚠️ [GAME] roomCode vacío pero GameConfig.isMultiplayer = true, forzando multijugador');
      isMultiplayer = true;
    }
    
    print('🎮 [GAME] ================================================');
    print('🎮 [GAME] onLoad - roomCode: $roomCode');
    print('🎮 [GAME] onLoad - GameConfig.isMultiplayer: ${GameConfig.isMultiplayer}');
    print('🎮 [GAME] onLoad - isMultiplayer (FINAL): $isMultiplayer');
    print('🎮 [GAME] ================================================');
    
    // 1. Crear el mundo
    world = World();
    await add(world);

    // 2. Fondo (detrás de todo)
    await world.add(Background()..priority = -1);

    // 3. Si es multijugador, conectar al servidor
    if (isMultiplayer) {
      print('🌐 [GAME] Iniciando modo multijugador...');
      await _initializeMultiplayer();
    } else {
      print('🎮 [GAME] Modo solo jugador');
    }
    
    // Asegurarse de que el playerHead esté inicializado (fallback si el servidor falló)
    if (_playerHead == null) {
      final Vector2 worldCenter = worldSize / 2;
      playerHead = PlayerHead(startPosition: worldCenter, skin: currentSkin);
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

    // 6.5. Agregar minimapa al viewport
    final minimap = Minimap();
    await cameraComponent.viewport.add(minimap);
    print('🗺️ Minimapa agregado');

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
    networkService!.onPlayerRespawn = _handlePlayerRespawn;
    networkService!.onAllPlayersReady = _handleAllPlayersReady;
    networkService!.onRankingUpdate = _handleRankingUpdate;  // 🏆
    networkService!.onGameEnd = _handleGameEnd;  // 🏁
    networkService!.onPowerUpSpawned = _handlePowerUpSpawned;  // 🎁
    networkService!.onPowerUpCollected = _handlePowerUpCollectedByOther;  // 🎁
    networkService!.onPlayerFrozen = _handlePlayerFrozen;  // ❄️
    networkService!.onPlayerShrunk = _handlePlayerShrunk;  // 📏
    networkService!.onBombExploded = _handleBombExploded;  // 💣
    networkService!.onDashUsed = _handleDashUsed;  // 🎯
    
    try {
      await networkService!.connect();
      print('✅ Conectado al servidor multijugador');
      
      // Enviar nickname (asegurar que no esté vacío)
      final nickname = GameConfig.playerNickname ?? 'Player';
      print('📤 Enviando nickname: $nickname');
      networkService!.sendNickname(nickname);
      
      // Pequeña espera para que el servidor procese el nickname
      await Future.delayed(Duration(milliseconds: 100));
      
      // Enviar código de sala para unirse (con skin seleccionada)
      print('📤 Enviando código de sala: $roomCode');
      print('🎨 Enviando skin seleccionada: ${GameConfig.selectedSkinId}');
      networkService!.sendRoomCode(roomCode!, skinId: GameConfig.selectedSkinId);
      
      // ⏳ Esperar hasta 60 segundos para que el servidor responda
      // (Render puede tardar ~30-60 segundos en "despertar")
      print('⏳ Esperando respuesta del servidor (puede tardar hasta 60 segundos si está despertando)...');
      int attempts = 0;
      while (_playerHead == null && attempts < 120) {  // 120 * 500ms = 60 segundos
        await Future.delayed(Duration(milliseconds: 500));
        attempts++;
        if (attempts % 4 == 0) {  // Cada 2 segundos
          print('⏳ Esperando... (${attempts ~/ 2} segundos)');
        }
      }
      
      // Verificar si recibimos datos del servidor
      if (_playerHead == null) {
        print('⚠️ No se recibió respuesta del servidor después de ${attempts ~/ 2} segundos');
        throw Exception('Servidor no respondió');
      }
      
      print('✅ Servidor respondió exitosamente');
    } catch (e) {
      print('❌ Error conectando al servidor: $e');
      print('⚠️ Continuando en modo multijugador (puede reconectar)...');
      // NO cambiar a modo solo - mantener multijugador para que UI funcione
      // isMultiplayer = false; // ❌ COMENTADO: Esto causaba que no apareciera el ranking
      networkService?.disconnect();
      networkService = null;
    }
  }
  
  void _handleServerInit(Map<String, dynamic> data) {
    print('✅ Recibido init del servidor');
    // Crear jugador local en la posición del servidor
    final startPos = Vector2(data['x'], data['y']);
    playerHead = PlayerHead(startPosition: startPos, skin: currentSkin);
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
    
    // 🔄 LIMPIAR comida existente antes de cargar la del servidor
    print('🧹 Limpiando comida existente...');
    _clearAllFood();
    
    // Cargar comida del servidor
    final foods = data['foods'] as List;
    print('🍎 Comida recibida del servidor: ${foods.length} orbes');
    for (var foodData in foods) {
      _addServerFood(foodData);
    }
    print('✅ Comida agregada al mundo (total: ${world.children.whereType<Food>().length} orbes)');
    
    // 🎁 Cargar power-ups del servidor
    if (data.containsKey('powerUps')) {
      final powerUps = data['powerUps'] as List;
      print('🎁 Power-ups recibidos del servidor: ${powerUps.length}');
      for (var powerUpData in powerUps) {
        _addServerPowerUp(powerUpData);
      }
      print('✅ Power-ups agregados al mundo');
    }
    
    // 🔄 Si el juego ya comenzó, esperar a que todos los jugadores se conecten
    final gameStarted = data['gameStarted'] ?? false;
    if (gameStarted) {
      print('⏳ Juego ya iniciado. Esperando a que todos los jugadores se conecten...');
      waitingForPlayers = true;
      paused = true;  // Pausar el motor hasta que todos estén listos
      overlays.add('WaitingForPlayers');
    }
  }
  
  void _handleAllPlayersReady(Map<String, dynamic> data) {
    print('✅ Todos los jugadores están listos. ¡Comenzando juego!');
    waitingForPlayers = false;
    paused = false;  // Reanudar el motor
    overlays.remove('WaitingForPlayers');
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
    print('📥 [GAME] ================================================');
    print('📥 [GAME] _handlePlayerMove llamado con data: $data');
    final playerId = data['playerId'];
    print('📥 [GAME] playerId extraído: $playerId');
    print('📥 [GAME] remotePlayers keys: ${remotePlayers.keys.toList()}');
    final player = remotePlayers[playerId];
    print('📥 [GAME] Jugador encontrado: ${player != null}');
    
    if (player != null) {
      final x = (data['x'] as num).toDouble();
      final y = (data['y'] as num).toDouble();
      print('📥 [GAME] Actualizando posición de $playerId a ($x, $y)');
      print('📥 [GAME] Posición actual del jugador: ${player.position}');
      player.updatePosition(Vector2(x, y));
      print('📥 [GAME] updatePosition llamado, nueva posición objetivo: ${player._targetPosition}');
    } else {
      print('⚠️ [GAME] ERROR: Jugador $playerId no encontrado en remotePlayers');
      print('⚠️ [GAME] Jugadores remotos actuales: ${remotePlayers.keys.toList()}');
    }
    print('📥 [GAME] ================================================');
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
      // ⚠️ IMPORTANTE: Eliminar todos los segmentos del cuerpo
      final segmentCount = player.body.length;
      for (var segment in player.body) {
        segment.removeFromParent();
      }
      player.body.clear();
      
      // Eliminar la cabeza
      player.removeFromParent();
      print('✅ Jugador remoto $playerId y sus $segmentCount segmentos removidos del juego');
    }
  }
  
  void _handlePlayerRespawn(Map<String, dynamic> data) {
    final playerId = data['playerId'];
    final x = data['x'];
    final y = data['y'];
    final score = data['score'] ?? 0;
    final nickname = data['nickname'] ?? 'Player';
    
    // No hacer nada si es el jugador local (ya se maneja en respawnPlayer)
    if (playerId == networkService!.playerId) {
      print('🔄 Respawn local confirmado por servidor');
      return;
    }
    
    print('🔄 Jugador $playerId reapareció en ($x, $y)');
    
    // Si el jugador remoto ya existe, actualizar su posición y score
    var remotePlayer = remotePlayers[playerId];
    if (remotePlayer != null) {
      remotePlayer.updatePosition(Vector2(x, y));
      remotePlayer.score = score;
      print('✅ Jugador remoto $playerId actualizado');
    } else {
      // Si no existe, crear un nuevo RemotePlayer (fue eliminado al morir)
      // 🎨 Obtener skin del jugador remoto
      final skinId = data['playerSkin'] ?? 'classic';
      final playerSkin = SnakeSkins.getById(skinId);
      
      remotePlayer = RemotePlayer(
        playerId: playerId,
        nickname: nickname,
        position: Vector2(x, y),
        skin: playerSkin, // 🎨 Usar skin correcta
      );
      remotePlayer.score = score;
      world.add(remotePlayer);
      remotePlayers[playerId] = remotePlayer;
      print('✅ Jugador remoto $playerId recreado después de respawn con skin: $skinId');
    }
  }
  
  void _handleRankingUpdate(Map<String, dynamic> data) {
    // Actualizar el ranking y tiempo restante
    ranking = List<Map<String, dynamic>>.from(data['ranking']);
    remainingSeconds = data['remainingSeconds'] ?? 0;
    
    // El overlay de RankingDisplay se actualiza automáticamente
    // ya que lee directamente de estas variables
  }
  
  void _handleGameEnd(Map<String, dynamic> data) {
    print('🏁 ¡Juego terminado!');
    gameEnded = true;
    paused = true;  // Pausar el juego
    
    // Actualizar ranking final
    ranking = List<Map<String, dynamic>>.from(data['ranking']);
    final winner = data['winner'];
    
    if (winner != null) {
      print('🏆 Ganador: ${winner['nickname']} con ${winner['score']} puntos');
    }
    
    // Mostrar overlay de fin de juego
    overlays.remove('WaitingForPlayers');
    overlays.add('GameEnd');
  }
  
  void _addRemotePlayer(Map<String, dynamic> playerData) {
    final playerId = playerData['id'];
    if (!remotePlayers.containsKey(playerId)) {
      // 🎨 Obtener skin del jugador remoto
      final skinId = playerData['playerSkin'] ?? 'classic';
      final playerSkin = SnakeSkins.getById(skinId);
      print('🎨 Jugador remoto $playerId con skin: $skinId');
      
      final player = RemotePlayer(
        playerId: playerId,
        nickname: playerData['nickname'] ?? 'Player',
        position: Vector2(playerData['x'], playerData['y']),
        bodyLength: playerData['bodyLength'] ?? 5,
        score: playerData['score'] ?? 0,
        skin: playerSkin, // 🎨 Usar skin correcta
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
  
  // 🎁 Agregar power-up recibido del servidor
  void _addServerPowerUp(Map<String, dynamic> powerUpData) {
    final powerUpId = powerUpData['id'];
    
    // Verificar que no existe ya
    final existingPowerUps = world.children.whereType<PowerUp>();
    for (var powerUp in existingPowerUps) {
      if (powerUp.id == powerUpId) {
        print('⚠️ Power-up $powerUpId ya existe, saltando...');
        return;
      }
    }
    
    try {
      // Convertir el string del tipo a PowerUpType enum
      final typeString = powerUpData['type'];
      PowerUpType type;
      
      switch (typeString) {
        case 'speedBoost':
          type = PowerUpType.speedBoost;
          break;
        case 'shield':
          type = PowerUpType.shield;
          break;
        case 'magnet':
          type = PowerUpType.magnet;
          break;
        case 'ghostMode':
          type = PowerUpType.ghostMode;
          break;
        case 'doublePoints':
          type = PowerUpType.doublePoints;
          break;
        case 'dash':
          type = PowerUpType.dash;
          break;
        case 'freeze':
          type = PowerUpType.freeze;
          break;
        case 'shrinkRay':
          type = PowerUpType.shrinkRay;
          break;
        case 'bomb':
          type = PowerUpType.bomb;
          break;
        default:
          print('❌ Tipo de power-up desconocido: $typeString');
          return;
      }
      
      final powerUp = PowerUp(
        id: powerUpId,
        type: type,
        position: Vector2(powerUpData['x'].toDouble(), powerUpData['y'].toDouble()),
      );
      world.add(powerUp);
      print('🎁 Power-up agregado: $typeString en (${powerUpData['x']}, ${powerUpData['y']})');
    } catch (e) {
      print('❌ Error agregando power-up: $e');
    }
  }
  
  // 🎁 Handler cuando el servidor genera un nuevo power-up
  void _handlePowerUpSpawned(Map<String, dynamic> data) {
    _addServerPowerUp(data['powerUp']);
  }
  
  // 🎁 Handler cuando otro jugador recoge un power-up
  void _handlePowerUpCollectedByOther(String powerUpId) {
    // Buscar y eliminar el power-up del mundo
    final existingPowerUps = world.children.whereType<PowerUp>().toList();
    for (var powerUp in existingPowerUps) {
      if (powerUp.id == powerUpId) {
        powerUp.removeFromParent();
        print('🎁 Power-up $powerUpId eliminado (recogido por otro jugador)');
        break;
      }
    }
  }
  
  // ❄️ Handler cuando un jugador es congelado
  void _handlePlayerFrozen(Map<String, dynamic> data) {
    final attackerId = data['playerId'] as String;
    final affectedPlayers = data['affectedPlayers'] as List;
    final duration = data['duration'] as double;
    
    // Si soy uno de los afectados, congelarme
    if (affectedPlayers.contains(networkService?.playerId)) {
      isFrozen = true;
      _frozenTimer = duration;
      print('❄️ ¡Has sido congelado por $attackerId por $duration segundos!');
    }
    
    print('❄️ Freeze usado por $attackerId: ${affectedPlayers.length} jugadores congelados');
  }
  
  // 📏 Handler cuando un jugador es reducido
  void _handlePlayerShrunk(Map<String, dynamic> data) {
    final attackerId = data['playerId'] as String;
    final affectedPlayers = data['affectedPlayers'] as Map<String, dynamic>;
    
    // Si soy uno de los afectados, reducir mi tamaño
    if (affectedPlayers.containsKey(networkService?.playerId)) {
      final segmentsToRemove = affectedPlayers[networkService?.playerId] as int;
      
      // Reducir bodyLength
      bodyLength = (bodyLength - segmentsToRemove).clamp(5, 1000);
      
      // Eliminar segmentos visualmente
      final segmentsToDelete = body.length > bodyLength ? body.length - bodyLength : 0;
      for (int i = 0; i < segmentsToDelete; i++) {
        if (body.isNotEmpty) {
          body.last.removeFromParent();
          body.removeLast();
        }
      }
      
      print('📏 ¡Has sido reducido por $attackerId! Perdiste $segmentsToRemove segmentos');
    }
    
    // Actualizar jugadores remotos
    affectedPlayers.forEach((playerId, segmentsRemoved) {
      if (remotePlayers.containsKey(playerId)) {
        final remotePlayer = remotePlayers[playerId]!;
        remotePlayer.bodyLength = (remotePlayer.bodyLength - (segmentsRemoved as int)).clamp(5, 1000);
        print('📏 Jugador remoto $playerId reducido');
      }
    });
    
    print('📏 Shrink Ray usado por $attackerId: ${affectedPlayers.length} jugadores afectados');
  }
  
  // 💣 Handler cuando explota una bomba
  void _handleBombExploded(Map<String, dynamic> data) {
    final attackerId = data['playerId'] as String;
    final affectedPlayers = data['affectedPlayers'] as Map<String, dynamic>;
    
    // Si soy uno de los afectados, reducir mi tamaño
    if (affectedPlayers.containsKey(networkService?.playerId)) {
      final segmentsDestroyed = affectedPlayers[networkService?.playerId] as int;
      
      // Reducir bodyLength
      bodyLength = (bodyLength - segmentsDestroyed).clamp(5, 1000);
      
      // Eliminar segmentos visualmente
      final segmentsToDelete = body.length > bodyLength ? body.length - bodyLength : 0;
      for (int i = 0; i < segmentsToDelete; i++) {
        if (body.isNotEmpty) {
          body.last.removeFromParent();
          body.removeLast();
        }
      }
      
      print('💣 ¡Has sido alcanzado por una bomba de $attackerId! Perdiste $segmentsDestroyed segmentos');
    }
    
    // Actualizar jugadores remotos
    affectedPlayers.forEach((playerId, segmentsDestroyed) {
      if (remotePlayers.containsKey(playerId)) {
        final remotePlayer = remotePlayers[playerId]!;
        remotePlayer.bodyLength = (remotePlayer.bodyLength - (segmentsDestroyed as int)).clamp(5, 1000);
        print('💣 Jugador remoto $playerId afectado por bomba');
      }
    });
    
    print('💣 Bomba explotada por $attackerId: ${affectedPlayers.length} jugadores afectados');
  }
  
  // 🎯 Handler cuando otro jugador usa Dash
  void _handleDashUsed(Map<String, dynamic> data) {
    final playerId = data['playerId'] as String;
    final startX = data['startX'] as double;
    final startY = data['startY'] as double;
    final endX = data['endX'] as double;
    final endY = data['endY'] as double;
    
    final startPosition = Vector2(startX, startY);
    final endPosition = Vector2(endX, endY);
    final direction = (endPosition - startPosition).normalized();
    final distance = (endPosition - startPosition).length;
    
    // Crear estela peligrosa para el otro jugador
    final trailSegments = 15;
    for (int i = 0; i < trailSegments; i++) {
      final progress = i / trailSegments;
      final trailPosition = startPosition + (direction * distance * progress);
      
      final trail = DashTrail(
        position: trailPosition,
        ownerId: playerId,
      );
      world.add(trail);
    }
    
    print('🎯 Dash de jugador $playerId visualizado (estela peligrosa creada)');
  }
  
  void _clearAllFood() {
    // Eliminar toda la comida del mundo
    final allFood = world.children.whereType<Food>().toList();
    for (var food in allFood) {
      food.removeFromParent();
    }
    print('🧹 ${allFood.length} orbes de comida eliminados');
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
    // Aumentar puntuación (con multiplicador si está activo Double Points)
    score += pointsMultiplier.round();
    
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
  // ⚡ OPTIMIZACIÓN: Timer para actualizar body segments
  double _bodyUpdateTimer = 0;
  static const double _bodyUpdateInterval = 0.033; // 30 FPS para body
  
  void update(double dt) {
    super.update(dt);
    
    // ⚡ OPTIMIZACIÓN: Actualizar body segments solo cada 0.033s (30 FPS)
    _bodyUpdateTimer += dt;
    if (_bodyUpdateTimer >= _bodyUpdateInterval) {
      _bodyUpdateTimer = 0;
      
      // Hacer crecer el cuerpo según bodyLength
      if (body.length < bodyLength) {
        final segment = BodySegment(
          position: playerHead.position,
          ownerId: networkService?.playerId,
          skin: currentSkin,
        );
        world.add(segment);
        body.add(segment);
      }

      // Actualizar posiciones de los segmentos del cuerpo
      if (playerHead.pathPoints.isNotEmpty) {
        for (var i = 0; i < body.length; i++) {
          final pointIndex = playerHead.pathPoints.length - 1 - (i * 1);
          if (pointIndex >= 0) {
            body[i].position = playerHead.pathPoints[pointIndex];
          }
        }
      }

      // Limpiar puntos antiguos del camino
      final lastSegmentIndex = playerHead.pathPoints.length - 1 - ((body.length - 1) * 1);
      if (lastSegmentIndex > 10) {
        playerHead.pathPoints.removeRange(0, lastSegmentIndex - 10);
      }
    }

    // Enviar actualización de posición al servidor (solo en multijugador)
    if (isMultiplayer && networkService != null) {
      _networkUpdateTimer += dt;
      if (_networkUpdateTimer >= _networkUpdateInterval) {
        _networkUpdateTimer = 0;
        
        // Solo enviar si hay cambio significativo (reduce tráfico de red)
        bool shouldSend = false;
        if (_lastSentPosition == null) {
          shouldSend = true;
        } else {
          final distance = (playerHead.position - _lastSentPosition!).length;
          shouldSend = distance >= _minDistanceToSend;
        }
        
        if (shouldSend) {
          print('📤 [GAME] Enviando posición: ${playerHead.position}, dirección: $targetDirection');
          networkService!.sendMove(playerHead.position, targetDirection);
          _lastSentPosition = playerHead.position.clone();
        }
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
    
    // 🎁 Sistema de Power-Ups
    _updatePowerUpSystem(dt);
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
  
  /// Reaparece el jugador después de morir
  void respawnPlayer() {
    print('🔄 Reapareciendo jugador...');
    
    // Encontrar una posición aleatoria segura
    final random = Random();
    final spawnX = (random.nextDouble() * size.x * 0.8) + size.x * 0.1;
    final spawnY = (random.nextDouble() * size.y * 0.8) + size.y * 0.1;
    final spawnPosition = Vector2(spawnX, spawnY);
    
    // Reiniciar puntuación y tamaño del gusano
    score = 0;
    bodyLength = 5; // Volver al tamaño inicial
    
    // Crear nuevo PlayerHead
    _playerHead = PlayerHead(
      startPosition: spawnPosition,
      skin: currentSkin,
    );
    world.add(_playerHead!);
    
    // 🎥 IMPORTANTE: Actualizar la cámara para seguir al nuevo jugador
    cameraComponent.follow(_playerHead!);
    
    // 🧹 Limpiar el cuerpo anterior (eliminar segmentos del mundo)
    for (var segment in body) {
      segment.removeFromParent();
    }
    body.clear();
    
    // Notificar al servidor del respawn
    if (isMultiplayer && networkService != null) {
      networkService!.sendPlayerRespawn(spawnPosition.x, spawnPosition.y);
    }
    
    // Quitar overlay y reanudar juego
    overlays.remove('GameOver');
    resumeEngine();
    
    print('✅ Jugador reaparecido en (${spawnPosition.x.toInt()}, ${spawnPosition.y.toInt()})');
  }
  
  // 🎁 ==================== SISTEMA DE POWER-UPS ====================
  
  void _updatePowerUpSystem(double dt) {
    // Actualizar cooldown
    if (_powerUpCooldown > 0) {
      _powerUpCooldown -= dt;
    }
    
    // 🎮 Spawn de power-ups (solo en modo solo jugador)
    if (!isMultiplayer) {
      _powerUpSpawnTimer += dt;
      if (_powerUpSpawnTimer >= _powerUpSpawnInterval) {
        _powerUpSpawnTimer = 0;
        _spawnPowerUp();
      }
    }
    
    // Actualizar temporizador del power-up activo
    if (activePowerUp != null && powerUpRemainingTime > 0) {
      powerUpRemainingTime -= dt;
      
      if (powerUpRemainingTime <= 0) {
        _deactivatePowerUp();
      }
    }
    
    // 🧲 Efecto del imán (atraer comida cercana)
    if (isMagnetActive) {
      _applyMagnetEffect();
    }
    
    // ❄️ Actualizar temporizador de congelación
    if (isFrozen && _frozenTimer > 0) {
      _frozenTimer -= dt;
      if (_frozenTimer <= 0) {
        isFrozen = false;
        print('❄️ Ya no estás congelado');
      }
    }
  }
  
  void _spawnPowerUp() {
    final powerUpsInMap = world.children.whereType<PowerUp>().length;
    if (powerUpsInMap >= _maxPowerUpsInMap) return;
    
    final random = Random();
    final position = Vector2(
      random.nextDouble() * worldSize.x,
      random.nextDouble() * worldSize.y,
    );
    
    final type = PowerUpConfig.getRandomPowerUp();
    final powerUp = PowerUp(
      id: '${DateTime.now().millisecondsSinceEpoch}_$powerUpsInMap',
      type: type,
      position: position,
    );
    
    world.add(powerUp);
    print('🎁 Power-up generado: ${PowerUpConfig.getConfig(type).name}');
  }
  
  void collectPowerUp(PowerUp powerUp) {
    // Verificar cooldown
    if (_powerUpCooldown > 0) return;
    
    // Desactivar power-up anterior si existe
    if (activePowerUp != null) {
      _deactivatePowerUp();
    }
    
    // Activar nuevo power-up
    activePowerUp = powerUp.type;
    final config = PowerUpConfig.getConfig(powerUp.type);
    powerUpTotalDuration = config.duration;
    powerUpRemainingTime = config.duration;
    
    // Eliminar el power-up del mapa
    powerUp.removeFromParent();
    
    // Aplicar efecto según tipo
    _activatePowerUpEffect(powerUp.type);
    
    // Iniciar cooldown
    _powerUpCooldown = _powerUpCooldownDuration;
    
    // 🌐 Notificar al servidor en modo multijugador
    if (isMultiplayer && networkService != null) {
      networkService!.sendPowerUpCollected(powerUp.id);
    }
    
    print('🎁 Power-up recogido: ${config.name}');
  }
  
  void _activatePowerUpEffect(PowerUpType type) {
    switch (type) {
      case PowerUpType.speedBoost:
        speedMultiplier = 2.0;
        break;
        
      case PowerUpType.shield:
        isShieldActive = true;
        break;
        
      case PowerUpType.magnet:
        isMagnetActive = true;
        break;
        
      case PowerUpType.ghostMode:
        isGhostMode = true;
        break;
        
      case PowerUpType.doublePoints:
        pointsMultiplier = 2.0;
        break;
        
      case PowerUpType.dash:
        _applyDash();
        break;
        
      case PowerUpType.freeze:
        _applyFreeze();
        break;
        
      case PowerUpType.shrinkRay:
        _applyShrinkRay();
        break;
        
      case PowerUpType.bomb:
        _applyBomb();
        break;
    }
  }
  
  void _deactivatePowerUp() {
    if (activePowerUp == null) return;
    
    // Resetear efectos
    speedMultiplier = 1.0;
    pointsMultiplier = 1.0;
    isShieldActive = false;
    isGhostMode = false;
    isMagnetActive = false;
    
    print('🎁 Power-up desactivado: ${PowerUpConfig.getConfig(activePowerUp!).name}');
    
    activePowerUp = null;
    powerUpRemainingTime = 0;
    powerUpTotalDuration = 0;
  }
  
  // 🧲 Efecto del imán
  void _applyMagnetEffect() {
    final magnetRange = 300.0;
    final magnetForce = 500.0;
    
    final allFood = world.children.whereType<Food>().toList();
    for (var food in allFood) {
      final distance = (food.position - playerHead.position).length;
      if (distance < magnetRange && distance > 30) {
        final direction = (playerHead.position - food.position).normalized();
        food.position += direction * magnetForce * 0.016; // Aproximadamente 60 FPS
      }
    }
  }
  
  // 🎯 Dash - Impulso rápido con estela peligrosa
  void _applyDash() {
    final dashDistance = 400.0;
    final startPosition = playerHead.position.clone();
    final newPosition = playerHead.position + (targetDirection * dashDistance);
    
    // Verificar límites del mapa
    newPosition.clamp(
      Vector2(currentRadius, currentRadius),
      worldSize - Vector2(currentRadius, currentRadius),
    );
    
    // Mover al jugador
    playerHead.position = newPosition;
    
    // 🔥 Crear estela peligrosa a lo largo del camino
    final trailSegments = 15; // 15 segmentos de estela
    final myPlayerId = networkService?.playerId ?? 'local';
    
    for (int i = 0; i < trailSegments; i++) {
      final progress = i / trailSegments;
      final trailPosition = startPosition + (targetDirection * dashDistance * progress);
      
      // Crear segmento de estela
      final trail = DashTrail(
        position: trailPosition,
        ownerId: myPlayerId,
      );
      world.add(trail);
    }
    
    // 🌐 Notificar al servidor en modo multijugador
    if (isMultiplayer && networkService != null) {
      networkService!.sendPowerUpDash(
        startPosition.x,
        startPosition.y,
        newPosition.x,
        newPosition.y,
      );
    }
    
    print('🎯 ¡Dash activado! Estela peligrosa creada');
  }
  
  // ❄️ Freeze - Congela jugadores cercanos
  void _applyFreeze() {
    final freezeRange = 400.0;
    List<String> affectedPlayers = [];
    
    for (var player in remotePlayers.values) {
      final distance = (player.position - playerHead.position).length;
      if (distance < freezeRange) {
        affectedPlayers.add(player.playerId);
        print('❄️ Jugador ${player.playerId} será congelado!');
      }
    }
    
    if (affectedPlayers.isNotEmpty) {
      // Enviar al servidor en modo multijugador
      if (isMultiplayer && networkService != null) {
        networkService!.sendPowerUpFreeze(affectedPlayers);
      }
      print('❄️ ¡Freeze activado! ${affectedPlayers.length} jugadores afectados');
    } else {
      print('❄️ Freeze activado pero no hay jugadores cercanos');
    }
  }
  
  // 📏 Shrink Ray - Reduce tamaño de rivales
  void _applyShrinkRay() {
    final shrinkRange = 300.0;
    final shrinkPercentage = 0.3; // 30%
    Map<String, int> affectedPlayers = {};
    
    for (var player in remotePlayers.values) {
      final distance = (player.position - playerHead.position).length;
      if (distance < shrinkRange) {
        final segmentsToRemove = (player.bodyLength * shrinkPercentage).round().clamp(1, player.bodyLength - 5);
        affectedPlayers[player.playerId] = segmentsToRemove;
        print('📏 Jugador ${player.playerId} será reducido en $segmentsToRemove segmentos!');
      }
    }
    
    if (affectedPlayers.isNotEmpty) {
      // Enviar al servidor en modo multijugador
      if (isMultiplayer && networkService != null) {
        networkService!.sendPowerUpShrinkRay(affectedPlayers);
      }
      print('📏 ¡Shrink Ray activado! ${affectedPlayers.length} jugadores afectados');
    } else {
      print('📏 Shrink Ray activado pero no hay jugadores cercanos');
    }
  }
  
  // 💣 Bomb - Explota segmentos cercanos
  void _applyBomb() {
    final bombRange = 250.0;
    
    // Contar segmentos destruidos por jugador
    Map<String, int> affectedPlayers = {};
    final allSegments = world.children.whereType<BodySegment>().toList();
    
    for (var segment in allSegments) {
      final distance = (segment.position - playerHead.position).length;
      if (distance < bombRange && segment.ownerId != null && segment.ownerId != networkService?.playerId) {
        // Eliminar visualmente el segmento
        segment.removeFromParent();
        
        // Contar para el jugador afectado
        affectedPlayers[segment.ownerId!] = (affectedPlayers[segment.ownerId] ?? 0) + 1;
      }
    }
    
    if (affectedPlayers.isNotEmpty) {
      // Enviar al servidor en modo multijugador
      if (isMultiplayer && networkService != null) {
        networkService!.sendPowerUpBomb(affectedPlayers);
      }
      
      final totalDestroyed = affectedPlayers.values.fold(0, (sum, count) => sum + count);
      print('💣 ¡BOOM! $totalDestroyed segmentos destruidos de ${affectedPlayers.length} jugadores');
    } else {
      print('💣 Bomba explotada pero no hay jugadores cercanos');
    }
    
    // TODO: Efecto visual de explosión
  }
  
  // 🎁 ==================== FIN SISTEMA DE POWER-UPS ====================
  
  @override
  void onRemove() {
    // Desconectar del servidor al cerrar el juego
    networkService?.disconnect();
    super.onRemove();
  }
}
