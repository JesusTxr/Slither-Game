# 🔧 PROBLEMA: Lobby no muestra jugadores

## ❌ SÍNTOMAS:

1. Creas una sala ✅
2. Código se muestra ✅
3. Otro jugador se une ✅
4. **PERO** el host no ve al jugador ❌
5. Aparece "0/0 Listos" ❌
6. No se puede iniciar el juego ❌

---

## 🎯 CAUSA:

El **servidor WebSocket NO está corriendo**.

El lobby necesita el servidor para:
- Sincronizar lista de jugadores
- Enviar estado de "Listo"
- Comunicar cuando iniciar el juego

---

## ✅ SOLUCIÓN (2 minutos):

### **PASO 1: Abrir PowerShell NUEVA terminal**

**IMPORTANTE:** No uses la misma terminal donde corre `flutter run`.

```powershell
cd C:\slither_game\server
dart server.dart
```

---

### **PASO 2: Verificar que inició correctamente**

Deberías ver:
```
🚀 Servidor iniciado en http://localhost:8080
⚡ WebSocket listo para conexiones
🎮 Esperando jugadores...
```

---

### **PASO 3: Mantener el servidor corriendo**

**NO CIERRES esta terminal.** Déjala abierta mientras juegas.

---

### **PASO 4: Reiniciar la app**

En la terminal donde corre Flutter:
1. Presiona `r` (hot reload)
2. O ejecuta `flutter run` de nuevo

---

### **PASO 5: Probar de nuevo**

1. Crea una sala
2. Otro jugador se une con el código
3. **Ahora SÍ ambos se verán en la lista** ✅
4. Click en "Listo"
5. Host inicia el juego
6. ¡A jugar! 🎮

---

## 🖥️ CONFIGURACIÓN CORRECTA:

Debes tener **2 terminales abiertas**:

```
Terminal 1: SERVIDOR
┌─────────────────────────────┐
│ C:\slither_game\server      │
│ > dart server.dart          │
│ 🚀 Servidor iniciado...     │
│ (dejarlo corriendo)         │
└─────────────────────────────┘

Terminal 2: APP
┌─────────────────────────────┐
│ C:\slither_game             │
│ > flutter run               │
│ (la app corriendo)          │
└─────────────────────────────┘
```

---

## 🔍 VERIFICAR QUE FUNCIONA:

### **Test 1: Servidor responde**

Abre navegador:
```
http://localhost:8080
```

Deberías ver:
```json
{"status":"ok","message":"Slither Game Server Running"}
```

### **Test 2: Ver logs del servidor**

En la terminal del servidor, cuando te unes deberías ver:
```
📥 Nuevo jugador conectado: xxx-xxx-xxx
🏠 Jugador xxx se unió a sala: ABGL8Y
📢 Broadcast a 2 jugadores en sala ABGL8Y
```

---

## 🆘 PROBLEMAS COMUNES:

### **"dart: command not found"**

**Solución:**
```powershell
choco install dart-sdk
```

O descarga Dart de: https://dart.dev/get-dart

---

### **"Address already in use"**

**Causa:** Otro proceso está usando el puerto 8080

**Solución:**
```powershell
# Ver procesos en puerto 8080
netstat -ano | findstr :8080

# Matar el proceso (reemplaza [PID] con el número que aparece)
taskkill /PID [PID] /F

# Volver a iniciar el servidor
cd server
dart server.dart
```

---

### **"El servidor se cierra solo"**

**Causa:** Error en el código o falta dependencias

**Solución:**
```powershell
# Instalar dependencias
cd server
dart pub get

# Volver a iniciar
dart server.dart
```

---

### **"Sigo sin ver jugadores"**

**Verificar:**

1. ✅ Servidor está corriendo (terminal muestra logs)
2. ✅ App está conectada (ver logs de la app)
3. ✅ Ambos jugadores usan el mismo código de sala
4. ✅ Ambos jugadores están conectados a la misma red (si es local)

**Logs de la app:**

Busca en la consola de Flutter:
```
🔄 Inicializando modo multijugador...
🌐 Intentando conectar a: ws://localhost:8080
✅ Conectado al servidor multijugador
```

Si ves:
```
❌ Error conectando al servidor: ...
```

El problema es la conexión. Verifica que el servidor esté corriendo.

---

## 📱 SI JUEGAS EN TELÉFONO:

Cambia la URL en `lib/config/game_config.dart`:

```dart
// En lugar de localhost:
static String serverUrl = 'ws://192.168.1.XXX:8080';
// Reemplaza XXX con tu IP local
```

**Obtener tu IP:**
```powershell
ipconfig
```

Busca "IPv4 Address": `192.168.1.XXX`

---

## ✅ CHECKLIST ANTES DE JUGAR:

- [ ] Terminal 1: Servidor corriendo (`dart server.dart`)
- [ ] Terminal 2: App corriendo (`flutter run`)
- [ ] Navegador: http://localhost:8080 funciona
- [ ] Servidor muestra: "🚀 Servidor iniciado"
- [ ] Logs del servidor aparecen cuando te conectas

**Si todos están ✅, funcionará perfectamente.**

---

## 🎊 RESULTADO ESPERADO:

### **Antes (sin servidor):**
```
Crear sala ✅
Unirse ✅
Lobby muestra: "0/0 Listos" ❌
No se ven jugadores ❌
```

### **Ahora (con servidor):**
```
Crear sala ✅
Unirse ✅
Lobby muestra: "1/2 Listos" ✅
Se ven ambos jugadores ✅
Click "Listo" → "2/2 Listos" ✅
Host inicia juego ✅
¡A jugar! 🎮✅
```

---

**¡INICIA EL SERVIDOR Y VUELVE A PROBAR!** 🚀





