import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:slither_game/components/food.dart';
import 'package:slither_game/components/body_segment.dart';
import 'package:slither_game/game.dart';

class PlayerHead extends PositionComponent
    with HasGameReference<SlitherGame>, CollisionCallbacks {
  PlayerHead({required Vector2 startPosition})
    : super(position: startPosition, anchor: Anchor.center);

  final _paint = Paint()
    ..color = const Color(0xFF00FF00)
    ..style = PaintingStyle.fill;
  
  final _borderPaint = Paint()
    ..color = const Color(0xFF00AA00)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;
    
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
    
    // Dibujar la cabeza principal
    canvas.drawCircle(center, radius, _paint);
    
    // Dibujar borde para definición
    canvas.drawCircle(center, radius, _borderPaint);
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
