import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AuthResult {
  final bool success;
  final String? error;
  final bool isLocal;
  
  AuthResult({required this.success, this.error, this.isLocal = false});
}

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _uuid = const Uuid();
  String? lastError; // Para guardar el último error
  
  // Usuario actual (puede ser de Supabase o local)
  User? get currentUser => _supabase.auth.currentUser;
  
  // Verificar si está logueado (Supabase o local)
  Future<bool> get isLoggedIn async {
    if (currentUser != null) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') != null;
  }
  
  // Obtener perfil del usuario
  Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Si hay usuario de Supabase, usar ese
    if (currentUser != null) {
      // Obtener nickname actualizado de Supabase
      final nickname = await getNickname();
      
      return {
        'id': currentUser!.id,
        'email': currentUser!.email,
        'nickname': nickname,
        'avatar': prefs.getString('avatar') ?? '🐍',
      };
    }
    
    // Si no, usar perfil local
    final userId = prefs.getString('userId');
    if (userId != null) {
      return {
        'id': userId,
        'email': prefs.getString('email') ?? 'guest@local',
        'nickname': prefs.getString('nickname') ?? 'Player',
        'avatar': prefs.getString('avatar') ?? '🐍',
      };
    }
    
    return null;
  }
  
  // Iniciar sesión
  Future<bool> signIn(String email, String password) async {
    try {
      print('🔐 Intentando login con: $email');
      lastError = null;
      
      // Intentar con Supabase
      try {
        print('🔄 Conectando a Supabase...');
        final response = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        
        print('📩 Respuesta de Supabase recibida');
        print('   Usuario: ${response.user?.id}');
        
        if (response.user != null) {
          print('✅ Login exitoso con Supabase');
          
          // Obtener nickname de la base de datos
          final prefs = await SharedPreferences.getInstance();
          String nickname = email.split('@')[0]; // Fallback
          
          try {
            final profile = await _supabase
                .from('profiles')
                .select('nickname, avatar')
                .eq('id', response.user!.id)
                .single();
            
            nickname = profile['nickname'] ?? nickname;
            print('✅ Perfil cargado desde Supabase: $nickname');
          } catch (profileError) {
            print('⚠️ Error cargando perfil: $profileError');
            // Intentar obtener de metadata del usuario
            if (response.user!.userMetadata?['nickname'] != null) {
              nickname = response.user!.userMetadata!['nickname'];
              print('✅ Nickname obtenido de metadata: $nickname');
            }
          }
          
          // Guardar nickname localmente
          await prefs.setString('nickname', nickname);
          await prefs.setString('userId', response.user!.id);
          await prefs.setString('email', email);
          await prefs.setString('avatar', '🐍');
          await prefs.remove('isLocal');
          await prefs.remove('pending_email');
          await prefs.remove('pending_nickname');
          
          print('✅ Login exitoso - Nickname: $nickname');
          return true;
        }
      } catch (supabaseError) {
        final errorMsg = supabaseError.toString();
        print('❌ ERROR DE SUPABASE LOGIN: $errorMsg');
        print('   Tipo: ${supabaseError.runtimeType}');
        
        // Verificar si es error de email no confirmado
        if (errorMsg.contains('Email not confirmed') || 
            errorMsg.contains('email_not_confirmed') ||
            errorMsg.contains('not confirmed')) {
          lastError = 'EMAIL_NOT_CONFIRMED';
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('pending_email', email);
          return false;
        }
        
        // Error de credenciales incorrectas
        if (errorMsg.contains('Invalid login credentials') || 
            errorMsg.contains('invalid_grant')) {
          lastError = 'INVALID_CREDENTIALS';
          return false;
        }
        
        lastError = 'ERROR SUPABASE: $errorMsg';
        print('⚠️ Intentando login local...');
      }
      
      // Fallback: Login local
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('email');
      final savedPassword = prefs.getString('password');
      
      if (savedEmail == email && savedPassword == password) {
        print('✅ Login exitoso con datos locales');
        return true;
      }
      
      print('❌ Credenciales incorrectas');
      lastError = 'INVALID_CREDENTIALS';
      return false;
    } catch (e) {
      print('❌ Error en login: $e');
      lastError = 'Error general: $e';
      return false;
    }
  }
  
  // Registrarse
  Future<bool> signUp(String email, String password, String nickname) async {
    try {
      print('📝 Intentando registro: $email / $nickname');
      lastError = null;
      
      final prefs = await SharedPreferences.getInstance();
      
      // Intentar con Supabase
      try {
        print('🔄 Conectando a Supabase...');
        final response = await _supabase.auth.signUp(
          email: email,
          password: password,
          data: {'nickname': nickname}, // Guardar nickname en metadata
        );
        
        print('📩 Respuesta de Supabase recibida');
        print('   Usuario: ${response.user?.id}');
        print('   Session: ${response.session?.accessToken != null ? "✅" : "❌"}');
        print('   Email confirmado: ${response.user?.emailConfirmedAt != null ? "✅" : "❌"}');
        
        if (response.user != null) {
          // Verificar si necesita confirmación de email
          if (response.user!.emailConfirmedAt == null) {
            print('📧 Email de confirmación enviado');
            lastError = 'CONFIRM_EMAIL'; // Flag especial
            await prefs.setString('pending_email', email);
            await prefs.setString('pending_nickname', nickname);
            return true;
          }
          
          print('✅ Registro exitoso con Supabase (email ya confirmado)');
          
          // Esperar un poco para que el trigger se ejecute
          await Future.delayed(Duration(milliseconds: 500));
          
          // Guardar nickname en la tabla de profiles
          try {
            // Usar upsert con onConflict para asegurar que se actualice
            await _supabase.from('profiles').upsert({
              'id': response.user!.id,
              'nickname': nickname,
              'avatar': '🐍',
              'updated_at': DateTime.now().toIso8601String(),
            }, onConflict: 'id');
            print('✅ Perfil guardado en Supabase con nickname: $nickname');
          } catch (profileError) {
            print('⚠️ Error guardando perfil: $profileError');
          }
          
          // Guardar datos localmente también
          await prefs.setString('userId', response.user!.id);
          await prefs.setString('email', email);
          await prefs.setString('nickname', nickname);
          await prefs.setString('avatar', '🐍');
          await prefs.remove('isLocal');
          await prefs.remove('pending_email');
          await prefs.remove('pending_nickname');
          
          print('✅ Usuario registrado en Supabase con ID: ${response.user!.id}');
          print('✅ Nickname guardado: $nickname');
          lastError = null;
          return true;
        } else {
          print('⚠️ Supabase no devolvió usuario');
          lastError = 'Supabase no devolvió usuario';
        }
      } catch (supabaseError) {
        final errorMsg = supabaseError.toString();
        print('❌ ERROR DE SUPABASE: $errorMsg');
        print('   Tipo: ${supabaseError.runtimeType}');
        
        // Verificar si es error de email ya registrado
        if (errorMsg.contains('already registered') || errorMsg.contains('already been registered')) {
          lastError = 'EMAIL_ALREADY_EXISTS';
          return false;
        }
        
        lastError = 'ERROR SUPABASE: $errorMsg';
        print('⚠️ Usando modo local como fallback');
      }
      
      // Fallback: Registro local
      final userId = _uuid.v4();
      await prefs.setString('userId', userId);
      await prefs.setString('email', email);
      await prefs.setString('password', password); // Solo para pruebas
      await prefs.setString('nickname', nickname);
      await prefs.setString('avatar', '🐍');
      await prefs.setBool('isLocal', true);
      
      print('✅ Registro exitoso local con ID: $userId');
      if (lastError == null) {
        lastError = 'LOCAL: Registrado localmente (Supabase no disponible)';
      }
      return true;
    } catch (e) {
      print('❌ Error en registro: $e');
      lastError = 'Error general: $e';
      return false;
    }
  }
  
  // Reenviar email de confirmación
  Future<bool> resendConfirmationEmail(String email) async {
    try {
      print('📧 Reenviando email de confirmación a: $email');
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      print('✅ Email reenviado');
      return true;
    } catch (e) {
      print('❌ Error reenviando email: $e');
      lastError = 'Error reenviando email: $e';
      return false;
    }
  }
  
  // Iniciar sesión como invitado
  Future<bool> signInAsGuest(String nickname) async {
    try {
      print('👤 Creando perfil de invitado: $nickname');
      
      final prefs = await SharedPreferences.getInstance();
      final userId = _uuid.v4();
      
      await prefs.setString('userId', userId);
      await prefs.setString('nickname', nickname);
      await prefs.setString('avatar', '🐍');
      await prefs.setBool('isGuest', true);
      await prefs.setBool('isLocal', true);
      
      print('✅ Invitado creado con ID: $userId');
      return true;
    } catch (e) {
      print('❌ Error en modo invitado: $e');
      return false;
    }
  }
  
  // Cerrar sesión
  Future<void> signOut() async {
    try {
      print('🚪 Cerrando sesión...');
      await _supabase.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✅ Sesión cerrada correctamente');
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
    }
  }
  
  // Obtener nickname actual
  Future<String> getNickname() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Intentar obtener de Supabase primero
    if (currentUser != null) {
      try {
        final profile = await _supabase
            .from('profiles')
            .select('nickname')
            .eq('id', currentUser!.id)
            .single();
        
        final nickname = profile['nickname'] as String?;
        if (nickname != null && nickname.isNotEmpty) {
          // Guardar localmente para uso offline
          await prefs.setString('nickname', nickname);
          return nickname;
        }
      } catch (e) {
        print('⚠️ Error obteniendo nickname de Supabase: $e');
      }
    }
    
    // Fallback a local
    return prefs.getString('nickname') ?? 'Player';
  }
  
  // Actualizar nickname
  Future<void> updateNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', nickname);
  }
}

