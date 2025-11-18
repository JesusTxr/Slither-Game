# 🐍 Slither.io Multiplayer Game

Un juego multijugador similar a Slither.io desarrollado con Flutter y Dart.

## 🎮 Características

- ✅ Modo Un Jugador
- ✅ Modo Multijugador Online
- ✅ Sistema de Salas con Códigos
- ✅ Autenticación de Usuarios (Supabase)
- ✅ Sincronización en Tiempo Real (WebSockets)
- ✅ Colisiones y Game Over
- ✅ Lista de Jugadores con Estado "Listo"

## 🚀 Instalación

### Requisitos Previos

- Flutter SDK (3.0.0+)
- Dart SDK (3.0.0+)
- Una cuenta en Supabase (gratuita)

### Configuración

1. **Clona el repositorio:**
   ```bash
   git clone https://github.com/TU_USUARIO/slither-game.git
   cd slither-game
   ```

2. **Instala las dependencias:**
   ```bash
   flutter pub get
   cd server
   dart pub get
   cd ..
   ```

3. **Configura Supabase:**
   - Crea un proyecto en [Supabase](https://supabase.com)
   - Ejecuta el script SQL: `SUPABASE_SETUP_CLEAN.sql`
   - Copia tu URL y Anon Key a `lib/config/supabase_config.dart`

4. **Configura el servidor:**
   - Para desarrollo local: Sigue las instrucciones en `lib/config/game_config.dart`
   - Para despliegue en la nube: Lee `RENDER_DEPLOYMENT.md`

## 🎯 Cómo Jugar

### Modo Local (Misma Red WiFi)

1. **Inicia el servidor:**
   ```bash
   cd server
   dart server.dart
   ```

2. **Ejecuta la app:**
   ```bash
   flutter run
   ```

3. **Crea o únete a una sala** y ¡diviértete!

### Modo Online (Cualquier Red)

Sigue la guía completa en `RENDER_DEPLOYMENT.md` para desplegar el servidor en Render.

## 📁 Estructura del Proyecto

```
slither_game/
├── lib/
│   ├── components/        # Componentes del juego (PlayerHead, BodySegment, etc.)
│   ├── config/           # Configuraciones (Supabase, Game Config)
│   ├── screens/          # Pantallas de la app
│   ├── services/         # Servicios (Auth, Network, Room)
│   ├── game.dart         # Lógica principal del juego
│   └── main.dart         # Punto de entrada
├── server/
│   ├── server.dart       # Servidor WebSocket
│   ├── Dockerfile        # Para despliegue en Render
│   └── pubspec.yaml      # Dependencias del servidor
└── RENDER_DEPLOYMENT.md  # Guía de despliegue
```

## 🛠️ Tecnologías Utilizadas

- **Flutter** - Framework de UI
- **Flame** - Motor de juego 2D
- **Dart WebSockets** - Comunicación en tiempo real
- **Supabase** - Autenticación y base de datos
- **Render** - Hosting del servidor (opcional)

## 📖 Documentación

- [Guía de Despliegue en Render](RENDER_DEPLOYMENT.md)
- [Configuración de Supabase](SUPABASE_SETUP_CLEAN.sql)
- [Configuración de Red](lib/config/game_config.dart)

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor, abre un issue primero para discutir los cambios que te gustaría hacer.

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 🎉 Créditos

Desarrollado con ❤️ usando Flutter y Dart.
