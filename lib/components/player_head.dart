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
    
    // 1. Sombra (usando paint cacheado)
    canvas.drawCircle(center + const Offset(3, 3), radius, _shadowPaint);
    
    // 2. Cuerpo base (usando paint cacheado)
    canvas.drawCircle(center, radius * 1.12, _basePaint);
    
    // 3. ⚡ OPTIMIZADO: Gradiente simplificado (2 colores)
    final gradientPaint = Paint()
      ..shader = Gradient.radial(
        center - Offset(radius * 0.3, radius * 0.3),
        radius * 1.2,
        [
          skin.secondaryColor,
          skin.primaryColor,
        ],
        [0.0, 1.0],
      );
    canvas.drawCircle(center, radius, gradientPaint);
    
    // 4. ⚡ OPTIMIZADO: Brillo simplificado
    final shinePaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.25);
    canvas.drawCircle(center - Offset(radius * 0.3, radius * 0.3), radius * 0.4, shinePaint);
    
    // 5. Borde (usando paint cacheado)
    canvas.drawCircle(center, radius - 1, _borderPaint);
    
    // 6. ⚡ OPTIMIZADO: Ojos simplificados
    _drawSimpleEyes(canvas, center, radius, angle);
    
    // ❄️ Efecto visual de congelación
    if (game.isFrozen) {
      // Overlay azul semitransparente
      final frozenPaint = Paint()
        ..color = const Color(0xFF00CED1).withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, frozenPaint);
      
      // Borde de hielo
      final iceBorderPaint = Paint()
        ..color = const Color(0xFF87CEEB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(center, radius, iceBorderPaint);
      
      // Cristales de hielo (decorativos)
      final crystalPaint = Paint()
        ..color = const Color(0xFFFFFFFF).withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      for (int i = 0; i < 6; i++) {
        final angle = (i * math.pi / 3);
        final start = center + Offset(math.cos(angle) * radius * 0.3, math.sin(angle) * radius * 0.3);
        final end = center + Offset(math.cos(angle) * radius * 0.8, math.sin(angle) * radius * 0.8);
        canvas.drawLine(start, end, crystalPaint);
      }
    }
  }
  
  // ⚡ OPTIMIZADO: Ojos simplificados (4 círculos en lugar de 10+)
  void _drawSimpleEyes(Canvas canvas, Offset center, double radius, double angle) {
    final eyeSize = radius * 0.3;
    final eyeDistance = radius * 0.4;
    
    // Posición de los ojos
    final eyeOffset = Offset(
      math.cos(angle) * eyeDistance,
      math.sin(angle) * eyeDistance,
    );
    final perpendicular = Offset(
      -math.sin(angle) * (radius * 0.3),
      math.cos(angle) * (radius * 0.3),
    );
    
    // Paints simples y reutilizables
    final whitePaint = Paint()..color = skin.eyeColor;
    final pupilPaint = Paint()..color = skin.pupilColor;
    
    // Ojo izquierdo
    final leftEyePos = center + eyeOffset + perpendicular;
    canvas.drawCircle(leftEyePos, eyeSize, whitePaint);
    canvas.drawCircle(leftEyePos + Offset(math.cos(angle) * eyeSize * 0.25, math.sin(angle) * eyeSize * 0.25), eyeSize * 0.4, pupilPaint);
    
    // Ojo derecho
    final rightEyePos = center + eyeOffset - perpendicular;
    canvas.drawCircle(rightEyePos, eyeSize, whitePaint);
    canvas.drawCircle(rightEyePos + Offset(math.cos(angle) * eyeSize * 0.25, math.sin(angle) * eyeSize * 0.25), eyeSize * 0.4, pupilPaint);
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
