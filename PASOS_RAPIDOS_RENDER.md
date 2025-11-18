# 🚀 Pasos Rápidos para Desplegar en Render

## ✅ Checklist Rápido

### 1️⃣ Subir a GitHub (5 minutos)

```bash
# En la carpeta de tu proyecto (C:\slither_game)
git init
git add .
git commit -m "Initial commit - Slither.io multiplayer"
git remote add origin https://github.com/TU_USUARIO/TU_REPO.git
git branch -M main
git push -u origin main
```

> **Nota:** Reemplaza `TU_USUARIO` y `TU_REPO` con tu información de GitHub.

---

### 2️⃣ Crear Servicio en Render (5 minutos)

1. Ve a [https://render.com](https://render.com) y regístrate con GitHub
2. Click en "New +" → "Web Service"
3. Selecciona tu repositorio
4. Configuración:
   - **Name:** `slither-game-server`
   - **Root Directory:** `server` ⚠️ **IMPORTANTE**
   - **Environment:** Docker
   - **Plan:** Free
5. Click en "Create Web Service"
6. Espera 5-10 minutos a que se despliegue

---

### 3️⃣ Obtener tu URL (1 minuto)

Cuando veas el estado "Live" con un círculo verde:
- Copia la URL que aparece arriba (ej: `https://slither-game-server.onrender.com`)

---

### 4️⃣ Configurar la App (2 minutos)

Abre `lib/config/game_config.dart` y modifica estas 2 líneas:

```dart
// Línea 9: Cambia 'local' por 'render'
static const String serverMode = 'render'; // ← Cambia esto

// Línea 14: Pega tu URL de Render (cambia https por wss)
static const String renderServerUrl = 'wss://slither-game-server.onrender.com'; // ← Pega tu URL aquí
```

**Importante:** Usa `wss://` en lugar de `https://` (la diferencia es solo una 's').

---

### 5️⃣ Reconstruir la App (2 minutos)

```bash
flutter clean
flutter pub get
flutter run
```

---

### 6️⃣ ¡Probar! (1 minuto)

1. **Dispositivo 1** (tu WiFi) → Crea una sala
2. **Dispositivo 2** (datos móviles u otro WiFi) → Únete con el código
3. ¡Deberían verse mutuamente y poder jugar! 🎉

---

## 🔄 Para Actualizar el Servidor Después

Cuando hagas cambios en `server/server.dart`:

```bash
git add .
git commit -m "Actualización del servidor"
git push origin main
```

Render detectará los cambios automáticamente y redespleagará.

---

## ⏸️ Nota sobre el Plan Gratuito

El servidor se "duerme" después de 15 minutos sin uso. La primera conexión tomará 30-60 segundos mientras se "despierta". Después de eso, funcionará con normalidad.

---

## 🆘 Problemas Comunes

### "Connection failed"
- ✅ Verifica que el servidor esté "Live" en Render
- ✅ Asegúrate de usar `wss://` (no `ws://`)
- ✅ Confirma que `serverMode = 'render'` en game_config.dart

### El servidor tarda mucho en responder
- Espera 30-60 segundos, está "despertando"

### Error al desplegar en Render
- Verifica que "Root Directory" sea `server`
- Revisa los logs en Render para ver el error específico

---

## 📚 Documentación Completa

Si necesitas más detalles, lee: `RENDER_DEPLOYMENT.md`

---

¡Listo para jugar online! 🎮🌐

