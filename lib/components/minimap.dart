import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;
import '../game.dart';

class Minimap extends PositionComponent with HasGameRef<SlitherGame> {
  late RectangleComponent background;
  late RectangleComponent worldBorder;
  late CircleComponent playerDot;
  final Map<String, CircleComponent> remoteDots = {};
  
  final double minimapWidth = 150;
  final double minimapHeight = 150;
  final double margin = 10;
  
  @override
  Future<void> onLoad() async {
    // Posición en la esquina superior derecha
    position = Vector2(
      gameRef.size.x - minimapWidth - margin,
      margin,
    );
    
    size = Vector2(minimapWidth, minimapHeight);
    
    // Fondo semi-transparente
    background = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..style = PaintingStyle.fill,
    );
    await add(background);
    
    // Borde del mundo (blanco)
    worldBorder = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    await add(worldBorder);
    
    // Punto del jugador (verde brillante)
    playerDot = CircleComponent(
      radius: 4,
      paint: Paint()..color = const Color(0xFF00ff88),
      anchor: Anchor.center,
    );
    await add(playerDot);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (gameRef.playerHead != null) {
      // Calcular posición del jugador en el minimapa
      final playerPos = gameRef.playerHead!.position;
      final worldSize = gameRef.worldSize;
      
      // Convertir posición del mundo a posición del minimapa
      final minimapX = (playerPos.x / worldSize.x) * minimapWidth;
      final minimapY = (playerPos.y / worldSize.y) * minimapHeight;
      
      playerDot.position = Vector2(minimapX, minimapY);
      
      // Actualizar posiciones de jugadores remotos
      _updateRemotePlayers();
    }
  }
  
  void _updateRemotePlayers() {
    // Limpiar dots de jugadores que ya no existen
    final currentPlayerIds = gameRef.remotePlayers.keys.toSet();
    final dotIds = remoteDots.keys.toSet();
    
    for (var id in dotIds.difference(currentPlayerIds)) {
      remoteDots[id]?.removeFromParent();
      remoteDots.remove(id);
    }
    
    // Agregar o actualizar dots de jugadores remotos
    for (var entry in gameRef.remotePlayers.entries) {
      final playerId = entry.key;
      final remotePlayer = entry.value;
      
      if (!remoteDots.containsKey(playerId)) {
        // Crear nuevo dot para jugador remoto
        final dot = CircleComponent(
          radius: 3,
          paint: Paint()..color = Colors.red.withOpacity(0.8),
          anchor: Anchor.center,
        );
        remoteDots[playerId] = dot;
        add(dot);
      }
      
      // Actualizar posición
      final worldSize = gameRef.worldSize;
      final minimapX = (remotePlayer.position.x / worldSize.x) * minimapWidth;
      final minimapY = (remotePlayer.position.y / worldSize.y) * minimapHeight;
      
      remoteDots[playerId]!.position = Vector2(minimapX, minimapY);
    }
  }
  
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    
    // Reposicionar en la esquina superior derecha cuando cambia el tamaño
    position = Vector2(
      size.x - minimapWidth - margin,
      margin,
    );
  }
}




