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
  }) : super(
        anchor: Anchor.center,
        priority: 0, // Prioridad baja para renderizar detrás de la cabeza
      );
    
  bool _hitboxAdded = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // El hitbox se agregará cuando el tamaño esté definido
  }

  @override
  void render(Canvas canvas) {
    // ⚡ OPTIMIZACIÓN: Culling - no renderizar si está fuera de cámara
    final camera = game.cameraComponent;
    final visibleRect = camera.visibleWorldRect;
    
    // Crear un rectángulo pequeño alrededor del segmento
    final segmentRect = Rect.fromCenter(
      center: position.toOffset(),
      width: size.x,
      height: size.y,
    );
    
    // Si el segmento está completamente fuera de la vista, no renderizarlo
    if (!visibleRect.overlaps(segmentRect)) {
      return;
    }
    
    super.render(canvas);
    final center = (size / 2).toOffset();
    final radius = size.x / 2;
    
    // ⚡ OPTIMIZADO: Renderizado simplificado (menos operaciones)
    
    // 1. Sombra (solo 1 drawCircle)
    final shadowPaint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.12);
    canvas.drawCircle(center + const Offset(1.5, 1.5), radius, shadowPaint);
    
    // 2. Cuerpo base
    final basePaint = Paint()
      ..color = skin.primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 1.08, basePaint);
    
    // 3. Gradiente simplificado (2 colores)
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
    
    // 4. Brillo simple (1 círculo transparente)
    final shinePaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.2);
    canvas.drawCircle(center - Offset(radius * 0.3, radius * 0.3), radius * 0.35, shinePaint);
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
