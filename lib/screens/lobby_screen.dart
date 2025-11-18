import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slither_game/services/auth_service.dart';
import 'package:slither_game/services/room_service.dart';
import 'package:slither_game/services/network_service.dart';
import 'package:slither_game/config/game_config.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({Key? key}) : super(key: key);

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final _authService = AuthService();
  final _roomService = RoomService();
  NetworkService? _networkService;
  
  String? _roomCode;
  String? _hostId;  // 🔑 ID del host recibido del servidor
  String? _serverPlayerId;  // 🔑 MI ID asignado por el servidor
  List<Map<String, dynamic>> _players = [];
  bool _isHost = false;
  bool _isReady = false;
  bool _isConnecting = true;
  String? _myPlayerId;  // ID de Supabase (para referencia)

  @override
  void initState() {
    super.initState();
    _initializeLobby();
  }

  Future<void> _initializeLobby() async {
    // Obtener argumentos de la ruta
    await Future.delayed(Duration.zero);
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _roomCode = args?['code'];

    if (_roomCode == null) {
      _showError('Código de sala inválido');
      Navigator.pop(context);
      return;
    }

    // Obtener perfil del usuario
    final profile = await _authService.getUserProfile();
    if (profile == null) {
      _showError('Error al obtener perfil');
      Navigator.pop(context);
      return;
    }

    _myPlayerId = profile['id'];
    // ⚠️ NO determinamos _isHost aquí, lo recibimos del servidor

    // Conectar al servidor con código de sala
    await _connectToServer();
  }

  Future<void> _connectToServer() async {
    try {
      _networkService = NetworkService(serverUrl: GameConfig.serverUrl);
      
      // Configurar callbacks del lobby
      _networkService!.onInit = _handleServerInit;
      _networkService!.onPlayerJoined = _handlePlayerJoined;
      _networkService!.onPlayerLeft = _handlePlayerLeft;
      _networkService!.onPlayerUpdate = _handlePlayerUpdate;
      _networkService!.onGameStart = _handleGameStart;  // 🎮 Handler para inicio de juego
      
      await _networkService!.connect();
      
      // Obtener y enviar nickname al servidor
      final profile = await _authService.getUserProfile();
      final nickname = profile?['nickname'] ?? 'Player';
      print('📤 Enviando nickname al servidor: $nickname');
      _networkService!.sendNickname(nickname);
      
      // Enviar código de sala al servidor
      _networkService!.sendRoomCode(_roomCode!);
      
      setState(() => _isConnecting = false);
    } catch (e) {
      setState(() => _isConnecting = false);
      _showError('Error al conectar: $e');
    }
  }

  void _handleServerInit(Map<String, dynamic> data) {
    setState(() {
      _serverPlayerId = data['playerId'];  // 🔑 MI ID del servidor
      _hostId = data['hostId'];  // 🔑 ID del host
      _players = (data['players'] as List?)
          ?.map((p) => p as Map<String, dynamic>)
          .toList() ?? [];
      
      // Determinar si soy el host usando IDs del servidor
      _isHost = _serverPlayerId == _hostId;
      
      print('📡 Init recibido:');
      print('   Mi ID servidor: $_serverPlayerId');
      print('   Host ID: $_hostId');
      print('   ¿Soy host?: $_isHost');
      print('   Jugadores: ${_players.length}');
    });
  }

  void _handlePlayerJoined(Map<String, dynamic> data) {
    setState(() {
      _players.add(data['player']);
    });
    _showSnackBar('${data['player']['nickname']} se unió');
  }

  void _handlePlayerLeft(Map<String, dynamic> data) {
    setState(() {
      _players.removeWhere((p) => p['id'] == data['playerId']);
    });
    _showSnackBar('Un jugador salió');
  }

  void _handlePlayerUpdate(Map<String, dynamic> data) {
    setState(() {
      // El servidor envía el objeto 'player' completo
      final playerData = data['player'] as Map<String, dynamic>?;
      if (playerData != null) {
        final index = _players.indexWhere((p) => p['id'] == playerData['id']);
        if (index != -1) {
          // Actualizar el jugador con los nuevos datos (incluyendo nickname)
          _players[index] = {..._players[index], ...playerData};
          print('🔄 Jugador actualizado: ${playerData['nickname']}');
        }
      }
    });
  }

  void _handleGameStart(Map<String, dynamic> data) async {
    print('🎮 Iniciando juego - Navegando a pantalla de juego...');
    final roomCode = data['roomCode'] as String?;
    
    if (mounted && roomCode != null) {
      // Establecer nickname en GameConfig antes de iniciar el juego
      final profile = await _authService.getUserProfile();
      GameConfig.playerNickname = profile?['nickname'] ?? 'Player';
      print('🎮 Uniéndose al juego con nickname: ${GameConfig.playerNickname}');
      
      // Navegar al juego
      Navigator.pushReplacementNamed(
        context,
        '/game',
        arguments: {
          'multiplayer': true,
          'roomCode': roomCode,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _leaveLobby();
        return true;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
            ),
          ),
          child: SafeArea(
            child: _isConnecting
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF00ff88)),
                        SizedBox(height: 20),
                        Text(
                          'Conectando al lobby...',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      _buildHeader(),
                      Expanded(child: _buildPlayersList()),
                      _buildBottomBar(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Botón atrás
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            onPressed: _leaveLobby,
          ),
          // Título
          const Text(
            'LOBBY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          // Código de sala - COMPACTO en la esquina
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00ff88).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF00ff88), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.vpn_key, color: Color(0xFF00ff88), size: 14),
                const SizedBox(width: 6),
                Text(
                  _roomCode ?? '',
                  style: const TextStyle(
                    color: Color(0xFF00ff88),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _roomCode!));
                    _showSnackBar('Código copiado!');
                  },
                  child: const Icon(Icons.copy, color: Color(0xFF00ff88), size: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersList() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Encabezado de la lista - MÁS COMPACTO
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, color: Color(0xFF00ff88), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Jugadores (${_players.length}/10)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_players.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00ff88).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_readyPlayers()}/${_players.length} ✓',
                      style: const TextStyle(
                        color: Color(0xFF00ff88),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          // Lista de jugadores
          Expanded(
            child: _players.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add,
                          size: 40,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Esperando jugadores...',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Comparte el código de sala',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    itemCount: _players.length,
                    itemBuilder: (context, index) {
                      final player = _players[index];
                      final isMe = player['id'] == _serverPlayerId;  // Usar ID del servidor
                      final isHost = player['id'] == _hostId;  // Usar hostId del servidor
                      final isReady = player['isReady'] ?? false;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 4,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFF00ff88).withOpacity(0.12)
                              : Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isMe
                                ? const Color(0xFF00ff88)
                                : Colors.white.withOpacity(0.1),
                            width: isMe ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isHost
                                    ? const Color(0xFFff9500).withOpacity(0.2)
                                    : isMe
                                        ? const Color(0xFF00ff88).withOpacity(0.2)
                                        : Colors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  player['avatar'] ?? '🐍',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    player['nickname'] ?? 'Player',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: isMe
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  // Badges
                                  Row(
                                    children: [
                                      if (isHost) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFff9500),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          child: const Text(
                                            'HOST',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                      ],
                                      if (isMe)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00ff88),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          child: const Text(
                                            'TÚ',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Estado
                            if (isReady)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF00ff88),
                                size: 24,
                              )
                            else
                              Icon(
                                Icons.radio_button_unchecked,
                                color: Colors.white.withOpacity(0.2),
                                size: 24,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Botón Listo (para TODOS incluyendo host)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _toggleReady,
                icon: Icon(
                  _isReady ? Icons.check_circle : Icons.circle_outlined,
                  size: 18,
                ),
                label: Text(
                  _isReady ? 'Listo!' : 'No Listo',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isReady
                      ? const Color(0xFF00ff88)
                      : Colors.white.withOpacity(0.1),
                  foregroundColor: _isReady ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            // Botón Iniciar Juego (solo para host)
            if (_isHost) ...[
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _canStartGame() ? _startGame : null,
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text(
                    'INICIAR',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFff9500),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    disabledBackgroundColor: Colors.white.withOpacity(0.1),
                    disabledForegroundColor: Colors.white30,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _canStartGame() {
    if (_players.length < 2) return false;
    // TODOS los jugadores deben estar listos (incluyendo el host)
    return _players.every((p) => p['isReady'] == true);
  }

  int _readyPlayers() {
    return _players.where((p) => p['isReady'] == true).length;
  }

  void _toggleReady() {
    setState(() => _isReady = !_isReady);
    // Enviar al servidor
    _networkService?.sendPlayerReady(_isReady);
  }

  Future<void> _startGame() async {
    // Notificar al servidor que se inicia el juego
    _networkService?.sendStartGame(_roomCode!);
    
    // Establecer nickname en GameConfig antes de iniciar el juego
    final profile = await _authService.getUserProfile();
    GameConfig.playerNickname = profile?['nickname'] ?? 'Player';
    print('🎮 Iniciando juego con nickname: ${GameConfig.playerNickname}');
    
    // Navegar al juego
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/game',
        arguments: {
          'multiplayer': true,
          'roomCode': _roomCode,
        },
      );
    }
  }

  Future<void> _leaveLobby() async {
    await _roomService.leaveRoom();
    _networkService?.disconnect();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _networkService?.disconnect();
    super.dispose();
  }
}

