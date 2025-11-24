import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:slither_game/components/body_segment.dart';
import 'package:slither_game/game.dart';
import 'package:slither_game/config/snake_skins.dart';

class RemotePlayer extends PositionComponent
    with HasGameReference<SlitherGame> {
  final String playerId;
  final String nickname;
  final List<BodySegment> body = [];
  List<Vector2> pathPoints = [];
  int bodyLength;
  int score;
  final SnakeSkin skin;
    
  final double _speed = 150;
  final double segmentSpacing = 1.5; // Espaciado óptimo para aspecto de gusano
  double baseRadius = 10;
  double get currentRadius => baseRadius + (bodyLength * 0.1);
  
  // 🔄 Variables para interpolación suave mejorada
  Vector2? _targetPosition;
  Vector2? _lastPosition;
  Vector2? _velocity; // Velocidad actual para extrapolación
  double _interpolationSpeed = 15.0; // MUY rápido para eliminar lag visual
  final List<_PositionSnapshot> _positionBuffer = []; // Buffer de posiciones
  double _timeSinceLastUpdate = 0;
  final double _maxExtrapolationTime = 0.8; // Más tiempo de extrapolación
  
  RemotePlayer({
    required this.playerId,
    required this.nickname,
    required Vector2 position,
    this.bodyLength = 5,
    this.score = 0,
    SnakeSkin? skin,
  }) : skin = skin ?? SnakeSkins.random(),
       super(
         position: position, 
         anchor: Anchor.center,
         priority: 10, // Prioridad alta para renderizar por encima del cuerpo
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2.all(currentRadius * 2);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final center = (size / 2).toOffset();
    final radius = size.x / 2;
    
    // Calcular ángulo de dirección
    final angle = _calculateDirection();
    
    // 1. Sombra suave para profundidad
    final shadowPaint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(center + const Offset(3, 3), radius, shadowPaint);
    
    // 2. Cuerpo base ligeramente más grande para conexión con el cuerpo
    final basePaint = Paint()
      ..color = skin.primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 1.12, basePaint);
    
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
    
    // 7. Dibujar el nickname encima
    final textPainter = TextPainter(
      text: TextSpan(
        text: nickname,
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        -textPainter.height - 10,
      ),
    );
  }
  
  double _calculateDirection() {
    if (pathPoints.length >= 2) {
      final current = pathPoints[pathPoints.length - 1];
      final previous = pathPoints[pathPoints.length - 2];
      final direction = current - previous;
      if (direction.length2 > 0) {
        return math.atan2(direction.y, direction.x);
      }
    }
    return 0.0; // Dirección por defecto (derecha)
  }
  
  void _drawEyes(Canvas canvas, Offset center, double radius, double angle) {
    // Tamaño de los ojos basado en el radio (más grandes para mejor visibilidad)
    final eyeSize = radius * 0.35;
    final eyeDistance = radius * 0.45;
    
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
      ..color = const Color(0xFF000000).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(position + const Offset(1.5, 1.5), size * 1.1, eyeShadowPaint);
    
    // Contorno blanco para que el ojo resalte
    final whiteOutlinePaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, size * 1.15, whiteOutlinePaint);
    
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

  void updatePosition(Vector2 newPosition) {
    // En lugar de cambiar la posición instantáneamente, establecer como objetivo
    _lastPosition = position.clone();
    _targetPosition = newPosition.clone();
    _timeSinceLastUpdate = 0; // Reiniciar timer
    
    // Calcular velocidad estimada con mayor precisión
    if (_lastPosition != null) {
      final delta = newPosition - _lastPosition!;
      // Factor más alto para compensar latencia y mantener movimiento fluido
      _velocity = delta * 60; // Asumiendo 60 FPS para predicción más agresiva
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    size = Vector2.all(currentRadius * 2);
    
    _timeSinceLastUpdate += dt;
    
    // 🔄 Sistema de interpolación mejorado con extrapolación
    if (_targetPosition != null) {
      final distance = (_targetPosition! - position).length;
      
      if (distance > 0.5) {
        // Calcular velocidad suave
        final direction = (_targetPosition! - position).normalized();
        
        // Interpolación MUY adaptativa (mucho más rápida)
        final adaptiveSpeed = _interpolationSpeed * (1.5 + (distance / 50.0).clamp(0.0, 4.0));
        final moveDistance = adaptiveSpeed * distance * dt;
        
        // Mover hacia el objetivo (más agresivo)
        final movement = direction * moveDistance.clamp(0, distance);
        position += movement;
        
        // Actualizar velocidad para extrapolación
        _velocity = movement / dt;
        
        // Agregar al path si nos movimos lo suficiente
        if (pathPoints.isEmpty || (position - pathPoints.last).length > segmentSpacing) {
          pathPoints.add(position.clone());
        }
      } else {
        // Si estamos muy cerca, saltar directamente
        position = _targetPosition!.clone();
        _velocity = Vector2.zero();
      }
    } else if (_velocity != null && _timeSinceLastUpdate < _maxExtrapolationTime) {
      // 🚀 Extrapolación AGRESIVA: continuar movimiento cuando no hay datos nuevos
      // Reducir más lentamente para mantener movimiento fluido por más tiempo
      final extrapolationFactor = 1.0 - ((_timeSinceLastUpdate / _maxExtrapolationTime) * 0.7);
      final movement = _velocity! * dt * extrapolationFactor.clamp(0.3, 1.0);
      position += movement;
      
      // Agregar al path
      if (pathPoints.isEmpty || (position - pathPoints.last).length > segmentSpacing) {
        pathPoints.add(position.clone());
      }
    }
    
    // Hacer crecer el cuerpo según bodyLength
    if (body.length < bodyLength) {
      final segment = BodySegment(
        position: position,
        ownerId: playerId,  // Marcar el segmento con el ID del jugador
        skin: skin,  // 🎨 Usar el mismo skin que la cabeza
      );
      game.world.add(segment);
      body.add(segment);
    }
    
    // Actualizar posiciones de los segmentos del cuerpo (más juntos)
    if (pathPoints.isNotEmpty) {
      for (var i = 0; i < body.length; i++) {
        final pointIndex = pathPoints.length - 1 - (i * 1); // Cambiado de 3 a 1 para más densidad
        if (pointIndex >= 0) {
          body[i].position = pathPoints[pointIndex];
        }
      }
    }
    
    // Limpiar puntos antiguos del camino
    final lastSegmentIndex =
        pathPoints.length - 1 - ((body.length - 1) * 1);
    if (lastSegmentIndex > 10) {
      pathPoints.removeRange(0, lastSegmentIndex - 10);
    }
  }
  
  @override
  void onRemove() {
    // Remover todos los segmentos del cuerpo
    for (var segment in body) {
      segment.removeFromParent();
    }
    body.clear();
    super.onRemove();
  }
}

// Clase auxiliar para el buffer de posiciones
class _PositionSnapshot {
  final Vector2 position;
  final double timestamp;
  
  _PositionSnapshot(this.position, this.timestamp);
}

