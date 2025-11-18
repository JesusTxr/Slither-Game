# 🎯 CONFIGURACIÓN AUTOMÁTICA PARA MÚLTIPLES DISPOSITIVOS

## ✅ SOLUCIÓN IMPLEMENTADA

Ahora el juego **detecta automáticamente** si estás en:
- **Dispositivo físico** (teléfono/tablet) → Usa IP de tu PC
- **Emulador** → Usa localhost

**¡Solo configuras la IP UNA VEZ!** 🎉

---

## 🚀 CONFIGURACIÓN (SOLO UNA VEZ):

### **PASO 1: Obtener tu IP local**

En PowerShell:
```powershell
ipconfig
```

Busca **"IPv4 Address"**:
```
IPv4 Address. . . . . . . : 192.168.1.105
                              ↑ Anota esta IP
```

---

### **PASO 2: Configurar en el código**

Abre: `lib/config/game_config.dart`

Busca esta línea:
```dart
static const String _pcIpAddress = '192.168.1.XXX';
```

Cámbiala por tu IP:
```dart
static const String _pcIpAddress = '192.168.1.105';
// ↑ Usa TU IP del paso 1
```

---

### **PASO 3: ¡Listo!**

**Ya no necesitas cambiar nada más.** 

Ahora funciona automáticamente:

#### **Dispositivo físico 1:**
```powershell
flutter run -d [device1_id]
```
✅ Usa automáticamente: `ws://192.168.1.105:8080`

#### **Dispositivo físico 2:**
```powershell
flutter run -d [device2_id]
```
✅ Usa automáticamente: `ws://192.168.1.105:8080`

#### **Emulador (pruebas):**
```powershell
flutter run -d emulator
```
✅ Usa automáticamente: `ws://localhost:8080`

---

## 🎮 FLUJO DE TRABAJO:

### **1. Iniciar servidor (una vez):**
```powershell
# Terminal 1
cd C:\slither_game\server
dart server.dart
```

### **2. Ejecutar en dispositivo 1:**
```powershell
# Terminal 2
flutter run -d [dispositivo1]
```

### **3. Ejecutar en dispositivo 2:**
```powershell
# Terminal 3
flutter run -d [dispositivo2]
```

### **4. Jugar:**
- Dispositivo 1: Crear Juego
- Dispositivo 2: Unirse con código
- **¡Ambos se ven automáticamente!** ✅

---

## 📱 VER LISTA DE DISPOSITIVOS:

```powershell
flutter devices
```

Verás algo como:
```
3 connected devices:

SM G973F (mobile)   • RZ8M802LXXX • android-arm64  • Android 11
iPhone 13 (mobile)  • 00008110-XXX • ios            • iOS 15.0
Chrome (web)        • chrome       • web-javascript • Google Chrome
```

Usa el **ID** (segunda columna) para ejecutar:
```powershell
flutter run -d RZ8M802LXXX  # Android
flutter run -d 00008110-XXX # iPhone
```

---

## ✅ VENTAJAS:

| Antes | Ahora |
|-------|-------|
| Cambiar IP manualmente | ✅ Detecta automáticamente |
| Editar código cada vez | ✅ Configura UNA sola vez |
| Compilar de nuevo | ✅ Hot reload funciona |
| Confusión con IPs | ✅ Siempre usa la correcta |

---

## 🔍 CÓMO FUNCIONA:

El código detecta la plataforma:

```dart
static String get serverUrl {
  if (Platform.isAndroid || Platform.isIOS) {
    // Dispositivo físico → IP de tu PC
    return 'ws://$_pcIpAddress:8080';
  } else {
    // Emulador → localhost
    return 'ws://localhost:8080';
  }
}
```

---

## 🆘 SI CAMBIAS DE RED:

Si te conectas a un WiFi diferente y tu PC obtiene una IP nueva:

1. Ejecuta `ipconfig` de nuevo
2. Actualiza `_pcIpAddress` en `game_config.dart`
3. Hot reload (`r`) en ambos dispositivos
4. ¡Listo!

---

## 📋 CHECKLIST:

- [ ] Obtuve mi IP con `ipconfig`
- [ ] Actualicé `_pcIpAddress` en `game_config.dart`
- [ ] Ambos dispositivos conectados a la misma WiFi
- [ ] Servidor corriendo (`dart server.dart`)
- [ ] Ejecuté `flutter run` en dispositivo 1
- [ ] Ejecuté `flutter run` en dispositivo 2
- [ ] ¡Funciona automáticamente! ✅

---

## 💡 EJEMPLO COMPLETO:

### **Mi configuración:**
```dart
static const String _pcIpAddress = '192.168.1.105';
```

### **Ejecución:**
```powershell
# Terminal 1: Servidor
cd server
dart server.dart

# Terminal 2: Samsung
flutter run -d RZ8M802LXXX

# Terminal 3: iPhone  
flutter run -d 00008110-XXX
```

**Resultado:**
- Samsung usa: `ws://192.168.1.105:8080` ✅
- iPhone usa: `ws://192.168.1.105:8080` ✅
- Ambos se conectan al mismo servidor ✅
- Se ven mutuamente en el lobby ✅

---

## 🎊 ¡PERFECTO PARA DESARROLLO!

Ahora puedes:
- ✅ Desarrollar en PC
- ✅ Probar en dos teléfonos simultáneamente
- ✅ Hot reload funciona en ambos
- ✅ Sin cambiar configuración cada vez
- ✅ Workflow rápido y eficiente

---

**¡CONFIGURA TU IP UNA VEZ Y OLVÍDATE!** 🚀





