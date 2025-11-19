import 'dart:io';

class GameConfig {
  // Configuración de red
  static bool isMultiplayer = false;
  
  // 🌐 MODO DE SERVIDOR
  // Cambia entre 'local' (red WiFi local) y 'render' (internet/nube)
  static const String serverMode = 'render'; // 'local' o 'render'
  
  // 🚀 URL del servidor en Render (Solo si serverMode = 'render')
  // Reemplaza con tu URL de Render después de desplegar
  // Ver RENDER_DEPLOYMENT.md para instrucciones completas
  static const String renderServerUrl = 'wss://slither-game.onrender.com';
  
  // ⚙️ CONFIGURACIÓN LOCAL (Solo si serverMode = 'local')
  // Configura SOLO esta variable con la IP de tu PC:
  static const String _pcIpAddress = '192.168.0.16'; // ← Tu IP de Wi-Fi
  
  // 🎯 URL DEL SERVIDOR (AUTOMÁTICO)
  static String get serverUrl {
    // Modo Render (Internet/Nube) - Funciona desde cualquier red WiFi
    if (serverMode == 'render') {
      return renderServerUrl;
    }
    
    // Modo Local (Red WiFi) - Solo funciona en tu red local
    // - Si es dispositivo físico (Android/iOS) → Usa IP de tu PC
    // - Si es emulador o web → Usa localhost
    if (Platform.isAndroid || Platform.isIOS) {
      // Es un teléfono/tablet real
      return 'ws://$_pcIpAddress:8080';
    } else {
      // Es emulador o prueba local
      return 'ws://localhost:8080';
    }
  }
  
  static String? playerNickname;
  
  // 📱 INSTRUCCIONES:
  // 
  // ═══════════════════════════════════════════════════════════════
  // 🌐 MODO RENDER (Juego Online - Desde cualquier WiFi)
  // ═══════════════════════════════════════════════════════════════
  // 1. Lee la guía completa: RENDER_DEPLOYMENT.md
  // 2. Despliega tu servidor en Render
  // 3. Copia tu URL de Render (ej: https://mi-servidor.onrender.com)
  // 4. Pégala en renderServerUrl usando wss:// (ej: wss://mi-servidor.onrender.com)
  // 5. Cambia serverMode a 'render'
  // 6. ¡Listo! Ahora puedes jugar desde cualquier red WiFi
  //
  // ═══════════════════════════════════════════════════════════════
  // 📡 MODO LOCAL (Solo tu red WiFi)
  // ═══════════════════════════════════════════════════════════════
  // 1. Obtén tu IP local:
  //    Windows PowerShell: ipconfig
  //    Mac/Linux Terminal: ifconfig
  //    Busca "IPv4 Address": 192.168.1.105 (ejemplo)
  // 2. Cambia arriba en _pcIpAddress:
  //    static const String _pcIpAddress = '192.168.1.105';
  // 3. Mantén serverMode en 'local'
  // 4. Inicia el servidor: cd server && dart server.dart
  // 5. ¡Listo! Funciona automáticamente en tu red WiFi
}

