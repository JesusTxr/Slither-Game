import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;
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
  final double segmentSpacing = 2.0; // Reducido para que los segmentos estén más juntos
  double baseRadius = 10;
  double get currentRadius => baseRadius + (bodyLength * 0.1);
  
  // 🔄 Variables para interpolación suave
  Vector2? _targetPosition;
  double _interpolationSpeed = 8.0; // Qué tan rápido se interpola (mayor = más rápido)
  
  RemotePlayer({
    required this.playerId,
    required this.nickname,
    required Vector2 position,
    this.bodyLength = 5,
    this.score = 0,
    SnakeSkin? skin,
  }) : skin = skin ?? SnakeSkins.random(),
       super(position: position, anchor: Anchor.center);

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
    
    // Dibujar la cabeza principal con gradiente
    final bodyPaint = skin.getBodyPaint(radius);
    canvas.drawCircle(center, radius, bodyPaint);
    
    // Dibujar borde para definición
    canvas.drawCircle(center, radius, skin.getBorderPaint());
    
    // Dibujar ojos
    _drawEyes(canvas, center, radius, angle);
    
    // Dibujar el nickname encima
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
    // Blanco del ojo
    final whitePaint = Paint()
      ..color = skin.eyeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, size, whitePaint);
    
    // Borde del ojo
    final eyeBorderPaint = Paint()
      ..color = skin.eyeColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(position, size, eyeBorderPaint);
    
    // Pupila (ligeramente hacia adelante)
    final pupilOffset = Offset(
      math.cos(angle) * (size * 0.3),
      math.sin(angle) * (size * 0.3),
    );
    final pupilPaint = Paint()
      ..color = skin.pupilColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position + pupilOffset, size * 0.4, pupilPaint);
    
    // Brillo en el ojo
    final shinePaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      position + Offset(-size * 0.2, -size * 0.2),
      size * 0.25,
      shinePaint,
    );
  }

  void updatePosition(Vector2 newPosition) {
    // En lugar de cambiar la posición instantáneamente, establecer como objetivo
    _targetPosition = newPosition.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);
    size = Vector2.all(currentRadius * 2);
    
    // 🔄 Interpolación suave hacia la posición objetivo
    if (_targetPosition != null) {
      // Calcular la distancia a la posición objetivo
      final distance = (_targetPosition! - position).length;
      
      if (distance > 0.5) {
        // Interpolar suavemente hacia el objetivo
        final direction = (_targetPosition! - position).normalized();
        final moveDistance = _interpolationSpeed * distance * dt;
        
        // Mover hacia el objetivo
        final movement = direction * moveDistance;
        position += movement;
        
        // Agregar al path si nos movimos lo suficiente
        if (pathPoints.isEmpty ||
            (position - pathPoints.last).length > segmentSpacing) {
          pathPoints.add(position.clone());
        }
      } else {
        // Si estamos muy cerca, saltar directamente
        position = _targetPosition!.clone();
        _targetPosition = null;
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

