import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/multiplayer_menu_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/game_screen.dart';
import 'config/supabase_config.dart';

Future<void> main() async {
  // 1. Asegura que los bindings de Flutter estén listos
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // 3. Fija la orientación de la app a horizontal
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // 4. Ejecuta la app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // Un tema oscuro queda bien para juegos
      // 1. La ruta inicial verifica si hay sesión activa
      home: const SplashScreen(),
      // 2. Define las rutas de la aplicación
      routes: {
        '/login': (context) => const LoginScreen(),
        '/loading': (context) => const LoadingScreen(),
        '/menu': (context) => const MainMenuScreen(),
        '/multiplayer': (context) => const MultiplayerMenuScreen(),
        '/lobby': (context) => const LobbyScreen(),
        '/game': (context) => const GameScreen(),
      },
    );
  }
}

// Pantalla de splash que verifica la sesión
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 1)); // Pequeña pausa visual
    
    // Verificar si hay sesión activa en Supabase
    final session = Supabase.instance.client.auth.currentSession;
    
    if (mounted) {
      if (session != null) {
        // Hay sesión activa, ir al menú
        print('✅ Sesión activa encontrada: ${session.user.email}');
        Navigator.of(context).pushReplacementNamed('/menu');
      } else {
        // No hay sesión, ir al login
        print('❌ No hay sesión activa, ir al login');
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

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
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🐍',
                style: TextStyle(fontSize: 80),
              ),
              SizedBox(height: 20),
              Text(
                'SLITHER GAME',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}