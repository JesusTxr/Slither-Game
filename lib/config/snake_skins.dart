import 'dart:ui';
import 'package:flutter/material.dart' show Color;

/// Sistema de skins para las serpientes
class SnakeSkin {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color eyeColor;
  final Color pupilColor;
  final bool hasPattern;
  
  const SnakeSkin({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.eyeColor,
    this.pupilColor = const Color(0xFF000000),
    this.hasPattern = false,
  });
  
  /// Crea un gradiente para el cuerpo
  Paint getBodyPaint(double radius) {
    return Paint()
      ..shader = Gradient.radial(
        Offset.zero,
        radius,
        [
          secondaryColor,
          primaryColor,
          Color.fromRGBO(
            primaryColor.red,
            primaryColor.green,
            primaryColor.blue,
            0.8,
          ),
        ],
        [0.0, 0.7, 1.0],
      )
      ..style = PaintingStyle.fill;
  }
  
  /// Crea un paint para el borde
  Paint getBorderPaint() {
    return Paint()
      ..color = primaryColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
  }
}

/// Skins predefinidos disponibles
class SnakeSkins {
  static const classic = SnakeSkin(
    id: 'classic',
    name: 'Clásico',
    primaryColor: Color(0xFF00ff88),
    secondaryColor: Color(0xFF00cc66),
    eyeColor: Color(0xFFFFFFFF),
  );
  
  static const fire = SnakeSkin(
    id: 'fire',
    name: 'Fuego',
    primaryColor: Color(0xFFFF4444),
    secondaryColor: Color(0xFFFF8800),
    eyeColor: Color(0xFFFFFF00),
  );
  
  static const ocean = SnakeSkin(
    id: 'ocean',
    name: 'Océano',
    primaryColor: Color(0xFF0088FF),
    secondaryColor: Color(0xFF00DDFF),
    eyeColor: Color(0xFFFFFFFF),
  );
  
  static const royal = SnakeSkin(
    id: 'royal',
    name: 'Real',
    primaryColor: Color(0xFF8800FF),
    secondaryColor: Color(0xFFDD00FF),
    eyeColor: Color(0xFFFFD700),
  );
  
  static const toxic = SnakeSkin(
    id: 'toxic',
    name: 'Tóxico',
    primaryColor: Color(0xFFAAFF00),
    secondaryColor: Color(0xFFFFFF00),
    eyeColor: Color(0xFF00FF00),
  );
  
  static const shadow = SnakeSkin(
    id: 'shadow',
    name: 'Sombra',
    primaryColor: Color(0xFF333333),
    secondaryColor: Color(0xFF666666),
    eyeColor: Color(0xFFFF0000),
  );
  
  static const golden = SnakeSkin(
    id: 'golden',
    name: 'Dorado',
    primaryColor: Color(0xFFFFD700),
    secondaryColor: Color(0xFFFFAA00),
    eyeColor: Color(0xFF000000),
  );
  
  static const candy = SnakeSkin(
    id: 'candy',
    name: 'Dulce',
    primaryColor: Color(0xFFFF88FF),
    secondaryColor: Color(0xFFFFAAFF),
    eyeColor: Color(0xFFFFFFFF),
  );
  
  /// Lista de todos los skins disponibles
  static const List<SnakeSkin> all = [
    classic,
    fire,
    ocean,
    royal,
    toxic,
    shadow,
    golden,
    candy,
  ];
  
  /// Obtener skin por ID
  static SnakeSkin getById(String id) {
    return all.firstWhere(
      (skin) => skin.id == id,
      orElse: () => classic,
    );
  }
  
  /// Skin aleatorio para jugadores remotos
  static SnakeSkin random() {
    final randomIndex = DateTime.now().millisecondsSinceEpoch % all.length;
    return all[randomIndex];
  }
}

