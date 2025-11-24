import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:slither_game/game.dart';

class DashTrail extends PositionComponent with HasGameReference<SlitherGame>, CollisionCallbacks {
  final String ownerId; // ID del jugador que creó la estela
  double lifetime;
  final double maxLifetime = 2.0; // Dura 2 segundos
  
  DashTrail({
    required Vector2 position,
    required this.ownerId,
  }) : lifetime = 2.0,
       super(
        position: position,
        anchor: Anchor.center,
        size: Vector2.all(20),
        priority: 1, // Por encima de comida pero debajo de jugadores
      );
  
  @override
  Future<void> onLoad() async {
    // Agregar hitbox circular
    add(CircleHitbox(
      radius: 10,
      anchor: Anchor.center,
    ));
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Reducir tiempo de vida
    lifetime -= dt;
    
    // Eliminar cuando expire
    if (lifetime <= 0) {
      removeFromParent();
    }
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final center = (size / 2).toOffset();
    final radius = size.x / 2;
    
    // Calcular opacidad basada en el tiempo de vida restante
    final opacity = (lifetime / maxLifetime).clamp(0.0, 1.0);
    
    // 1. Aura exterior brillante (naranja)
    final auraPaint = Paint()
      ..shader = Gradient.radial(
        center,
        radius * 2,
        [
          Color(0xFFFF8C00).withOpacity(0.6 * opacity),
          Color(0xFFFF8C00).withOpacity(0.3 * opacity),
          Color(0xFFFF8C00).withOpacity(0.0),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawCircle(center, radius * 2, auraPaint);
    
    // 2. Núcleo naranja brillante
    final corePaint = Paint()
      ..shader = Gradient.radial(
        center,
        radius,
        [
          Color(0xFFFFD700).withOpacity(opacity), // Dorado
          Color(0xFFFF8C00).withOpacity(opacity), // Naranja
          Color(0xFFFF4500).withOpacity(opacity * 0.5), // Naranja rojizo
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawCircle(center, radius, corePaint);
    
    // 3. Borde peligroso
    final borderPaint = Paint()
      ..color = Color(0xFFFF0000).withOpacity(opacity * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.8, borderPaint);
    
    // 4. Chispas rotativas (efecto de energía)
    final sparkPaint = Paint()
      ..color = Color(0xFFFFFFFF).withOpacity(opacity * 0.9)
      ..style = PaintingStyle.fill;
    
    final time = (maxLifetime - lifetime) * 5; // Velocidad de rotación
    for (int i = 0; i < 4; i++) {
      final angle = (time + (i * 1.57)); // 90 grados entre cada chispa
      final sparkPos = center + Offset(
        radius * 0.6 * (1 + 0.2 * (i % 2)) * math.cos(angle),
        radius * 0.6 * (1 + 0.2 * (i % 2)) * math.sin(angle),
      );
      canvas.drawCircle(sparkPos, 2, sparkPaint);
    }
  }
}

