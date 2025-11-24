import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart' hide Gradient;
import 'package:slither_game/config/power_up_types.dart';
import 'package:slither_game/game.dart';

class PowerUp extends PositionComponent with HasGameReference<SlitherGame>, CollisionCallbacks {
  final String id;
  final PowerUpType type;
  late final PowerUpConfig config;
  double _rotation = 0;
  double _pulseScale = 1.0;
  double _pulseDirection = 1.0;
  
  // ⚡ OPTIMIZACIÓN: Cache del TextPainter
  late final TextPainter _cachedEmojiPainter;
  
  PowerUp({
    required this.id,
    required this.type,
    required Vector2 position,
  }) : super(
        position: position,
        anchor: Anchor.center,
        size: Vector2.all(40),
        priority: 5, // Por encima de comida pero debajo de jugadores
      );
  
  @override
  Future<void> onLoad() async {
    config = PowerUpConfig.getConfig(type);
    
    // ⚡ OPTIMIZACIÓN: Cachear TextPainter del emoji
    _cachedEmojiPainter = TextPainter(
      text: TextSpan(
        text: config.emoji,
        style: TextStyle(
          fontSize: size.x * 0.5,
          shadows: [
            Shadow(
              color: const Color(0xFF000000).withOpacity(0.5),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    _cachedEmojiPainter.layout();
    
    // 🎯 Agregar hitbox circular para detectar colisiones
    add(CircleHitbox(
      radius: 20,
      anchor: Anchor.center,
    ));
  }
  
  // ⚡ OPTIMIZACIÓN: Reducir frecuencia de animaciones
  double _animationTimer = 0;
  static const double _animationInterval = 0.05; // 20 FPS para animaciones
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // ⚡ OPTIMIZACIÓN: Actualizar animación solo cada 0.05s
    _animationTimer += dt;
    if (_animationTimer >= _animationInterval) {
      _animationTimer = 0;
      
      // Rotación constante
      _rotation += _animationInterval * 2;
      
      // Efecto de pulsación
      _pulseScale += _pulseDirection * _animationInterval * 0.5;
      if (_pulseScale > 1.15) {
        _pulseScale = 1.15;
        _pulseDirection = -1;
      } else if (_pulseScale < 0.95) {
        _pulseScale = 0.95;
        _pulseDirection = 1;
      }
    }
  }
  
  @override
  void render(Canvas canvas) {
    // ⚡ OPTIMIZACIÓN: Culling - no renderizar power-ups fuera de cámara
    final camera = game.cameraComponent;
    final visibleRect = camera.visibleWorldRect;
    
    final powerUpRect = Rect.fromCenter(
      center: position.toOffset(),
      width: size.x * 1.5, // Un poco más grande para incluir el aura
      height: size.y * 1.5,
    );
    
    // Si está fuera de la vista, no renderizar
    if (!visibleRect.overlaps(powerUpRect)) {
      return;
    }
    
    super.render(canvas);
    
    final center = (size / 2).toOffset();
    final radius = size.x / 2;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(_pulseScale);
    canvas.rotate(_rotation);
    canvas.translate(-center.dx, -center.dy);
    
    // ⚡ OPTIMIZADO: Renderizado simplificado (menos gradientes)
    
    // 1. Aura exterior simplificada (1 color)
    final auraPaint = Paint()
      ..color = config.color.withOpacity(0.3);
    canvas.drawCircle(center, radius * 1.3, auraPaint);
    
    // 2. Cuerpo principal con gradiente simplificado (2 colores)
    final boxPaint = Paint()
      ..shader = Gradient.radial(
        center - Offset(radius * 0.3, radius * 0.3),
        radius,
        [
          Color.lerp(config.color, const Color(0xFFFFFFFF), 0.2)!,
          config.color,
        ],
        [0.0, 1.0],
      );
    canvas.drawCircle(center, radius * 0.8, boxPaint);
    
    // 3. Brillo simple
    final shinePaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.3);
    canvas.drawCircle(center - Offset(radius * 0.3, radius * 0.3), radius * 0.3, shinePaint);
    
    // 4. Borde
    final borderPaint = Paint()
      ..color = Color.lerp(config.color, const Color(0xFF000000), 0.4)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.75, borderPaint);
    
    // 6. Indicador de rareza (estrellas para épicos)
    if (config.rarity == PowerUpRarity.epic) {
      _drawStars(canvas, center, radius);
    }
    
    canvas.restore();
    
    // 7. Emoji/ícono en el centro
    _drawEmoji(canvas, center);
  }
  
  // ⚡ OPTIMIZADO: Estrellas simplificadas (círculos en lugar de paths)
  void _drawStars(Canvas canvas, Offset center, double radius) {
    final starPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    
    // 3 pequeños círculos dorados giratorios (más simple que estrellas)
    for (int i = 0; i < 3; i++) {
      final angle = (_rotation * 2) + (i * (pi * 2 / 3));
      final starPos = center + Offset(
        cos(angle) * radius * 1.2,
        sin(angle) * radius * 1.2,
      );
      
      canvas.drawCircle(starPos, 2.5, starPaint);
    }
  }
  
  // ⚡ OPTIMIZADO: Usar TextPainter cacheado
  void _drawEmoji(Canvas canvas, Offset center) {
    _cachedEmojiPainter.paint(
      canvas,
      center - Offset(_cachedEmojiPainter.width / 2, _cachedEmojiPainter.height / 2),
    );
  }
}

