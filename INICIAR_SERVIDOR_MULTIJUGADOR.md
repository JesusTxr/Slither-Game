# 🚀 INICIAR SERVIDOR PARA MULTIJUGADOR

## ❌ PROBLEMA ACTUAL:

El lobby no muestra jugadores porque el **servidor WebSocket no está corriendo**.

---

## ✅ SOLUCIÓN:

### **PASO 1: Abrir una terminal NUEVA para el servidor**

En PowerShell (NEW terminal, no donde corre Flutter):

```powershell
cd C:\slither_game\server
dart server.dart
```

**Deberías ver:**
```
🚀 Servidor iniciado en http://localhost:8080
⚡ WebSocket listo para conexiones
🎮 Esperando jugadores...
```

---

### **PASO 2: Dejar el servidor corriendo**

**IMPORTANTE:** El servidor DEBE estar corriendo SIEMPRE que juegues multijugador.

---

### **PASO 3: Reiniciar la app**

1. En la terminal donde corre Flutter, presiona `r` para hot reload
2. O cierra y vuelve a ejecutar: `flutter run`

---

### **PASO 4: Probar el multijugador**

1. **Jugador 1 (Host):**
   - Abre la app
   - Multijugador → Crear Juego
   - Espera en el lobby
   - **Ahora SÍ deberías verte en la lista**

2. **Jugador 2:**
   - Abre la app en otro dispositivo/emulador
   - Multijugador → Unirse a Juego
   - Ingresa el código
   - **El host AHORA SÍ te verá en la lista**

3. **Iniciar partida:**
   - Ambos jugadores click en "Listo"
   - Host click en "Iniciar Juego"
   - ¡A jugar! 🎮

---

## 🖥️ MANTENER EL SERVIDOR CORRIENDO:

### **Opción A: Terminal separada (Recomendado)**

```powershell
# Terminal 1: Servidor
cd C:\slither_game\server
dart server.dart

# Terminal 2: App
cd C:\slither_game
flutter run
```

### **Opción B: Usar el script automático**

Ejecuta:
```powershell
.\INICIAR_TODO.bat
```

Esto iniciará servidor + app automáticamente.

---

## 🔍 VERIFICAR QUE EL SERVIDOR FUNCIONA:

Abre tu navegador en:
```
http://localhost:8080
```

**Deberías ver:**
```json
{"status":"ok","message":"Slither Game Server Running"}
```

---

## 🆘 SI EL SERVIDOR NO INICIA:

### **Error: "dart: command not found"**

Instala Dart:
```powershell
choco install dart-sdk
```

### **Error: "Address already in use"**

Otro proceso está usando el puerto 8080:

```powershell
# Ver qué proceso usa el puerto
netstat -ano | findstr :8080

# Matar el proceso (usa el PID que aparece)
taskkill /PID [número] /F
```

Luego vuelve a iniciar el servidor.

---

## 📱 PROBAR EN MÓVIL:

Si quieres probar en tu teléfono:

1. **Cambia la IP en el servidor:**

Edita `lib/config/game_config.dart`:
```dart
static String serverUrl = 'ws://192.168.1.XXX:8080'; // Tu IP local
```

2. **Inicia el servidor:**
```powershell
cd server
dart server.dart
```

3. **Instala en teléfono:**
```powershell
flutter install
```

---

## ⚡ VERIFICACIÓN RÁPIDA:

**Antes de jugar multijugador, verifica:**

- [ ] Servidor corriendo (terminal muestra "🚀 Servidor iniciado")
- [ ] App corriendo (en emulador o móvil)
- [ ] Puedes abrir http://localhost:8080 en navegador

**Si todos están ✅, el multijugador funcionará.**

---

## 🎊 RESUMEN:

```
1. Terminal 1: cd server && dart server.dart
2. Terminal 2: flutter run
3. Crear sala
4. Unirse con código
5. ¡Ambos se ven!
6. Listo + Iniciar Juego
7. ¡A jugar! 🐍
```

---

**¡INICIA EL SERVIDOR AHORA!** 🚀





