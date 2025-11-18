import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slither_game/services/auth_service.dart';
import 'package:slither_game/services/room_service.dart';

class MultiplayerMenuScreen extends StatefulWidget {
  const MultiplayerMenuScreen({Key? key}) : super(key: key);

  @override
  State<MultiplayerMenuScreen> createState() => _MultiplayerMenuScreenState();
}

class _MultiplayerMenuScreenState extends State<MultiplayerMenuScreen> {
  final _authService = AuthService();
  final _roomService = RoomService();
  final _roomCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // Crear Juego
                        _buildMenuButton(
                          icon: Icons.add_circle_outline,
                          title: 'Crear Juego',
                          subtitle: 'Inicia una nueva partida',
                          color: const Color(0xFF00ff88),
                          onTap: _createGame,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Unirse a Juego
                        _buildMenuButton(
                          icon: Icons.login,
                          title: 'Unirse a Juego',
                          subtitle: 'Ingresa el código de la partida',
                          color: const Color(0xFF0088ff),
                          onTap: _showJoinDialog,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Mi Perfil
                        _buildMenuButton(
                          icon: Icons.person,
                          title: 'Mi Perfil',
                          subtitle: 'Ver y editar perfil',
                          color: const Color(0xFFff00ff),
                          onTap: _showProfile,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          const Text(
            'MULTIJUGADOR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createGame() async {
    print('🎮 Botón Crear Juego presionado');
    setState(() => _isLoading = true);
    
    try {
      final profile = await _authService.getUserProfile();
      if (profile == null) {
        setState(() => _isLoading = false);
        _showError('Error al obtener perfil');
        return;
      }

      print('✅ Perfil obtenido: ${profile['nickname']}');

      final room = await _roomService.createRoom(
        profile['id'],
        profile['nickname'],
      );

      print('✅ Sala creada: ${room.code}');
      setState(() => _isLoading = false);

      if (mounted) {
        _showRoomCreatedDialog(room.code);
      }
    } catch (e) {
      print('❌ Error al crear sala: $e');
      setState(() => _isLoading = false);
      _showError('Error al crear sala: $e');
    }
  }

  void _showRoomCreatedDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🎮 Sala Creada',
          style: TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Comparte este código:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00ff88).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00ff88), width: 2),
                ),
                child: Text(
                  code,
                  style: const TextStyle(
                    color: Color(0xFF00ff88),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('📋 Código copiado!'),
                      backgroundColor: Color(0xFF00ff88),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copiar Código', style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00ff88),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/lobby', arguments: {'code': code});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00ff88),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Ir al Lobby', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog() {
    _roomCodeController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        title: const Text(
          '🚪 Unirse a Juego',
          style: TextStyle(color: Colors.white, fontSize: 17),
          textAlign: TextAlign.center,
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ingresa el código de la sala:',
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _roomCodeController,
                autofocus: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: 'A1B2C3',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF0088ff)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: const Color(0xFF0088ff).withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF0088ff), width: 2),
                  ),
                  counterStyle: const TextStyle(color: Colors.white54, fontSize: 11),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_roomCodeController.text.length == 6) {
                Navigator.pop(context);
                await _joinGame(_roomCodeController.text.toUpperCase());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El código debe tener 6 caracteres')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0088ff),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Unirse', style: TextStyle(fontSize: 13)),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      ),
    );
  }

  Future<void> _joinGame(String code) async {
    print('🚪 Intentando unirse a sala: $code');
    setState(() => _isLoading = true);
    
    try {
      final profile = await _authService.getUserProfile();
      if (profile == null) {
        setState(() => _isLoading = false);
        _showError('Error al obtener perfil');
        return;
      }

      final success = await _roomService.joinRoom(
        code,
        profile['id'],
        profile['nickname'],
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        print('✅ Uniéndose a sala $code');
        Navigator.pushNamed(context, '/lobby', arguments: {'code': code});
      } else {
        _showError('No se pudo unir a la sala');
      }
    } catch (e) {
      print('❌ Error al unirse: $e');
      setState(() => _isLoading = false);
      _showError('Error al unirse: $e');
    }
  }

  void _showProfile() async {
    final profile = await _authService.getUserProfile();
    final nickname = await _authService.getNickname();
    
    if (!mounted) return;
    
    print('🔍 Mostrando perfil:');
    print('   Nickname: $nickname');
    print('   Email: ${profile?['email']}');
    print('   Avatar: ${profile?['avatar']}');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '👤 Mi Perfil',
          style: TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                profile?['avatar'] ?? '🐍',
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 12),
              Text(
                nickname,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                profile?['email'] ?? 'Invitado',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white30),
              const SizedBox(height: 6),
              Text(
                'ID: ${profile?['id']?.toString().substring(0, 8) ?? 'N/A'}...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authService.signOut();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00ff88),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Cerrar', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }
}
