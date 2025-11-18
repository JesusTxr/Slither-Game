# 🚀 Guía de Despliegue en Render

Esta guía te ayudará a desplegar tu servidor de Slither.io en Render para que sea accesible desde cualquier red WiFi en internet.

## 📋 Requisitos Previos

1. **Cuenta en GitHub** (gratuita)
2. **Cuenta en Render** (gratuita) - [https://render.com](https://render.com)
3. Tu proyecto debe estar en un repositorio de GitHub

---

## 🔧 Paso 1: Preparar tu Repositorio en GitHub

### 1.1 Crear un repositorio en GitHub (si no lo tienes)

1. Ve a [GitHub](https://github.com) e inicia sesión
2. Haz clic en el botón "+" en la esquina superior derecha → "New repository"
3. Nombre: `slither-game` (o el que prefieras)
4. Descripción: "Multiplayer Slither.io game with Flutter & Dart"
5. Selecciona "Private" o "Public" (como prefieras)
6. **NO** marques "Initialize this repository with a README"
7. Haz clic en "Create repository"

### 1.2 Subir tu código a GitHub

Abre la terminal en la carpeta de tu proyecto (`C:\slither_game`) y ejecuta:

```bash
# Inicializa Git (si no lo has hecho)
git init

# Agrega un archivo .gitignore
echo "build/" >> .gitignore
echo ".dart_tool/" >> .gitignore
echo ".flutter-plugins" >> .gitignore
echo ".flutter-plugins-dependencies" >> .gitignore
echo ".packages" >> .gitignore
echo "pubspec.lock" >> .gitignore

# Agrega todos los archivos
git add .

# Crea el primer commit
git commit -m "Initial commit - Slither.io multiplayer game"

# Conecta con tu repositorio (reemplaza TU_USUARIO y TU_REPOSITORIO)
git remote add origin https://github.com/TU_USUARIO/TU_REPOSITORIO.git

# Sube el código
git branch -M main
git push -u origin main
```

> **Nota**: Reemplaza `TU_USUARIO` y `TU_REPOSITORIO` con tu información de GitHub.

---

## 🌐 Paso 2: Desplegar en Render

### 2.1 Crear cuenta en Render

1. Ve a [https://render.com](https://render.com)
2. Haz clic en "Get Started"
3. Regístrate con tu cuenta de GitHub (más fácil) o con email
4. Confirma tu email si es necesario

### 2.2 Conectar GitHub con Render

1. En el dashboard de Render, haz clic en "New +" → "Web Service"
2. Haz clic en "Connect account" junto a GitHub
3. Autoriza a Render para acceder a tus repositorios
4. Selecciona tu repositorio `slither-game` (o el nombre que le hayas puesto)

### 2.3 Configurar el Web Service

Render detectará automáticamente el `Dockerfile`. Configura lo siguiente:

- **Name**: `slither-game-server` (o el que prefieras)
- **Region**: Selecciona la más cercana a ti (ej: Oregon, Frankfurt, etc.)
- **Branch**: `main`
- **Root Directory**: `server` ⚠️ **MUY IMPORTANTE**
- **Environment**: `Docker`
- **Plan**: Selecciona **"Free"**

### 2.4 Variables de entorno (Opcional)

Por ahora no necesitas agregar variables de entorno, pero puedes agregar:

- `PORT`: `8080` (ya está configurado por defecto)

### 2.5 Desplegar

1. Revisa que todo esté correcto
2. Haz clic en "Create Web Service"
3. Render comenzará a construir y desplegar tu servidor
4. Este proceso puede tomar 5-10 minutos la primera vez

### 2.6 Obtener tu URL

Una vez que el despliegue esté completo:

1. Verás un estado "Live" con un círculo verde
2. En la parte superior verás tu URL, algo como:
   ```
   https://slither-game-server.onrender.com
   ```
3. **Copia esta URL**, la necesitarás en el siguiente paso

---

## 📱 Paso 3: Configurar la App para Usar Render

### 3.1 Actualizar `game_config.dart`

Abre el archivo `lib/config/game_config.dart` y modifica la variable `serverUrl`:

```dart
class GameConfig {
  // 🌐 URL del servidor en Render (REEMPLAZA CON TU URL)
  static const String renderServerUrl = 'wss://slither-game-server.onrender.com';
  
  // Cambia esto de 'local' a 'render' para usar el servidor en la nube
  static const String serverMode = 'render'; // 'local' o 'render'
  
  // Configuración de red
  static String get serverUrl {
    if (serverMode == 'render') {
      return renderServerUrl;
    }
    
    // Modo local (para desarrollo)
    final isWeb = kIsWeb;
    final isAndroid = !isWeb && Platform.isAndroid;
    
    if (isWeb) {
      return 'ws://localhost:8080';
    } else if (isAndroid) {
      return 'ws://10.0.2.2:8080';
    } else {
      return 'ws://$_pcIpAddress:8080';
    }
  }
  
  // ... resto del código
}
```

**Pasos:**

1. Reemplaza `slither-game-server.onrender.com` con tu URL de Render (sin el `https://`)
2. Cambia `serverMode` de `'local'` a `'render'`
3. Guarda el archivo

### 3.2 Reconstruir la aplicación

```bash
flutter clean
flutter pub get
flutter run
```

---

## ✅ Paso 4: Probar tu Juego Online

### 4.1 Prueba desde diferentes redes

1. **Dispositivo 1**: Conectado a tu WiFi de casa
2. **Dispositivo 2**: Conectado a datos móviles (4G/5G) o otro WiFi diferente
3. Ambos dispositivos deberían poder:
   - Crear salas
   - Unirse a salas con el código
   - Jugar juntos en tiempo real

### 4.2 Verificar que el servidor está funcionando

Abre tu navegador y ve a tu URL de Render:
```
https://slither-game-server.onrender.com
```

Deberías ver:
```
Slither.io WebSocket Server Running
```

---

## 🔍 Solución de Problemas

### Problema 1: "Connection failed" en la app

**Solución:**
1. Verifica que el servidor esté "Live" en Render (círculo verde)
2. Asegúrate de haber usado `wss://` en lugar de `ws://` (la 's' es importante para HTTPS)
3. Verifica que hayas configurado `serverMode = 'render'` en `game_config.dart`

### Problema 2: El servidor se "duerme" (error 503)

**Causa:** El plan gratuito de Render duerme el servidor después de 15 minutos sin uso.

**Solución:**
- Espera 30-60 segundos, el servidor se "despertará" automáticamente
- Para evitar esto, considera actualizar al plan de pago ($7/mes)

### Problema 3: Error al construir en Render

**Solución:**
1. Verifica que hayas configurado "Root Directory" como `server`
2. Asegúrate de que el `Dockerfile` esté en la carpeta `server/`
3. Revisa los logs en Render para ver el error específico

### Problema 4: No puedo conectar GitHub con Render

**Solución:**
1. Asegúrate de haber subido tu código a GitHub primero
2. En Render, ve a "Account Settings" → "GitHub" → "Reconnect"

---

## 📊 Monitoreo y Logs

### Ver logs en tiempo real

1. Ve a tu servicio en el dashboard de Render
2. Haz clic en la pestaña "Logs"
3. Aquí verás todos los mensajes del servidor, incluyendo:
   - Conexiones de jugadores
   - Creación de salas
   - Errores (si los hay)

### Reiniciar el servidor

Si algo no funciona:
1. Ve a tu servicio en Render
2. Haz clic en "Manual Deploy" → "Deploy latest commit"
3. O haz clic en "Settings" → "Suspend Service" → "Resume Service"

---

## 🔄 Actualizar el Servidor

Cuando hagas cambios en tu código:

```bash
# 1. Haz commit de tus cambios
git add .
git commit -m "Descripción de tus cambios"

# 2. Sube a GitHub
git push origin main
```

Render detectará automáticamente los cambios y redespleagará el servidor.

---

## 💰 Costos

- **Plan Gratuito**: $0/mes
  - ✅ Perfecto para desarrollo y pruebas
  - ⏸️ Se duerme después de 15 minutos sin uso
  - 🔄 Se despierta automáticamente (30-60 segundos)
  
- **Plan de Pago**: ~$7/mes
  - ✅ Servidor siempre activo (no se duerme)
  - ✅ Mejor rendimiento
  - ✅ Más recursos

---

## 🎉 ¡Listo!

Tu juego ahora es verdaderamente online y puede ser jugado desde cualquier parte del mundo. ¡Comparte los códigos de sala con tus amigos y diviértanse!

---

## 🆘 ¿Necesitas Ayuda?

Si tienes problemas:

1. Revisa la sección de "Solución de Problemas" arriba
2. Verifica los logs en Render
3. Asegúrate de que el `serverMode` esté en `'render'` en `game_config.dart`

---

## 📝 Notas Adicionales

### Cambiar entre modo local y Render

En `game_config.dart`, simplemente cambia:
- `serverMode = 'local'` → Para desarrollo local
- `serverMode = 'render'` → Para usar el servidor en la nube

### Alternativas si Render no funciona

Si tienes problemas con Render, puedes usar:
1. **Fly.io** - Similar a Render, también tiene plan gratuito
2. **Google Cloud Run** - Solo pagas por uso
3. **DigitalOcean App Platform** - $5/mes, muy confiable

