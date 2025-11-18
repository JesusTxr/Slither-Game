import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:slither_game/game.dart';

class VirtualJoystick extends PositionComponent
    with HasGameReference<SlitherGame>, TapCallbacks, DragCallbacks {
  VirtualJoystick({
    required Vector2 position,
    this.outerRadius = 60.0,
    this.innerRadius = 25.0,
  }) : super(
          position: position,
          size: Vector2.all(outerRadius * 2),
          anchor: Anchor.center,
          priority: 100, // Siempre visible encima de todo
        );

  final double outerRadius;
  final double innerRadius;
  Vector2 _knobPosition = Vector2.zero();
  bool _isDragging = false;
  Vector2? _dragStartPosition;

  // Pinturas para el joystick
  final Paint _outerPaint = Paint()
    ..color = const Color(0x88FFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final Paint _innerPaint = Paint()
    ..color = const Color(0xAAFFFFFF)
    ..style = PaintingStyle.fill;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Dibujar círculo exterior
    canvas.drawCircle(
      (size / 2).toOffset(),
      outerRadius,
      _outerPaint,
    );

    // Dibujar círculo interior (knob)
    final knobOffset = _knobPosition + (size / 2);
    canvas.drawCircle(
      knobOffset.toOffset(),
      innerRadius,
      _innerPaint,
    );
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _isDragging = true;
    _dragStartPosition = event.localPosition;
    _updateKnobPosition(event.localPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (_isDragging) {
      // Calcular la posición actual sumando el delta
      if (_dragStartPosition != null) {
        final currentPosition = _dragStartPosition! + event.localDelta;
        _dragStartPosition = currentPosition;
        _updateKnobPosition(currentPosition);
      }
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isDragging = false;
    _knobPosition = Vector2.zero();
    _dragStartPosition = null;
    // El gusano sigue moviéndose en la última dirección
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _isDragging = false;
    _knobPosition = Vector2.zero();
    _dragStartPosition = null;
  }

  void _updateKnobPosition(Vector2 localPosition) {
    // Posición relativa al centro del joystick
    final center = size / 2;
    var delta = localPosition - center;

    // Limitar el movimiento del knob al radio exterior
    final distance = delta.length;
    final maxDistance = outerRadius - innerRadius;

    if (distance > maxDistance) {
      delta = delta.normalized() * maxDistance;
    }

    _knobPosition = delta;

    // Actualizar la dirección del juego si hay movimiento
    if (delta.length > 5) {
      // Umbral mínimo para evitar movimientos muy pequeños
      game.targetDirection = delta.normalized();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Mantener el joystick en una posición fija en la pantalla
    // (se actualiza automáticamente por ser parte del viewport)
  }
}
