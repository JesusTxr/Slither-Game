import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:uuid/uuid.dart';
import 'package:slither_game/game.dart';

class Food extends PositionComponent with HasGameReference<SlitherGame> {
  final String id;
  final Color? color;
  
  Food({
    required Vector2 position,
    String? id,
    this.color,
  })  : id = id ?? const Uuid().v4(),
        super(
          position: position,
          size: Vector2.all(10),
          anchor: Anchor.center,
        );

  final _paint = Paint();
  final _random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
    
    // Usar el color proporcionado o generar uno aleatorio
    if (color != null) {
      _paint.color = color!;
    } else {
      _paint.color = Color.fromARGB(
        255,
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    // ⚡ OPTIMIZACIÓN: Culling - no renderizar comida fuera de cámara
    final camera = game.cameraComponent;
    final visibleRect = camera.visibleWorldRect;
    
    final foodRect = Rect.fromCenter(
      center: position.toOffset(),
      width: size.x,
      height: size.y,
    );
    
    // Si está fuera de la vista, no renderizar
    if (!visibleRect.overlaps(foodRect)) {
      return;
    }
    
    super.render(canvas);
    canvas.drawCircle((size / 2).toOffset(), size.x / 2, _paint);
  }
}
