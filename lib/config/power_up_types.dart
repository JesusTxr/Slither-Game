import 'dart:ui';

/// Tipos de power-ups disponibles en el juego
enum PowerUpType {
  // Defensivos/Ayuda
  speedBoost,    // ⚡ Velocidad x2
  shield,        // 🛡️ Invulnerabilidad
  magnet,        // 🧲 Atrae comida
  ghostMode,     // 👻 Atraviesa jugadores
  doublePoints,  // 💎 Puntos x2
  
  // Ofensivos/Ataque
  dash,          // 🎯 Impulso rápido
  freeze,        // ❄️ Congela rivales
  shrinkRay,     // 📏 Reduce tamaño
  bomb,          // 💣 Explota segmentos
}

/// Rareza de los power-ups
enum PowerUpRarity {
  common,   // 60% - Comunes
  rare,     // 30% - Raros
  epic,     // 10% - Épicos
}

/// Configuración de un power-up
class PowerUpConfig {
  final PowerUpType type;
  final String name;
  final String emoji;
  final Color color;
  final PowerUpRarity rarity;
  final double duration; // Duración en segundos (0 = instantáneo)
  final String description;
  
  const PowerUpConfig({
    required this.type,
    required this.name,
    required this.emoji,
    required this.color,
    required this.rarity,
    required this.duration,
    required this.description,
  });
  
  /// Obtiene la configuración para un tipo de power-up
  static PowerUpConfig getConfig(PowerUpType type) {
    return _configs[type]!;
  }
  
  /// Todas las configuraciones de power-ups
  static final Map<PowerUpType, PowerUpConfig> _configs = {
    // DEFENSIVOS/AYUDA
    PowerUpType.speedBoost: PowerUpConfig(
      type: PowerUpType.speedBoost,
      name: 'Speed Boost',
      emoji: '⚡',
      color: Color(0xFFFFD700), // Dorado
      rarity: PowerUpRarity.common,
      duration: 5.0,
      description: 'Velocidad x2 por 5 segundos',
    ),
    
    PowerUpType.shield: PowerUpConfig(
      type: PowerUpType.shield,
      name: 'Shield',
      emoji: '🛡️',
      color: Color(0xFF00BFFF), // Azul cielo
      rarity: PowerUpRarity.common,
      duration: 8.0,
      description: 'Invulnerable por 8 segundos',
    ),
    
    PowerUpType.magnet: PowerUpConfig(
      type: PowerUpType.magnet,
      name: 'Magnet',
      emoji: '🧲',
      color: Color(0xFF9370DB), // Morado medio
      rarity: PowerUpRarity.common,
      duration: 10.0,
      description: 'Atrae comida cercana',
    ),
    
    PowerUpType.ghostMode: PowerUpConfig(
      type: PowerUpType.ghostMode,
      name: 'Ghost Mode',
      emoji: '👻',
      color: Color(0xFFFFFFFF), // Blanco
      rarity: PowerUpRarity.rare,
      duration: 6.0,
      description: 'Atraviesa jugadores sin morir',
    ),
    
    PowerUpType.doublePoints: PowerUpConfig(
      type: PowerUpType.doublePoints,
      name: 'Double Points',
      emoji: '💎',
      color: Color(0xFF00FF88), // Verde brillante
      rarity: PowerUpRarity.rare,
      duration: 15.0,
      description: 'Puntos x2 por 15 segundos',
    ),
    
    // OFENSIVOS/ATAQUE
    PowerUpType.dash: PowerUpConfig(
      type: PowerUpType.dash,
      name: 'Dash',
      emoji: '🎯',
      color: Color(0xFFFF8C00), // Naranja oscuro
      rarity: PowerUpRarity.rare,
      duration: 0.0, // Instantáneo
      description: 'Impulso rápido + estela peligrosa',
    ),
    
    PowerUpType.freeze: PowerUpConfig(
      type: PowerUpType.freeze,
      name: 'Freeze',
      emoji: '❄️',
      color: Color(0xFF00CED1), // Turquesa oscuro
      rarity: PowerUpRarity.epic,
      duration: 3.0,
      description: 'Congela jugadores cercanos',
    ),
    
    PowerUpType.shrinkRay: PowerUpConfig(
      type: PowerUpType.shrinkRay,
      name: 'Shrink Ray',
      emoji: '📏',
      color: Color(0xFFFF69B4), // Rosa caliente
      rarity: PowerUpRarity.epic,
      duration: 0.0, // Instantáneo
      description: 'Reduce tamaño de rivales 30%',
    ),
    
    PowerUpType.bomb: PowerUpConfig(
      type: PowerUpType.bomb,
      name: 'Bomb',
      emoji: '💣',
      color: Color(0xFFFF0000), // Rojo
      rarity: PowerUpRarity.epic,
      duration: 0.0, // Instantáneo
      description: 'Explota segmentos cercanos',
    ),
  };
  
  /// Obtiene un power-up aleatorio basado en rareza
  static PowerUpType getRandomPowerUp() {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    
    // 60% Común, 30% Raro, 10% Épico
    if (random < 60) {
      // Común
      final commons = [
        PowerUpType.speedBoost,
        PowerUpType.shield,
        PowerUpType.magnet,
      ];
      return commons[DateTime.now().microsecond % commons.length];
    } else if (random < 90) {
      // Raro
      final rares = [
        PowerUpType.ghostMode,
        PowerUpType.doublePoints,
        PowerUpType.dash,
      ];
      return rares[DateTime.now().microsecond % rares.length];
    } else {
      // Épico
      final epics = [
        PowerUpType.freeze,
        PowerUpType.shrinkRay,
        PowerUpType.bomb,
      ];
      return epics[DateTime.now().microsecond % epics.length];
    }
  }
}

