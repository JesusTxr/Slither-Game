import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:uuid/uuid.dart';

class Food extends PositionComponent {
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
    super.render(canvas);
    canvas.drawCircle((size / 2).toOffset(), size.x / 2, _paint);
  }
}
