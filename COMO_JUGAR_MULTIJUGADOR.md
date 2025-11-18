# 🎮 GUÍA COMPLETA: Cómo Jugar Multijugador

## 🌟 ESCENARIO 1: Probar en la Misma Computadora

### Paso 1: Inicia el Servidor
```bash
cd server
dart pub get
dart server.dart
```

Verás:
```
Generadas 1500 comidas iniciales
Servidor escuchando en ws://0.0.0.0:8080
```

✅ **¡Servidor listo!**

### Paso 2: Configura para Localhost

Abre `lib/config/game_config.dart` y asegúrate de que diga:
```dart
static String serverUrl = 'ws://localhost:8080';
```

### Paso 3: Inicia Múltiples Jugadores

**Jugador 1** (nueva terminal):
```bash
flutter run
```

**Jugador 2** (nueva terminal):
```bash
flutter run -d chrome
```

**Jugador 3** (si tienes otro emulador):
```bash
flutter run -d <nombre_emulador>
```

Para ver dispositivos disponibles:
```bash
flutter devices
```

### Paso 4: Juega!
1. En cada ventana, presiona **"Multijugador"**
2. ¡Deberías ver a los otros jugadores en azul! 🔵

---

## 📱 ESCENARIO 2: Jugar desde Teléfono/Tablet

### Paso 1: Encuentra tu IP

**En Windows:**
1. Abre CMD (Win+R, escribe `cmd`)
2. Escribe: `ipconfig`
3. Busca "Adaptador de LAN inalámbrica Wi-Fi"
4. Copia el número de **Dirección IPv4**
   - Ejemplo: `192.168.1.105`

**En Mac:**
1. Abre Terminal
2. Escribe: `ifconfig | grep "inet "`
3. Busca algo como `192.168.1.105`

**En Linux:**
1. Abre Terminal
2. Escribe: `ip addr show`
3. Busca tu IP local

### Paso 2: Configura la IP

Edita `lib/config/game_config.dart`:
```dart
// Cambia XXX por tu IP
static String serverUrl = 'ws://192.168.1.105:8080';
```

### Paso 3: Inicia el Servidor en tu PC

En tu computadora:
```bash
cd server
dart server.dart
```

### Paso 4: Conecta Dispositivos

**En tu Computadora:**
```bash
flutter run
```

**En tu Teléfono (conectado por USB):**
```bash
flutter run -d <ID_de_tu_telefono>
```

**En otro Teléfono/Tablet:**
```bash
flutter run -d <ID_del_dispositivo>
```

### Paso 5: Asegúrate del Firewall

**Windows:**
1. Busca "Firewall de Windows Defender"
2. Clic en "Permitir una aplicación..."
3. Busca "dart.exe"
4. Marca las casillas de "Privada" y "Pública"

**Mac/Linux:**
```bash
# Permitir puerto 8080
sudo ufw allow 8080
```

---

## 🌍 ESCENARIO 3: Jugar por Internet (Avanzado)

### Opción A: Usar Ngrok (Gratis, Temporal)

1. **Descarga Ngrok**: https://ngrok.com/download

2. **Inicia el servidor normalmente:**
```bash
cd server
dart server.dart
```

3. **En otra terminal, inicia Ngrok:**
```bash
ngrok http 8080
```

Verás algo como:
```
Forwarding: tcp://abc123.ngrok.io:8080 -> localhost:8080
```

4. **Configura el juego** con esa URL:
```dart
static String serverUrl = 'ws://abc123.ngrok.io:8080';
```

5. **Comparte esa URL** con tus amigos
6. Todos pueden jugar desde cualquier parte del mundo! 🌍

### Opción B: Desplegar en la Nube

Puedes desplegar el servidor en:
- **Heroku** (gratis para proyectos pequeños)
- **Railway** (fácil de usar)
- **DigitalOcean** (más control)
- **Google Cloud** (escalable)

---

## 🔍 Verificar Conexión

### En el Servidor verás:
```
Nueva conexión establecida
Jugador conectado: abc123-uuid (Total: 1)
Jugador conectado: def456-uuid (Total: 2)
Jugador conectado: ghi789-uuid (Total: 3)
```

### En cada Juego verás:
```
🔄 Inicializando modo multijugador...
🌐 Intentando conectar a: ws://192.168.1.105:8080
✅ Conectado al servidor multijugador
✅ Recibido init del servidor
🎮 Jugador creado en posición: [x, y]
👥 Jugadores existentes: 2
🍎 Comida recibida del servidor: 1500 orbes
✅ Comida agregada al mundo
```

---

## 🎯 Resumen Rápido

### Para jugar LOCAL (misma PC):
```bash
# Terminal 1
cd server && dart server.dart

# Terminal 2
flutter run

# Terminal 3
flutter run -d chrome
```

### Para jugar en RED LOCAL (WiFi):
1. Servidor en PC: `dart server.dart`
2. Encuentra IP de PC: `ipconfig`
3. Cambia `game_config.dart`: `ws://TU.IP.AQUI:8080`
4. Ejecuta en teléfonos: `flutter run`

### Para jugar por INTERNET:
1. Servidor en PC: `dart server.dart`
2. Ngrok: `ngrok http 8080`
3. Copia URL de Ngrok
4. Cambia `game_config.dart` con esa URL
5. Comparte con amigos

---

## ❓ Problemas Comunes

### "No se puede conectar al servidor"
- ✅ Verifica que el servidor esté corriendo
- ✅ Revisa la IP en `game_config.dart`
- ✅ Asegúrate de estar en la misma WiFi
- ✅ Desactiva el firewall temporalmente para probar

### "No veo otros jugadores"
- ✅ Todos deben presionar "Multijugador"
- ✅ Todos deben estar conectados al mismo servidor
- ✅ Revisa los logs del servidor

### "El juego se cierra al iniciar multijugador"
- ✅ Revisa la consola de Flutter
- ✅ El servidor debe estar corriendo ANTES de iniciar el juego

---

## 📊 Capacidad del Servidor

- ✅ Soporta ~50 jugadores simultáneos
- ✅ 2000 orbes de comida máximo
- ✅ Actualizaciones cada 50ms (20 Hz)
- ✅ Latencia: 10-50ms en red local

---

## 🎮 ¡Disfruta Jugando!

Ahora ya sabes cómo conectar múltiples jugadores. 

**Pregunta cualquier duda que tengas!** 🐍✨





