import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:slither_game/components/body_segment.dart';
import 'package:slither_game/game.dart';

class RemotePlayer extends PositionComponent
    with HasGameReference<SlitherGame> {
  final String playerId;
  final String nickname;
  final List<BodySegment> body = [];
  List<Vector2> pathPoints = [];
  int bodyLength;
  int score;
  
  final _paint = Paint()
    ..color = const Color(0xFF0088FF)
    ..style = PaintingStyle.fill; // Azul para otros jugadores
  
  final _borderPaint = Paint()
    ..color = const Color(0xFF0055AA)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;
    
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
  }) : super(position: position, anchor: Anchor.center);

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
    
    // Dibujar la cabeza principal
    canvas.drawCircle(center, radius, _paint);
    
    // Dibujar borde para definición
    canvas.drawCircle(center, radius, _borderPaint);
    
    // Dibujar el nickname encima
    final textPainter = TextPainter(
      text: TextSpan(
        text: nickname,
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 12,
          fontWeight: FontWeight.bold,
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

