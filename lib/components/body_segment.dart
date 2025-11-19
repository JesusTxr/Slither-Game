import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:slither_game/game.dart';
import 'package:slither_game/config/snake_skins.dart';

class BodySegment extends PositionComponent 
    with HasGameReference<SlitherGame>, CollisionCallbacks {
  final String? ownerId; // ID del jugador dueño del segmento
  final SnakeSkin skin;
  
  BodySegment({
    required super.position,
    this.ownerId,
    this.skin = SnakeSkins.classic,
  }) : super(anchor: Anchor.center);
    
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
    
    // Dibujar el cuerpo principal con gradiente
    final bodyPaint = skin.getBodyPaint(radius);
    canvas.drawCircle(center, radius, bodyPaint);
    
    // Dibujar borde para definición
    canvas.drawCircle(center, radius, skin.getBorderPaint());
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
