import 'package:flutter/material.dart';
import 'package:slither_game/config/power_up_types.dart';

class PowerUpIndicator extends StatelessWidget {
  final PowerUpType? activePowerUp;
  final double remainingTime;
  final double totalDuration;
  
  const PowerUpIndicator({
    Key? key,
    required this.activePowerUp,
    required this.remainingTime,
    required this.totalDuration,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (activePowerUp == null || remainingTime <= 0) {
      return const SizedBox.shrink();
    }
    
    final config = PowerUpConfig.getConfig(activePowerUp!);
    final progress = totalDuration > 0 ? remainingTime / totalDuration : 0.0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: config.color.withOpacity(0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: config.color.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji/Ícono
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: config.color.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                config.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Nombre y barra de progreso
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre
              Text(
                config.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              
              // Barra de progreso
              Stack(
                children: [
                  // Fondo
                  Container(
                    width: 80,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Progreso
                  Container(
                    width: 80 * progress,
                    height: 6,
                    decoration: BoxDecoration(
                      color: config.color,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: config.color.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 8),
          
          // Tiempo restante
          Text(
            '${remainingTime.ceil()}s',
            style: TextStyle(
              color: config.color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

