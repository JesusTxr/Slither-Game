import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:slither_game/config/power_up_types.dart';
import 'package:slither_game/game.dart';

class PowerUp extends PositionComponent with HasGameReference<SlitherGame> {
  final String id;
  final PowerUpType type;
  late final PowerUpConfig config;
  double _rotation = 0;
  double _pulseScale = 1.0;
  double _pulseDirection = 1.0;
  
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
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Rotación constante
    _rotation += dt * 2;
    
    // Efecto de pulsación
    _pulseScale += _pulseDirection * dt * 0.5;
    if (_pulseScale > 1.15) {
      _pulseScale = 1.15;
      _pulseDirection = -1;
    } else if (_pulseScale < 0.95) {
      _pulseScale = 0.95;
      _pulseDirection = 1;
    }
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final center = (size / 2).toOffset();
    final radius = size.x / 2;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(_pulseScale);
    canvas.rotate(_rotation);
    canvas.translate(-center.dx, -center.dy);
    
    // 1. Aura exterior (glow)
    final auraPaint = Paint()
      ..shader = Gradient.radial(
        center,
        radius * 1.5,
        [
          config.color.withOpacity(0.4),
          config.color.withOpacity(0.2),
          config.color.withOpacity(0.0),
        ],
        [0.0, 0.7, 1.0],
      );
    canvas.drawCircle(center, radius * 1.5, auraPaint);
    
    // 2. Borde exterior brillante
    final outerBorderPaint = Paint()
      ..color = config.color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius * 0.9, outerBorderPaint);
    
    // 3. Caja principal con gradiente
    final boxPaint = Paint()
      ..shader = Gradient.radial(
        center - Offset(radius * 0.3, radius * 0.3),
        radius,
        [
          Color.lerp(config.color, const Color(0xFFFFFFFF), 0.3)!,
          config.color,
          Color.lerp(config.color, const Color(0xFF000000), 0.3)!,
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawCircle(center, radius * 0.8, boxPaint);
    
    // 4. Brillo especular
    final shinePaint = Paint()
      ..shader = Gradient.radial(
        center - Offset(radius * 0.4, radius * 0.4),
        radius * 0.5,
        [
          const Color(0xFFFFFFFF).withOpacity(0.6),
          const Color(0xFFFFFFFF).withOpacity(0.2),
          const Color(0xFFFFFFFF).withOpacity(0.0),
        ],
        [0.0, 0.6, 1.0],
      );
    canvas.drawCircle(center, radius * 0.8, shinePaint);
    
    // 5. Borde interior
    final innerBorderPaint = Paint()
      ..color = Color.lerp(config.color, const Color(0xFF000000), 0.4)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.75, innerBorderPaint);
    
    // 6. Indicador de rareza (estrellas para épicos)
    if (config.rarity == PowerUpRarity.epic) {
      _drawStars(canvas, center, radius);
    }
    
    canvas.restore();
    
    // 7. Emoji/ícono en el centro
    _drawEmoji(canvas, center);
  }
  
  void _drawStars(Canvas canvas, Offset center, double radius) {
    final starPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    
    // 3 pequeñas estrellas giratorias
    for (int i = 0; i < 3; i++) {
      final angle = (_rotation * 2) + (i * (pi * 2 / 3));
      final starPos = center + Offset(
        cos(angle) * radius * 1.2,
        sin(angle) * radius * 1.2,
      );
      
      _drawStar(canvas, starPos, 3, starPaint);
    }
  }
  
  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * pi / 5) - (pi / 2);
      final x = center.dx + cos(angle) * size;
      final y = center.dy + sin(angle) * size;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  
  void _drawEmoji(Canvas canvas, Offset center) {
    final textPainter = TextPainter(
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
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }
}

