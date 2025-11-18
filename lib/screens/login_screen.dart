import 'package:flutter/material.dart';
import 'package:slither_game/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Título
                  const Text(
                    '🐍',
                    style: TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SLITHER GAME',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Formulario
                  _buildForm(),

                  const SizedBox(height: 30),

                  // Botón de invitado
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _playAsGuest,
                    icon: const Icon(Icons.person_outline, color: Colors.white70),
                    label: const Text(
                      'Jugar como Invitado',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      side: const BorderSide(color: Colors.white30),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Nickname (siempre visible)
          TextField(
            controller: _nicknameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Nickname',
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.person, color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          // Email y Password (solo si no es modo invitado)
          if (!_isGuest) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.email, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              style: const TextStyle(color: Colors.white),
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Botón principal
          if (_isLoading)
            const CircularProgressIndicator(color: Colors.white)
          else
            ElevatedButton(
              onPressed: _handleAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00ff88),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                _isSignUp ? 'Registrarse' : 'Iniciar Sesión',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Toggle login/signup
          TextButton(
            onPressed: () => setState(() => _isSignUp = !_isSignUp),
            child: Text(
              _isSignUp
                  ? '¿Ya tienes cuenta? Inicia sesión'
                  : '¿No tienes cuenta? Regístrate',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  bool get _isGuest => false; // Simplificado para este ejemplo

  Future<void> _handleAuth() async {
    if (_nicknameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    bool success;
    if (_isSignUp) {
      success = await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _nicknameController.text.trim(),
      );
    } else {
      success = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    setState(() => _isLoading = false);

    if (success) {
      // Manejar caso especial de confirmación de email
      if (_authService.lastError == 'CONFIRM_EMAIL') {
        if (mounted) {
          _showEmailConfirmationDialog();
        }
        return;
      }
      
      // Mostrar mensaje de depuración
      if (_authService.lastError != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authService.lastError!),
            backgroundColor: _authService.lastError!.contains('LOCAL') 
                ? Colors.orange 
                : Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/menu');
      }
    } else {
      // Manejar errores específicos
      if (_authService.lastError == 'EMAIL_NOT_CONFIRMED') {
        _showEmailNotConfirmedDialog();
      } else if (_authService.lastError == 'EMAIL_ALREADY_EXISTS') {
        _showError('Este email ya está registrado. Intenta iniciar sesión.');
      } else if (_authService.lastError == 'INVALID_CREDENTIALS') {
        _showError('Email o contraseña incorrectos');
      } else {
        final errorMsg = _authService.lastError ?? 'Error desconocido';
        _showError('Error al ${_isSignUp ? "registrarse" : "iniciar sesión"}\n\n$errorMsg');
      }
    }
  }

  Future<void> _playAsGuest() async {
    if (_nicknameController.text.isEmpty) {
      _showError('Por favor ingresa un nickname');
      return;
    }

    setState(() => _isLoading = true);
    final success = await _authService.signInAsGuest(_nicknameController.text.trim());
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/menu');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  void _showEmailConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Row(
          children: [
            Icon(Icons.email, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '✅ Registro Exitoso',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              '¡Te has registrado correctamente!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hemos enviado un email de confirmación a:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              _emailController.text,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '📧 Por favor revisa tu bandeja de entrada (o spam) y haz click en el link de confirmación.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Una vez confirmado, podrás iniciar sesión',
                      style: TextStyle(color: Colors.orange, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final email = _emailController.text;
              Navigator.pop(context);
              final sent = await _authService.resendConfirmationEmail(email);
              if (sent && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email reenviado ✅'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Reenviar Email', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Entendido', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  void _showEmailNotConfirmedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Email No Confirmado',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              'Tu cuenta aún no ha sido confirmada.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '📧 Por favor revisa tu email y haz click en el link de confirmación que te enviamos.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            const Text(
              'Email:',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              _emailController.text,
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: const Row(
                children: [
                  Icon(Icons.help_outline, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '¿No lo recibes? Revisa spam o reenvíalo',
                      style: TextStyle(color: Colors.blue, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final email = _emailController.text;
              Navigator.pop(context);
              final sent = await _authService.resendConfirmationEmail(email);
              if (sent && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email reenviado ✅'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Reenviar Email', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Entendido', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

