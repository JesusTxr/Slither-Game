# 🎮 GUÍA RÁPIDA: PROBAR TODO EL SISTEMA

## ✅ TODO ESTÁ LISTO - AHORA A PROBAR!

### 🚀 INICIO RÁPIDO (2 Minutos)

#### PASO 1: Inicia el Servidor
```bash
# Opción A: Automático (Windows)
INICIAR_TODO.bat

# Opción B: Manual
cd server
dart pub get
dart server.dart
```

Verás:
```
🚀 Servidor escuchando en ws://0.0.0.0:8080
✅ Sistema de salas activado
```

#### PASO 2: Inicia el Juego (Nueva Terminal)
```bash
flutter run
```

---

## 🎯 FLUJO COMPLETO DE PRUEBA

### 1️⃣ Pantalla de Login
- **Opción A:** Jugar como Invitado
  - Ingresa nickname: `Player1`
  - Click "Jugar como Invitado"

- **Opción B:** Registrarse
  - Ingresa email: `test@test.com`
  - Contraseña: `123456`
  - Nickname: `Player1`
  - Click "Registrarse"

### 2️⃣ Menú Principal
- Click en **"Multijugador"** (botón azul)

### 3️⃣ Menú Multijugador
Tienes 3 opciones:

**A) CREAR JUEGO**
1. Click en "Crear Juego"
2. Verás un código como: `A1B2C3`
3. Click en "Copiar Código"
4. Click en "Ir al Lobby"

**B) UNIRSE A JUEGO**
1. Click en "Unirse a Juego"
2. Ingresa el código: `A1B2C3`
3. Click en "Unirse"

**C) MI PERFIL**
- Ver tu información

### 4️⃣ Lobby (Sala de Espera)
Verás:
- ✅ Código de la sala en grande
- ✅ Lista de jugadores
- ✅ Tu nombre con etiqueta "TÚ"
- ✅ Host tiene etiqueta "HOST"

**Si eres JUGADOR NORMAL:**
- Click en "Listo!" cuando estés listo

**Si eres el HOST:**
- Espera a que todos estén listos
- Click en "INICIAR JUEGO"

### 5️⃣ Juego
- ¡Juega!
- Verás otros jugadores en azul
- Come orbes para crecer

---

## 🎮 PROBAR CON MÚLTIPLES JUGADORES

### Método 1: Misma PC (Fácil)
```bash
# Terminal 1: Servidor
cd server && dart server.dart

# Terminal 2: Jugador 1
flutter run

# Terminal 3: Jugador 2
flutter run -d chrome
```

### Método 2: Con Tu Teléfono
1. Servidor en PC
2. Anota tu IP: `ipconfig` → `192.168.1.XXX`
3. Cambia en `lib/config/game_config.dart`:
   ```dart
   static String serverUrl = 'ws://192.168.1.XXX:8080';
   ```
4. Ejecuta en teléfono: `flutter run`

---

## 🔥 CARACTERÍSTICAS IMPLEMENTADAS

### Sistema Completo
✅ Login/Registro con Supabase
✅ Modo Invitado (sin registro)
✅ Menú Multijugador
✅ Crear Salas con Código Único
✅ Unirse a Salas con Código
✅ Lobby con Lista de Jugadores
✅ Sistema "Listo" para jugadores
✅ Host puede Iniciar Juego
✅ Servidor con Sistema de Salas
✅ Comida por Sala (independiente)
✅ Broadcast solo a jugadores de la misma sala

### Características del Lobby
- 🎮 Código de 6 caracteres
- 📋 Copiar código al portapapeles
- 👥 Ver jugadores en tiempo real
- ✅ Sistema de "Listo"
- 👑 Indicador de Host
- 🚪 Salir de la sala
- 🎨 Interfaz profesional

---

## 🎯 PRUEBAS RECOMENDADAS

### Prueba 1: Crear y Unirse
1. Jugador 1: Crea sala → Código `ABC123`
2. Jugador 2: Une a `ABC123`
3. Ambos se ven en el lobby ✓

### Prueba 2: Sistema "Listo"
1. Jugador 2: Click "Listo!"
2. Jugador 1 (host): Ve que jugador 2 está listo
3. Host: Click "INICIAR JUEGO"
4. Ambos entran al juego ✓

### Prueba 3: Desconexión
1. Jugador 2: Cierra app
2. Jugador 1: Ve que jugador 2 salió
3. Lobby se actualiza automáticamente ✓

### Prueba 4: Múltiples Salas
1. Sala 1: `ABC123` (2 jugadores)
2. Sala 2: `XYZ789` (2 jugadores)
3. Cada sala tiene su propia comida
4. No se ven entre salas ✓

---

## 📊 CONSOLA DEL SERVIDOR

Deberías ver mensajes como:
```
🎮 Jugador conectado: abc-123 (Total: 1)
🏠 Sala creada: ABC123 por abc-123
🍎 Generadas 1500 comidas para sala ABC123
🚪 Jugador def-456 se unió a sala ABC123
🎮 Juego iniciado en sala ABC123
```

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### "No se puede conectar al servidor"
✅ Verifica que el servidor esté corriendo
✅ Mira la consola del servidor

### "No aparece en el lobby"
✅ Verifica la consola del juego
✅ Busca mensajes de error

### "No puedo iniciar juego"
✅ Todos deben estar "Listos"
✅ Solo el host puede iniciar
✅ Necesitas mínimo 2 jugadores

### "No veo orbes en el juego"
✅ Verifica que el juego haya iniciado
✅ Mira la consola del servidor
✅ Debería decir "🎮 Juego iniciado"

---

## 🎉 ¡TODO FUNCIONAL!

### Lo Que Tienes Ahora:
- ✅ Login/Registro completo
- ✅ Sistema de salas tipo Among Us
- ✅ Lobby profesional
- ✅ Multijugador real
- ✅ Servidor con salas
- ✅ Comida independiente por sala

### Próximas Mejoras (Opcional):
- [ ] Chat en lobby
- [ ] Avatares personalizados
- [ ] Configuración de sala (máx jugadores, velocidad)
- [ ] Estadísticas de partida
- [ ] Leaderboard por sala
- [ ] Efectos visuales en lobby

---

## 📞 ¿PROBLEMAS?

1. Lee los mensajes de la consola
2. Revisa `PROYECTO_COMPLETO_GUIA.md`
3. Todos los archivos están listos

¡DISFRUTA TU JUEGO MULTIJUGADOR! 🐍🎮✨





