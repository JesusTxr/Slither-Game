import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:slither_game/components/body_segment.dart';
import 'package:slither_game/components/dash_trail.dart';
import 'package:slither_game/components/food.dart';
import 'package:slither_game/components/power_up.dart';
import 'package:slither_game/config/snake_skins.dart';
import 'package:slither_game/game.dart';

class PlayerHead extends PositionComponent
    with HasGameReference<SlitherGame>, CollisionCallbacks {
  PlayerHead({required Vector2 startPosition, this.skin = SnakeSkins.classic})
    : super(
        position: startPosition, 
        anchor: Anchor.center,
        priority: 10, // Prioridad alta para renderizar por encima del cuerpo
      );

  final SnakeSkin skin;
    
  final double _speed = 150;
  final double segmentSpacing = 1.5; // Espaciado óptimo para aspecto de gusano
  List<Vector2> pathPoints = [];
  
  // ⚡ OPTIMIZACIÓN: Cache de Paints
  late final Paint _shadowPaint;
  late final Paint _basePaint;
  late final Paint _borderPaint;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
    
    // ⚡ OPTIMIZACIÓN: Cachear Paints
    _shadowPaint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    _basePaint = Paint()
      ..color = skin.primaryColor
      ..style = PaintingStyle.fill;
    
    _borderPaint = Paint()
      ..color = Color.lerp(skin.primaryColor, const Color(0xFF000000), 0.5)!.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = (size / 2).toOffset();
    final radius = size.x / 2;
    
    // Calcular ángulo de dirección
    final direction = game.targetDirection;
    final angle = math.atan2(direction.y, direction.x);
    
    // 🐍 CABEZA OVALADA ESTILO SLITHER.IO
    // Dimensiones de la cabeza ovalada (más ancha que alta)
    final headWidth = radius * 2.2;
    final headHeight = radius * 1.8;
    
    // Crear rectángulo para la cabeza ovalada
    final headRect = Rect.fromCenter(
      center: center,
      width: headWidth,
      height: headHeight,
    );
    
    // 1. Sombra de la cabeza ovalada
    canvas.save();
    canvas.translate(3, 3);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawOval(headRect, _shadowPaint);
    canvas.restore();
    
    // 2. Capa base oscura (profundidad)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -center.dy);
    
    final darkBasePaint = Paint()
      ..color = Color.lerp(skin.primaryColor, const Color(0xFF000000), 0.3)!;
    canvas.drawOval(headRect, darkBasePaint);
    
    // 3. Gradiente principal más realista (3 colores)
    final gradientPaint = Paint()
      ..shader = Gradient.radial(
        center - Offset(radius * 0.4, radius * 0.3),
        radius * 1.5,
        [
          Color.lerp(skin.secondaryColor, const Color(0xFFFFFFFF), 0.3)!,
          skin.secondaryColor,
          skin.primaryColor,
        ],
        [0.0, 0.5, 1.0],
      );
    final innerHeadRect = Rect.fromCenter(
      center: center,
      width: headWidth * 0.95,
      height: headHeight * 0.95,
    );
    canvas.drawOval(innerHeadRect, gradientPaint);
    
    // 4. Patrón de escamas (textura)
    _drawScalePattern(canvas, center, radius, angle);
    
    // 5. Brillo superior (efecto 3D)
    final shinePaint = Paint()
      ..shader = Gradient.radial(
        center - Offset(radius * 0.4, radius * 0.4),
        radius * 0.6,
        [
          const Color(0xFFFFFFFF).withOpacity(0.4),
          const Color(0xFFFFFFFF).withOpacity(0.0),
        ],
        [0.0, 1.0],
      );
    canvas.drawOval(
      Rect.fromCenter(
        center: center - Offset(radius * 0.2, radius * 0.2),
        width: headWidth * 0.5,
        height: headHeight * 0.4,
      ),
      shinePaint,
    );
    
    // 6. Borde exterior definido
    final borderPaint = Paint()
      ..color = Color.lerp(skin.primaryColor, const Color(0xFF000000), 0.6)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawOval(innerHeadRect, borderPaint);
    
    // 7. Borde interior sutil
    final innerBorderPaint = Paint()
      ..color = Color.lerp(skin.secondaryColor, const Color(0xFFFFFFFF), 0.2)!.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final innerBorderRect = Rect.fromCenter(
      center: center,
      width: headWidth * 0.85,
      height: headHeight * 0.85,
    );
    canvas.drawOval(innerBorderRect, innerBorderPaint);
    
    canvas.restore();
    
    // 8. Ojos mejorados (más grandes y expresivos)
    _drawEnhancedEyes(canvas, center, radius, angle);
    
    // ❄️ Efecto visual de congelación
    if (game.isFrozen) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.translate(-center.dx, -center.dy);
      
      // Overlay azul semitransparente
      final frozenPaint = Paint()
        ..color = const Color(0xFF00CED1).withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawOval(headRect, frozenPaint);
      
      // Borde de hielo
      final iceBorderPaint = Paint()
        ..color = const Color(0xFF87CEEB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawOval(headRect, iceBorderPaint);
      
      // Cristales de hielo (decorativos)
      final crystalPaint = Paint()
        ..color = const Color(0xFFFFFFFF).withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      for (int i = 0; i < 6; i++) {
        final crystalAngle = (i * math.pi / 3);
        final start = center + Offset(math.cos(crystalAngle) * radius * 0.3, math.sin(crystalAngle) * radius * 0.3);
        final end = center + Offset(math.cos(crystalAngle) * radius * 0.8, math.sin(crystalAngle) * radius * 0.8);
        canvas.drawLine(start, end, crystalPaint);
      }
      
      canvas.restore();
    }
  }
  
  // 🎨 Patrón de escamas para textura realista
  void _drawScalePattern(Canvas canvas, Offset center, double radius, double angle) {
    final scalePaint = Paint()
      ..color = Color.lerp(skin.primaryColor, const Color(0xFF000000), 0.15)!.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Dibujar líneas de escamas (patrón diagonal)
    for (int i = -2; i <= 2; i++) {
      final offset = i * radius * 0.3;
      final startX = center.dx - radius + offset;
      final startY = center.dy - radius * 0.5;
      final endX = center.dx + radius + offset;
      final endY = center.dy + radius * 0.5;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        scalePaint,
      );
    }
  }
  
  
  // 👁️ Ojos mejorados estilo Slither.io
  void _drawEnhancedEyes(Canvas canvas, Offset center, double radius, double angle) {
    final eyeSize = radius * 0.45; // Ojos más grandes
    final eyeDistance = radius * 0.5;
    
    // Posición de los ojos (adelante de la cabeza)
    final eyeOffset = Offset(
      math.cos(angle) * eyeDistance,
      math.sin(angle) * eyeDistance,
    );
    final perpendicular = Offset(
      -math.sin(angle) * (radius * 0.35),
      math.cos(angle) * (radius * 0.35),
    );
    
    // Paints para los ojos
    final eyeWhitePaint = Paint()..color = skin.eyeColor;
    final eyeShadowPaint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.2);
    final pupilPaint = Paint()..color = skin.pupilColor;
    final pupilShinePaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.6);
    
    // Ojo izquierdo
    final leftEyePos = center + eyeOffset + perpendicular;
    
    // Sombra del ojo
    canvas.drawCircle(leftEyePos + const Offset(1, 1), eyeSize, eyeShadowPaint);
    
    // Blanco del ojo con gradiente
    final eyeGradientPaint = Paint()
      ..shader = Gradient.radial(
        leftEyePos - Offset(eyeSize * 0.2, eyeSize * 0.2),
        eyeSize,
        [
          const Color(0xFFFFFFFF),
          skin.eyeColor,
        ],
        [0.0, 1.0],
      );
    canvas.drawCircle(leftEyePos, eyeSize, eyeGradientPaint);
    
    // Borde del ojo
    final eyeBorderPaint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(leftEyePos, eyeSize, eyeBorderPaint);
    
    // Pupila
    final pupilPos = leftEyePos + Offset(
      math.cos(angle) * eyeSize * 0.3,
      math.sin(angle) * eyeSize * 0.3,
    );
    canvas.drawCircle(pupilPos, eyeSize * 0.5, pupilPaint);
    
    // Brillo en la pupila
    canvas.drawCircle(
      pupilPos - Offset(eyeSize * 0.15, eyeSize * 0.15),
      eyeSize * 0.2,
      pupilShinePaint,
    );
    
    // Ojo derecho (mismo proceso)
    final rightEyePos = center + eyeOffset - perpendicular;
    
    // Sombra del ojo
    canvas.drawCircle(rightEyePos + const Offset(1, 1), eyeSize, eyeShadowPaint);
    
    // Blanco del ojo con gradiente
    final eyeGradientPaint2 = Paint()
      ..shader = Gradient.radial(
        rightEyePos - Offset(eyeSize * 0.2, eyeSize * 0.2),
        eyeSize,
        [
          const Color(0xFFFFFFFF),
          skin.eyeColor,
        ],
        [0.0, 1.0],
      );
    canvas.drawCircle(rightEyePos, eyeSize, eyeGradientPaint2);
    
    // Borde del ojo
    canvas.drawCircle(rightEyePos, eyeSize, eyeBorderPaint);
    
    // Pupila
    final pupilPos2 = rightEyePos + Offset(
      math.cos(angle) * eyeSize * 0.3,
      math.sin(angle) * eyeSize * 0.3,
    );
    canvas.drawCircle(pupilPos2, eyeSize * 0.5, pupilPaint);
    
    // Brillo en la pupila
    canvas.drawCircle(
      pupilPos2 - Offset(eyeSize * 0.15, eyeSize * 0.15),
      eyeSize * 0.2,
      pupilShinePaint,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    size = Vector2.all(game.currentRadius * 2);
    
    // ❄️ No moverse si está congelado
    if (!game.isFrozen) {
      // 🎮 CLIENT-SIDE PREDICTION: Movimiento instantáneo SIN esperar al servidor
      // Esto elimina completamente el lag de entrada
      position += game.targetDirection * _speed * game.speedMultiplier * dt;
    }

    // Lógica de límites del mapa (clamping)
    double currentRadius = (game as SlitherGame).currentRadius;
    // Límites X (Izquierda y Derecha)
    position.x = position.x.clamp(
      currentRadius, // Límite izquierdo
      (game as SlitherGame).worldSize.x - currentRadius, // Límite derecho
    );
    // Límites Y (Arriba y Abajo)
    position.y = position.y.clamp(
      currentRadius, // Límite superior
      (game as SlitherGame).worldSize.y - currentRadius, // Límite inferior
    );

    if (pathPoints.isEmpty ||
        (position - pathPoints.last).length > segmentSpacing) {
      pathPoints.add(position.clone());
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    // Colisión con comida
    if (other is Food) {
      other.removeFromParent();
      game.eatFood(foodId: other.id); // Pasar el ID de la comida
    }
    
    // 🎁 Colisión con power-up
    if (other is PowerUp) {
      game.collectPowerUp(other);
    }
    
    // 🎯 Colisión con estela de Dash
    if (other is DashTrail) {
      final myPlayerId = game.networkService?.playerId;
      // Solo morir si no es mi propia estela
      if (other.ownerId != myPlayerId) {
        // 🛡️ Verificar si está activo shield o ghost mode
        if (!game.isShieldActive && !game.isGhostMode) {
          print('💥 ¡Colisión con estela de Dash de ${other.ownerId}!');
          game.onPlayerDeath();
        } else {
          print('✨ ¡Estela de Dash evitada! Power-up activo');
        }
      }
    }
    
    // Colisión con segmento de cuerpo de otro jugador
    if (other is BodySegment) {
      // Verificar que no sea mi propio cuerpo
      final myPlayerId = game.networkService?.playerId;
      if (other.ownerId != null && other.ownerId != myPlayerId) {
        // 🛡️ Verificar si está activo shield o ghost mode
        if (!game.isShieldActive && !game.isGhostMode) {
          print('💥 ¡Colisión! Chocaste con el jugador: ${other.ownerId}');
          game.onPlayerDeath();
        } else {
          print('✨ ¡Colisión evitada! Power-up activo');
        }
      }
    }
  }
}
