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
  double _interpolationSpeed = 15.0; // ⚡ OPTIMIZADO: Balanceado (antes 25.0 muy agresivo)
  final List<_PositionSnapshot> _positionBuffer = []; // Buffer de posiciones
  double _timeSinceLastUpdate = 0;
  final double _maxExtrapolationTime = 0.5; // ⚡ OPTIMIZADO: 0.5s (antes 1.2s muy largo)
  
  // ⚡ OPTIMIZACIÓN: Cache del TextPainter para evitar reconstrucción cada frame
  late final TextPainter _cachedTextPainter;
  
  // ⚡ OPTIMIZACIÓN: Cache de Paints para evitar recrearlos
  late final Paint _shadowPaint;
  late final Paint _basePaint;
  late final Paint _borderPaint;
  
  // ⚡ OPTIMIZACIÓN: Reducir frecuencia de actualización de body segments
  double _bodyUpdateTimer = 0;
  static const double _bodyUpdateInterval = 0.033; // 30 FPS para body (suficiente)
  
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
    
    // ⚡ OPTIMIZACIÓN: Cachear TextPainter (solo se crea una vez)
    _cachedTextPainter = TextPainter(
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
    _cachedTextPainter.layout();
    
    // ⚡ OPTIMIZACIÓN: Cachear Paints comunes
    _shadowPaint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    _basePaint = Paint()
      ..color = skin.primaryColor
      ..style = PaintingStyle.fill;
    
    _borderPaint = Paint()
      ..color = Color.lerp(skin.primaryColor, const Color(0xFF000000), 0.5)!.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
  }

  @override
  void render(Canvas canvas) {
    // ⚡ OPTIMIZACIÓN: Culling - no renderizar si está fuera de cámara
    final camera = game.cameraComponent;
    final visibleRect = camera.visibleWorldRect;
    
    // Crear rectángulo alrededor del jugador
    final playerRect = Rect.fromCenter(
      center: position.toOffset(),
      width: size.x * 2, // Un poco más grande para suavizar entrada/salida
      height: size.y * 2,
    );
    
    // Si el jugador está completamente fuera de la vista, no renderizarlo
    if (!visibleRect.overlaps(playerRect)) {
      return; // ⚡ OPTIMIZACIÓN: Ahorra ~50% CPU con muchos jugadores
    }
    
    super.render(canvas);
    
    final center = (size / 2).toOffset();
    final radius = size.x / 2;
    
    // Calcular ángulo de dirección
    final angle = _calculateDirection();
    
    // 1. Sombra suave (usando paint cacheado)
    canvas.drawCircle(center + const Offset(3, 3), radius, _shadowPaint);
    
    // 2. Cuerpo base (usando paint cacheado)
    canvas.drawCircle(center, radius * 1.12, _basePaint);
    
    // 3. ⚡ OPTIMIZADO: Gradiente simplificado (2 colores en lugar de 4)
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
    
    // 4. ⚡ OPTIMIZADO: Brillo simplificado (1 círculo semi-transparente)
    final shinePaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.25);
    canvas.drawCircle(center - Offset(radius * 0.3, radius * 0.3), radius * 0.4, shinePaint);
    
    // 5. Borde (usando paint cacheado)
    canvas.drawCircle(center, radius - 1, _borderPaint);
    
    // 6. ⚡ OPTIMIZADO: Ojos simplificados
    _drawSimpleEyes(canvas, center, radius, angle);
    
    // 7. ⚡ OPTIMIZADO: Nickname con TextPainter cacheado
    _cachedTextPainter.paint(
      canvas,
      Offset(
        (size.x - _cachedTextPainter.width) / 2,
        -_cachedTextPainter.height - 10,
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
  
  // ⚡ OPTIMIZADO: Ojos simplificados (4 círculos en lugar de 10+)
  void _drawSimpleEyes(Canvas canvas, Offset center, double radius, double angle) {
    final eyeSize = radius * 0.3;
    final eyeDistance = radius * 0.4;
    
    // Posición de los ojos
    final eyeOffset = Offset(
      math.cos(angle) * eyeDistance,
      math.sin(angle) * eyeDistance,
    );
    final perpendicular = Offset(
      -math.sin(angle) * (radius * 0.3),
      math.cos(angle) * (radius * 0.3),
    );
    
    // Paints simples y reutilizables
    final whitePaint = Paint()..color = skin.eyeColor;
    final pupilPaint = Paint()..color = skin.pupilColor;
    
    // Ojo izquierdo
    final leftEyePos = center + eyeOffset + perpendicular;
    canvas.drawCircle(leftEyePos, eyeSize, whitePaint);
    canvas.drawCircle(leftEyePos + Offset(math.cos(angle) * eyeSize * 0.25, math.sin(angle) * eyeSize * 0.25), eyeSize * 0.4, pupilPaint);
    
    // Ojo derecho
    final rightEyePos = center + eyeOffset - perpendicular;
    canvas.drawCircle(rightEyePos, eyeSize, whitePaint);
    canvas.drawCircle(rightEyePos + Offset(math.cos(angle) * eyeSize * 0.25, math.sin(angle) * eyeSize * 0.25), eyeSize * 0.4, pupilPaint);
  }

  void updatePosition(Vector2 newPosition) {
    print('📍 [REMOTE] updatePosition llamado para $playerId: $newPosition');
    // En lugar de cambiar la posición instantáneamente, establecer como objetivo
    _lastPosition = position.clone();
    _targetPosition = newPosition.clone();
    _timeSinceLastUpdate = 0; // Reiniciar timer
    
    // Calcular velocidad estimada con precisión balanceada
    if (_lastPosition != null) {
      final delta = newPosition - _lastPosition!;
      // ⚡ OPTIMIZADO: Factor x50 (antes x100 muy agresivo)
      _velocity = delta * 50; // Factor balanceado para movimiento fluido
      print('📍 [REMOTE] Velocidad calculada para $playerId: $_velocity');
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
      
      if (distance > 0.1) { // Umbral mucho más bajo
        // Calcular velocidad suave
        final direction = (_targetPosition! - position).normalized();
        
        // Interpolación ULTRA AGRESIVA - Alcanza casi instantáneamente
        final adaptiveSpeed = _interpolationSpeed * (2.0 + (distance / 30.0).clamp(0.0, 8.0));
        final moveDistance = adaptiveSpeed * distance * dt;
        
        // Mover hacia el objetivo (muy agresivo)
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
      // 🚀 Extrapolación BALANCEADA: continuar movimiento fluido
      // ⚡ OPTIMIZADO: Reducir gradualmente para evitar desviación excesiva
      final extrapolationFactor = 1.0 - ((_timeSinceLastUpdate / _maxExtrapolationTime) * 0.7);
      final movement = _velocity! * dt * extrapolationFactor.clamp(0.3, 1.0); // Mínimo 30% velocidad
      position += movement;
      
      // Agregar al path
      if (pathPoints.isEmpty || (position - pathPoints.last).length > segmentSpacing) {
        pathPoints.add(position.clone());
      }
    }
    
    // ⚡ OPTIMIZACIÓN: Actualizar body segments solo cada 0.033s (30 FPS)
    _bodyUpdateTimer += dt;
    if (_bodyUpdateTimer >= _bodyUpdateInterval) {
      _bodyUpdateTimer = 0;
      
      // Hacer crecer el cuerpo según bodyLength
      if (body.length < bodyLength) {
        final segment = BodySegment(
          position: position,
          ownerId: playerId,
          skin: skin,
        );
        game.world.add(segment);
        body.add(segment);
      }
      
      // Actualizar posiciones de los segmentos del cuerpo
      if (pathPoints.isNotEmpty) {
        for (var i = 0; i < body.length; i++) {
          final pointIndex = pathPoints.length - 1 - (i * 1);
          if (pointIndex >= 0) {
            body[i].position = pathPoints[pointIndex];
          }
        }
      }
      
      // Limpiar puntos antiguos del camino
      final lastSegmentIndex = pathPoints.length - 1 - ((body.length - 1) * 1);
      if (lastSegmentIndex > 10) {
        pathPoints.removeRange(0, lastSegmentIndex - 10);
      }
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

