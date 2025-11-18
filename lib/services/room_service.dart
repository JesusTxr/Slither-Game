import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class GameRoom {
  final String code;
  final String hostId;
  final String hostNickname;
  final List<RoomPlayer> players;
  final int maxPlayers;
  final DateTime createdAt;
  bool isStarted;
  
  GameRoom({
    required this.code,
    required this.hostId,
    required this.hostNickname,
    this.players = const [],
    this.maxPlayers = 10,
    DateTime? createdAt,
    this.isStarted = false,
  }) : createdAt = createdAt ?? DateTime.now();
  
  Map<String, dynamic> toJson() => {
    'code': code,
    'hostId': hostId,
    'hostNickname': hostNickname,
    'players': players.map((p) => p.toJson()).toList(),
    'maxPlayers': maxPlayers,
    'isStarted': isStarted,
  };
  
  factory GameRoom.fromJson(Map<String, dynamic> json) => GameRoom(
    code: json['code'],
    hostId: json['hostId'],
    hostNickname: json['hostNickname'],
    players: (json['players'] as List?)
        ?.map((p) => RoomPlayer.fromJson(p))
        .toList() ?? [],
    maxPlayers: json['maxPlayers'] ?? 10,
    isStarted: json['isStarted'] ?? false,
  );
}

class RoomPlayer {
  final String id;
  final String nickname;
  final String avatar;
  final bool isReady;
  
  RoomPlayer({
    required this.id,
    required this.nickname,
    this.avatar = '🐍',
    this.isReady = false,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': nickname,
    'avatar': avatar,
    'isReady': isReady,
  };
  
  factory RoomPlayer.fromJson(Map<String, dynamic> json) => RoomPlayer(
    id: json['id'],
    nickname: json['nickname'],
    avatar: json['avatar'] ?? '🐍',
    isReady: json['isReady'] ?? false,
  );
}

class RoomService {
  static final RoomService _instance = RoomService._internal();
  factory RoomService() => _instance;
  RoomService._internal();
  
  GameRoom? _currentRoom;
  GameRoom? get currentRoom => _currentRoom;
  
  // Generar código de sala único
  String generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Sin I, O, 0, 1
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }
  
  // Crear una sala
  Future<GameRoom> createRoom(String hostId, String hostNickname) async {
    final code = generateRoomCode();
    final host = RoomPlayer(
      id: hostId,
      nickname: hostNickname,
      isReady: true, // Host siempre listo
    );
    
    _currentRoom = GameRoom(
      code: code,
      hostId: hostId,
      hostNickname: hostNickname,
      players: [host],
    );
    
    // Guardar código localmente
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentRoomCode', code);
    
    print('🎮 Sala creada: $code');
    return _currentRoom!;
  }
  
  // Unirse a una sala
  Future<bool> joinRoom(String code, String playerId, String nickname) async {
    // En una implementación real, esto consultaría el servidor
    // Por ahora, guardamos localmente
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentRoomCode', code);
    
    print('🚪 Intentando unirse a sala: $code');
    return true;
  }
  
  // Salir de la sala
  Future<void> leaveRoom() async {
    _currentRoom = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentRoomCode');
  }
  
  // Verificar si el jugador es el host
  bool isHost(String playerId) {
    return _currentRoom?.hostId == playerId;
  }
  
  // Obtener código de sala actual
  Future<String?> getCurrentRoomCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('currentRoomCode');
  }
}





