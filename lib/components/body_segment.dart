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

  final _paint = Paint()
    ..color = const Color(0xFF00AA00)
    ..style = PaintingStyle.fill;
  
  final _borderPaint = Paint()
    ..color = const Color(0xFF006600)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
    
  bool _hitboxAdded = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // El hitbox se agregará cuando el tamaño esté definido
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = (size / 2).toOffset();
    final radius = size.x / 2;
    
    // Dibujar el cuerpo principal
    canvas.drawCircle(center, radius, _paint);
    
    // Dibujar borde oscuro para definición
    canvas.drawCircle(center, radius, _borderPaint);
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
