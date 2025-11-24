import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;
import '../game.dart';
import 'power_up.dart';
import '../config/power_up_types.dart';

class Minimap extends PositionComponent with HasGameRef<SlitherGame> {
  late RectangleComponent background;
  late RectangleComponent worldBorder;
  late CircleComponent playerDot;
  final Map<String, CircleComponent> remoteDots = {};
  final Map<String, CircleComponent> powerUpDots = {}; // 🎁 Dots para power-ups
  
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
      
      // 🎁 Actualizar posiciones de power-ups
      _updatePowerUps();
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
  
  void _updatePowerUps() {
    // Obtener todos los power-ups del mundo
    final allPowerUps = gameRef.world.children.whereType<PowerUp>().toList();
    final currentPowerUpIds = allPowerUps.map((p) => p.id).toSet();
    final dotIds = powerUpDots.keys.toSet();
    
    // Limpiar dots de power-ups que ya no existen
    for (var id in dotIds.difference(currentPowerUpIds)) {
      powerUpDots[id]?.removeFromParent();
      powerUpDots.remove(id);
    }
    
    // Agregar o actualizar dots de power-ups
    for (var powerUp in allPowerUps) {
      if (!powerUpDots.containsKey(powerUp.id)) {
        // Crear nuevo dot para power-up con su color específico
        final config = PowerUpConfig.getConfig(powerUp.type);
        final dot = CircleComponent(
          radius: 5, // Un poco más grande para destacar
          paint: Paint()
            ..color = config.color
            ..style = PaintingStyle.fill,
          anchor: Anchor.center,
        );
        
        // Agregar un borde blanco para mejor visibilidad
        final border = CircleComponent(
          radius: 5,
          paint: Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
          anchor: Anchor.center,
        );
        dot.add(border);
        
        powerUpDots[powerUp.id] = dot;
        add(dot);
      }
      
      // Actualizar posición
      final worldSize = gameRef.worldSize;
      final minimapX = (powerUp.position.x / worldSize.x) * minimapWidth;
      final minimapY = (powerUp.position.y / worldSize.y) * minimapHeight;
      
      powerUpDots[powerUp.id]!.position = Vector2(minimapX, minimapY);
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




