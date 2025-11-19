import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:slither_game/components/food.dart';
import 'package:slither_game/components/body_segment.dart';
import 'package:slither_game/game.dart';
import 'package:slither_game/config/snake_skins.dart';

class PlayerHead extends PositionComponent
    with HasGameReference<SlitherGame>, CollisionCallbacks {
  PlayerHead({required Vector2 startPosition, this.skin = SnakeSkins.classic})
    : super(position: startPosition, anchor: Anchor.center);

  final SnakeSkin skin;
    
  final double _speed = 150;
  final double segmentSpacing = 2.0; // Reducido para que los segmentos estén más juntos
  List<Vector2> pathPoints = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = (size / 2).toOffset();
    final radius = size.x / 2;
    
    // Calcular ángulo de dirección
    final direction = game.targetDirection;
    final angle = math.atan2(direction.y, direction.x);
    
    // Dibujar la cabeza principal con gradiente
    final bodyPaint = skin.getBodyPaint(radius);
    canvas.drawCircle(center, radius, bodyPaint);
    
    // Dibujar borde para definición
    canvas.drawCircle(center, radius, skin.getBorderPaint());
    
    // Dibujar ojos
    _drawEyes(canvas, center, radius, angle);
  }
  
  void _drawEyes(Canvas canvas, Offset center, double radius, double angle) {
    // Tamaño de los ojos basado en el radio
    final eyeSize = radius * 0.25;
    final eyeDistance = radius * 0.4;
    
    // Posición de los ojos (relativa a la dirección)
    final eyeOffset = Offset(
      math.cos(angle) * eyeDistance,
      math.sin(angle) * eyeDistance,
    );
    
    // Perpendicular para separar los ojos
    final perpendicular = Offset(
      -math.sin(angle) * (radius * 0.35),
      math.cos(angle) * (radius * 0.35),
    );
    
    // Ojo izquierdo
    final leftEyePos = center + eyeOffset + perpendicular;
    _drawEye(canvas, leftEyePos, eyeSize, angle);
    
    // Ojo derecho
    final rightEyePos = center + eyeOffset - perpendicular;
    _drawEye(canvas, rightEyePos, eyeSize, angle);
  }
  
  void _drawEye(Canvas canvas, Offset position, double size, double angle) {
    // Blanco del ojo
    final whitePaint = Paint()
      ..color = skin.eyeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, size, whitePaint);
    
    // Borde del ojo
    final eyeBorderPaint = Paint()
      ..color = skin.eyeColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(position, size, eyeBorderPaint);
    
    // Pupila (ligeramente hacia adelante)
    final pupilOffset = Offset(
      math.cos(angle) * (size * 0.3),
      math.sin(angle) * (size * 0.3),
    );
    final pupilPaint = Paint()
      ..color = skin.pupilColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position + pupilOffset, size * 0.4, pupilPaint);
    
    // Brillo en el ojo
    final shinePaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      position + Offset(-size * 0.2, -size * 0.2),
      size * 0.25,
      shinePaint,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    size = Vector2.all(game.currentRadius * 2);
    // Usar directamente la dirección del juego (ya está normalizada)
    position += game.targetDirection * _speed * dt;

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
    
    // Colisión con segmento de cuerpo de otro jugador
    if (other is BodySegment) {
      // Verificar que no sea mi propio cuerpo
      final myPlayerId = game.networkService?.playerId;
      if (other.ownerId != null && other.ownerId != myPlayerId) {
        print('💥 ¡Colisión! Chocaste con el jugador: ${other.ownerId}');
        game.onPlayerDeath();
      }
    }
  }
}
