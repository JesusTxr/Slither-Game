# 🐍 Slither Game - Modo Multijugador

¡Tu juego Slither ahora tiene soporte multijugador en tiempo real!

## 🚀 Cómo Iniciar

### Paso 1: Instalar Dependencias

#### Para el Cliente (Flutter)
```bash
flutter pub get
```

#### Para el Servidor
```bash
cd server
dart pub get
```

### Paso 2: Iniciar el Servidor

```bash
cd server
dart server.dart
```

Deberías ver:
```
Generadas 1500 comidas iniciales
Servidor escuchando en ws://0.0.0.0:8080
```

### Paso 3: Ejecutar el Juego

En una nueva terminal:
```bash
flutter run
```

## 🎮 Cómo Jugar

1. **Modo Solo**: Juega tú solo con comida generada localmente
2. **Modo Multijugador**: Conéctate al servidor y juega con otros

### Controles
- Usa el **joystick** en la esquina inferior izquierda para moverte
- Come los orbes de colores para crecer
- Creces 1 segmento cada 3 orbes comidos

## 🌐 Configuración de Red

### Jugar en Localhost (Misma Computadora)
El juego ya está configurado para `localhost:8080`. No necesitas cambiar nada.

### Jugar desde Otro Dispositivo (Teléfono, Tablet, etc.)

1. Abre `lib/config/game_config.dart`
2. Cambia la línea:
```dart
static String serverUrl = 'ws://localhost:8080';
```

Por la IP de tu computadora:
```dart
static String serverUrl = 'ws://192.168.1.XXX:8080';  // Reemplaza XXX con tu IP
```

3. Para encontrar tu IP:
   - **Windows**: `ipconfig` en cmd
   - **Mac/Linux**: `ifconfig` en terminal
   - Busca algo como `192.168.1.100` o `10.0.0.5`

4. **Importante**: Asegúrate de que tu firewall permita conexiones en el puerto 8080

### Probar con Varios Jugadores

1. Inicia el servidor una vez
2. Ejecuta múltiples instancias del juego:
   - En emuladores diferentes
   - En dispositivos físicos
   - En computadoras diferentes (misma red)

## 🔧 Configuración del Servidor

Puedes modificar estos parámetros en `server/server.dart`:

```dart
final double worldWidth = 6000;      // Ancho del mundo
final double worldHeight = 6000;     // Alto del mundo
final int maxFood = 2000;            // Máxima comida en el mapa
```

Para cambiar el puerto del servidor, modifica la línea:
```dart
var server = await io.serve(handler, '0.0.0.0', 8080);
```

## 📊 Características del Multijugador

✅ **Sincronización en Tiempo Real**
- Actualiza posiciones cada 50ms
- Latencia baja (~10-50ms en red local)

✅ **Comida Compartida**
- Todos los jugadores ven la misma comida
- Cuando alguien come, desaparece para todos
- Se regenera gradualmente

✅ **Jugadores Visibles**
- Ves a todos los demás jugadores en azul
- Ves su nickname encima
- Su tamaño refleja cuánto han crecido

✅ **Reconexión Automática**
- Si el servidor no está disponible, vuelve a modo solo

## 🐛 Solución de Problemas

### El juego no se conecta al servidor

1. Verifica que el servidor esté corriendo
2. Revisa la URL en `lib/config/game_config.dart`
3. Prueba con `ws://localhost:8080` primero

### Lag o retraso

- Asegúrate de estar en la misma red WiFi
- Cierra otros programas que usen mucho internet
- Reduce el número de jugadores simultáneos

### El servidor se cierra solo

- Verifica que todas las dependencias estén instaladas
- Revisa los mensajes de error en la consola

## 📱 Desplegar en Internet (Avanzado)

Para jugar con amigos por internet, necesitas:

1. **Opción 1: Servicio Cloud**
   - Despliega el servidor en Heroku, Railway, o DigitalOcean
   - Cambia `serverUrl` a `ws://tu-servidor.com:8080`

2. **Opción 2: Ngrok (Temporal)**
   ```bash
   ngrok http 8080
   ```
   - Copia la URL que te da
   - Úsala en `game_config.dart`

## 🎯 Próximas Mejoras Sugeridas

- [ ] Sistema de salas/rooms
- [ ] Leaderboard global
- [ ] Chat entre jugadores
- [ ] Power-ups especiales
- [ ] Colisión entre jugadores
- [ ] Efectos de muerte y respawn

## 💡 Notas Técnicas

**Tecnología Usada:**
- WebSockets para comunicación en tiempo real
- Dart/Shelf para el servidor
- Flame engine para el juego
- Arquitectura cliente-servidor

**Rendimiento:**
- Soporta ~50 jugadores simultáneos
- 2000 orbes de comida máximo
- Actualizaciones a 20 Hz (50ms)

---

¡Disfruta jugando con tus amigos! 🎮🐍





