import 'dart:ui';

import 'package:flame/components.dart';
import 'package:slither_game/game.dart';

class Background extends PositionComponent with HasGameReference<SlitherGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = game.worldSize;
    position = Vector2.zero();
    anchor = Anchor.topLeft;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final backgroundPaint = Paint()..color = const Color(0xFF202020);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), backgroundPaint);

    final gridPaint = Paint()
      ..color = const Color(0xFF404040)
      ..strokeWidth = 1;

    for (var x = 0.0; x < size.x; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), gridPaint);
    }

    for (var y = 0.0; y < size.y; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), gridPaint);
    }
  }
}
