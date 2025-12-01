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
    
    // 🐍 SEGMENTO MEJORADO ESTILO SLITHER.IO
    
    // 1. Sombra más suave
    final shadowPaint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(center + const Offset(2, 2), radius, shadowPaint);
    
    // 2. Capa base oscura (profundidad)
    final darkBasePaint = Paint()
      ..color = Color.lerp(skin.primaryColor, const Color(0xFF000000), 0.25)!;
    canvas.drawCircle(center, radius * 1.05, darkBasePaint);
    
    // 3. Gradiente principal más realista (3 colores)
    final gradientPaint = Paint()
      ..shader = Gradient.radial(
        center - Offset(radius * 0.35, radius * 0.35),
        radius * 1.3,
        [
          Color.lerp(skin.secondaryColor, const Color(0xFFFFFFFF), 0.25)!,
          skin.secondaryColor,
          skin.primaryColor,
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawCircle(center, radius, gradientPaint);
    
    // 4. Patrón de escamas sutil
    final scalePaint = Paint()
      ..color = Color.lerp(skin.primaryColor, const Color(0xFF000000), 0.12)!.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    
    // Líneas de escamas (menos que en la cabeza)
    for (int i = -1; i <= 1; i++) {
      final offset = i * radius * 0.4;
      canvas.drawLine(
        Offset(center.dx - radius * 0.6 + offset, center.dy - radius * 0.4),
        Offset(center.dx + radius * 0.6 + offset, center.dy + radius * 0.4),
        scalePaint,
      );
    }
    
    // 5. Brillo superior (efecto 3D)
    final shinePaint = Paint()
      ..shader = Gradient.radial(
        center - Offset(radius * 0.35, radius * 0.35),
        radius * 0.5,
        [
          const Color(0xFFFFFFFF).withOpacity(0.3),
          const Color(0xFFFFFFFF).withOpacity(0.0),
        ],
        [0.0, 1.0],
      );
    canvas.drawCircle(center - Offset(radius * 0.25, radius * 0.25), radius * 0.4, shinePaint);
    
    // 6. Borde exterior definido
    final borderPaint = Paint()
      ..color = Color.lerp(skin.primaryColor, const Color(0xFF000000), 0.5)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius * 0.95, borderPaint);
    
    // 7. Borde interior sutil
    final innerBorderPaint = Paint()
      ..color = Color.lerp(skin.secondaryColor, const Color(0xFFFFFFFF), 0.15)!.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius * 0.8, innerBorderPaint);
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
