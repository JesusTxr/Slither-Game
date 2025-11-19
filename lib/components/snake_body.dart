import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;

class SnakeBody extends PositionComponent {
  final List<Vector2> bodyPoints;
  final double radius;
  final Color color;
  final String? playerId; // Para identificar al dueño
  
  SnakeBody({
    required this.bodyPoints,
    required this.radius,
    required this.color,
    this.playerId,
  }) : super(priority: -1); // Dibujarse detrás de la cabeza
  
  @override
  void render(Canvas canvas) {
    if (bodyPoints.length < 2) return;
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Dibujar líneas gruesas conectando los puntos del cuerpo
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    // Crear path suave a través de todos los puntos
    final path = Path();
    path.moveTo(bodyPoints.first.x, bodyPoints.first.y);
    
    // Usar curvas cuadráticas para suavizar el cuerpo
    for (int i = 0; i < bodyPoints.length - 1; i++) {
      final current = bodyPoints[i];
      final next = bodyPoints[i + 1];
      
      // Punto medio para la curva
      final midX = (current.x + next.x) / 2;
      final midY = (current.y + next.y) / 2;
      
      if (i == 0) {
        path.lineTo(midX, midY);
      } else {
        path.quadraticBezierTo(current.x, current.y, midX, midY);
      }
    }
    
    // Última línea
    if (bodyPoints.length > 1) {
      final last = bodyPoints.last;
      path.lineTo(last.x, last.y);
    }
    
    // Dibujar el path con grosor
    canvas.drawPath(path, strokePaint);
    
    // Dibujar círculos en cada punto para mayor suavidad
    for (final point in bodyPoints) {
      canvas.drawCircle(point.toOffset(), radius, paint);
    }
  }
}




