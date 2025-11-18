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
  
  final _paint = Paint()..color = const Color(0xFF0088FF); // Azul para otros jugadores
  final double _speed = 150;
  final double segmentSpacing = 5.0;
  double baseRadius = 10;
  double get currentRadius => baseRadius + (bodyLength * 0.1);
  
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
    
    // Dibujar la cabeza
    canvas.drawCircle((size / 2).toOffset(), size.x / 2, _paint);
    
    // Dibujar el nickname encima
    final textPainter = TextPainter(
      text: TextSpan(
        text: nickname,
        style: TextStyle(
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
    position = newPosition;
    
    if (pathPoints.isEmpty ||
        (position - pathPoints.last).length > segmentSpacing) {
      pathPoints.add(position.clone());
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    size = Vector2.all(currentRadius * 2);
    
    // Hacer crecer el cuerpo según bodyLength
    if (body.length < bodyLength) {
      final segment = BodySegment(
        position: position,
        ownerId: playerId,  // Marcar el segmento con el ID del jugador
      );
      game.world.add(segment);
      body.add(segment);
    }
    
    // Actualizar posiciones de los segmentos del cuerpo
    if (pathPoints.isNotEmpty) {
      for (var i = 0; i < body.length; i++) {
        final pointIndex = pathPoints.length - 1 - (i * 3);
        if (pointIndex >= 0) {
          body[i].position = pathPoints[pointIndex];
        }
      }
    }
    
    // Limpiar puntos antiguos del camino
    final lastSegmentIndex =
        pathPoints.length - 1 - ((body.length - 1) * 3);
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

