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
    
    // 1. Sombra suave para profundidad
    final shadowPaint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(center + const Offset(3, 3), radius, shadowPaint);
    
    // 2. Cuerpo base más grande para conexión perfecta con el cuerpo
    final basePaint = Paint()
      ..color = skin.primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 1.08, basePaint);
    
    // 3. Gradiente radial mejorado para efecto 3D
    final gradientPaint = Paint()
      ..shader = Gradient.radial(
        center - Offset(radius * 0.3, radius * 0.3), // Luz desde arriba-izquierda
        radius * 1.3,
        [
          Color.lerp(skin.secondaryColor, const Color(0xFFFFFFFF), 0.5)!,
          skin.secondaryColor,
          skin.primaryColor,
          Color.lerp(skin.primaryColor, const Color(0xFF000000), 0.25)!,
        ],
        [0.0, 0.25, 0.65, 1.0],
      );
    canvas.drawCircle(center, radius, gradientPaint);
    
    // 4. Brillo especular (reflejo de luz) - más pronunciado en la cabeza
    final shinePaint = Paint()
      ..shader = Gradient.radial(
        center - Offset(radius * 0.4, radius * 0.4),
        radius * 0.6,
        [
          const Color(0xFFFFFFFF).withOpacity(0.5),
          const Color(0xFFFFFFFF).withOpacity(0.2),
          const Color(0xFFFFFFFF).withOpacity(0.0),
        ],
        [0.0, 0.4, 1.0],
      );
    canvas.drawCircle(center, radius, shinePaint);
    
    // 5. Borde oscuro para definición
    final borderPaint = Paint()
      ..color = Color.lerp(skin.primaryColor, const Color(0xFF000000), 0.5)!.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius - 1, borderPaint);
    
    // 6. Dibujar ojos
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
    // Sombra del ojo
    final eyeShadowPaint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(position + const Offset(1, 1), size, eyeShadowPaint);
    
    // Blanco del ojo con gradiente sutil
    final whitePaint = Paint()
      ..shader = Gradient.radial(
        position - Offset(size * 0.2, size * 0.2),
        size,
        [
          skin.eyeColor,
          Color.lerp(skin.eyeColor, const Color(0xFF000000), 0.1)!,
        ],
        [0.0, 1.0],
      );
    canvas.drawCircle(position, size, whitePaint);
    
    // Borde del ojo más pronunciado
    final eyeBorderPaint = Paint()
      ..color = Color.lerp(skin.eyeColor, const Color(0xFF000000), 0.4)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(position, size, eyeBorderPaint);
    
    // Pupila (ligeramente hacia adelante)
    final pupilOffset = Offset(
      math.cos(angle) * (size * 0.3),
      math.sin(angle) * (size * 0.3),
    );
    final pupilPaint = Paint()
      ..shader = Gradient.radial(
        position + pupilOffset,
        size * 0.4,
        [
          skin.pupilColor,
          Color.lerp(skin.pupilColor, const Color(0xFF000000), 0.3)!,
        ],
        [0.7, 1.0],
      );
    canvas.drawCircle(position + pupilOffset, size * 0.4, pupilPaint);
    
    // Brillo principal en el ojo
    final shinePaint = Paint()
      ..shader = Gradient.radial(
        position + Offset(-size * 0.15, -size * 0.15),
        size * 0.35,
        [
          const Color(0xFFFFFFFF).withOpacity(0.8),
          const Color(0xFFFFFFFF).withOpacity(0.3),
          const Color(0xFFFFFFFF).withOpacity(0.0),
        ],
        [0.0, 0.6, 1.0],
      );
    canvas.drawCircle(
      position + Offset(-size * 0.15, -size * 0.15),
      size * 0.35,
      shinePaint,
    );
    
    // Brillo secundario (pequeño)
    final shineSecondaryPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      position + Offset(size * 0.25, size * 0.3),
      size * 0.15,
      shineSecondaryPaint,
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
