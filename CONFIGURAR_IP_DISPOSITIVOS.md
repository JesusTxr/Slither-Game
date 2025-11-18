# 🔧 CONFIGURAR IP PARA MÚLTIPLES DISPOSITIVOS

## ❌ PROBLEMA:

Cuando juegas desde **diferentes dispositivos** (dos teléfonos), necesitas que ambos se conecten al **mismo servidor** usando la **IP local de tu PC**.

---

## ✅ SOLUCIÓN PASO A PASO:

### **PASO 1: Obtener tu IP local**

En PowerShell (en tu PC):

```powershell
ipconfig
```

Busca **"IPv4 Address"** en la sección de tu conexión:
```
IPv4 Address. . . . . . . . . . . : 192.168.1.105
```

**Anota esa IP** (será algo como `192.168.1.XXX`)

---

### **PASO 2: Configurar la IP en el código**

Abre el archivo:
```
lib/config/game_config.dart
```

Cambia esta línea:
```dart
static String serverUrl = 'ws://192.168.1.XXX:8080';
```

Por tu IP real:
```dart
static String serverUrl = 'ws://192.168.1.105:8080';
// ↑ Usa tu IP del PASO 1
```

---

### **PASO 3: Reiniciar el servidor**

**IMPORTANTE:** El servidor debe escuchar en todas las interfaces, no solo localhost.

Verifica que en `server/server.dart` la línea sea:
```dart
var server = await io.serve(handler, '0.0.0.0', 8080);
```

**NO debe ser** `localhost` ni `127.0.0.1`.

Si ya está correcto, continúa al siguiente paso.

---

### **PASO 4: Asegurar que el firewall permite conexiones**

En Windows:

1. Abre **Windows Defender Firewall**
2. Click en **"Configuración avanzada"**
3. Click en **"Reglas de entrada"**
4. Click en **"Nueva regla..."**
5. Tipo: **Puerto**
6. Puerto: **8080**
7. Acción: **Permitir la conexión**
8. Nombre: **Slither Game Server**

O ejecuta este comando en PowerShell **como Administrador**:

```powershell
New-NetFirewallRule -DisplayName "Slither Game Server" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

---

### **PASO 5: Conectar ambos dispositivos a la misma red WiFi**

**MUY IMPORTANTE:**
- PC donde corre el servidor: Red WiFi (ej: "MiWiFi")
- Teléfono 1: **Misma red WiFi** ("MiWiFi")
- Teléfono 2: **Misma red WiFi** ("MiWiFi")

**Todos deben estar en la MISMA red.**

---

### **PASO 6: Reinstalar la app en los dispositivos**

```powershell
# Con los teléfonos conectados por USB
flutter clean
flutter pub get

# Instalar en dispositivo 1
flutter install -d [device1_id]

# Instalar en dispositivo 2
flutter install -d [device2_id]
```

O simplemente:
```powershell
flutter run
# Y selecciona el dispositivo
```

---

### **PASO 7: Iniciar el servidor**

```powershell
cd C:\slither_game\server
dart server.dart
```

Deberías ver:
```
🚀 Servidor escuchando en ws://0.0.0.0:8080
```

---

### **PASO 8: Probar**

#### **Dispositivo 1 (Host):**
1. Abre la app
2. Multijugador → Crear Juego
3. Código: ej. ABGL8Y

#### **Dispositivo 2:**
1. Abre la app
2. Multijugador → Unirse
3. Código: ABGL8Y

**Ahora SÍ ambos deberían verse** ✅

---

## 🔍 VERIFICAR CONECTIVIDAD:

### **Test 1: Ping desde el teléfono**

Desde el navegador del teléfono, abre:
```
http://192.168.1.105:8080
```
(Usa tu IP)

Deberías ver:
```
404 Not Found
Only WebSocket connections are supported.
```

Si ves esto = ✅ **Conectividad correcta**

---

### **Test 2: Ver logs del servidor**

En la terminal donde corre `dart server.dart`, deberías ver cuando los dispositivos se conectan:
```
🎮 Jugador conectado: xxx-xxx-xxx
📥 Mensaje recibido: createRoom
🏠 Sala creada: ABGL8Y
📥 Mensaje recibido: joinRoom
👥 Jugador xxx se unió a sala ABGL8Y
```

---

## 🆘 PROBLEMAS COMUNES:

### **"No se pueden conectar los teléfonos"**

**Verifica:**
1. ✅ Ambos teléfonos en la misma WiFi
2. ✅ IP correcta en `game_config.dart`
3. ✅ Servidor corriendo (`dart server.dart`)
4. ✅ Firewall permite puerto 8080

### **"Sigue sin verse el segundo jugador"**

**Solución:**
1. Cierra completamente ambas apps
2. Detén el servidor (Ctrl+C)
3. Reinicia el servidor
4. Reinstala la app en ambos dispositivos
5. Prueba de nuevo

---

## 📋 CHECKLIST:

- [ ] Obtuve mi IP local (`ipconfig`)
- [ ] Actualicé `game_config.dart` con mi IP
- [ ] Servidor en `0.0.0.0:8080` (no `localhost`)
- [ ] Firewall permite puerto 8080
- [ ] Todos los dispositivos en la misma WiFi
- [ ] Reinstalé la app en todos los dispositivos
- [ ] Servidor corriendo (`dart server.dart`)
- [ ] Probé conectividad desde navegador del teléfono

---

## 💡 EJEMPLO COMPLETO:

### **Mi configuración:**
- PC IP: `192.168.1.105`
- WiFi: "MiCasa_5G"
- Teléfono 1: Samsung (conectado a "MiCasa_5G")
- Teléfono 2: iPhone (conectado a "MiCasa_5G")

### **game_config.dart:**
```dart
static String serverUrl = 'ws://192.168.1.105:8080';
```

### **Comandos:**
```powershell
# Terminal 1: Servidor
cd C:\slither_game\server
dart server.dart

# Terminal 2: Instalar en dispositivos
flutter install
```

**¡Ahora funciona!** 🎮

---

**¡SIGUE ESTOS PASOS Y FUNCIONARÁ!** 🚀





