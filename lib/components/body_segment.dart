import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:slither_game/game.dart';

class BodySegment extends PositionComponent 
    with HasGameReference<SlitherGame>, CollisionCallbacks {
  final String? ownerId; // ID del jugador dueño del segmento
  
  BodySegment({
    required super.position,
    this.ownerId,
  }) : super(anchor: Anchor.center);

  final _paint = Paint()..color = const Color(0xFF008000);
  bool _hitboxAdded = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // El hitbox se agregará cuando el tamaño esté definido
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle((size / 2).toOffset(), size.x / 2, _paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    size = Vector2.all(game.currentRadius * 2);
    
    // Agregar hitbox solo una vez después de que el tamaño esté definido
    if (!_hitboxAdded && size.x > 0) {
      add(CircleHitbox());
      _hitboxAdded = true;
    }
  }
}
