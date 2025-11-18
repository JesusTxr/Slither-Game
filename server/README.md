# 🐍 Slither Game - Servidor Multijugador

Servidor WebSocket para el juego Slither multijugador.

## 🚀 Cómo Iniciar el Servidor

### 1. Instalar dependencias
```bash
cd server
dart pub get
```

### 2. Iniciar el servidor
```bash
dart server.dart
```

El servidor se iniciará en `ws://localhost:8080`

## 📝 Notas

- El servidor maneja hasta 2000 orbes de comida simultáneamente
- Regenera 10 orbes cada 2 segundos
- Sincroniza automáticamente todos los jugadores conectados
- Mapa de 6000x6000 píxeles

## 🔧 Configuración

Puedes modificar los parámetros en `server.dart`:
- `worldWidth` y `worldHeight`: Tamaño del mundo
- `maxFood`: Cantidad máxima de comida
- Puerto del servidor (línea con `io.serve`)





