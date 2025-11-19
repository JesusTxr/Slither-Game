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
    super.render(canvas);
    final center = (size / 2).toOffset();
    final radius = size.x / 2;
    
    // 1. Sombra suave para profundidad
    final shadowPaint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center + const Offset(2, 2), radius, shadowPaint);
    
    // 2. Cuerpo base ligeramente más grande para cubrir espacios
    final basePaint = Paint()
      ..color = skin.primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 1.08, basePaint);
    
    // 3. Gradiente radial mejorado para efecto 3D
    final gradientPaint = Paint()
      ..shader = Gradient.radial(
        center - Offset(radius * 0.3, radius * 0.3), // Luz desde arriba-izquierda
        radius * 1.2,
        [
          Color.lerp(skin.secondaryColor, const Color(0xFFFFFFFF), 0.4)!,
          skin.secondaryColor,
          skin.primaryColor,
          Color.lerp(skin.primaryColor, const Color(0xFF000000), 0.2)!,
        ],
        [0.0, 0.3, 0.7, 1.0],
      );
    canvas.drawCircle(center, radius, gradientPaint);
    
    // 4. Brillo especular (reflejo de luz)
    final shinePaint = Paint()
      ..shader = Gradient.radial(
        center - Offset(radius * 0.35, radius * 0.35),
        radius * 0.5,
        [
          const Color(0xFFFFFFFF).withOpacity(0.4),
          const Color(0xFFFFFFFF).withOpacity(0.15),
          const Color(0xFFFFFFFF).withOpacity(0.0),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawCircle(center, radius, shinePaint);
    
    // 5. Borde oscuro para definición
    final borderPaint = Paint()
      ..color = Color.lerp(skin.primaryColor, const Color(0xFF000000), 0.5)!.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius - 1, borderPaint);
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
