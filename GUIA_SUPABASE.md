# 🗄️ GUÍA COMPLETA DE CONFIGURACIÓN SUPABASE

## 🎯 ¿NECESITAS SUPABASE?

### ✅ **OPCIÓN 1: SIN SUPABASE (RECOMENDADA PARA PRUEBAS)**
- ✅ Ya funciona AHORA MISMO
- ✅ No necesitas configurar nada
- ✅ Los datos se guardan localmente
- ✅ Perfecto para jugar y probar

### 🌐 **OPCIÓN 2: CON SUPABASE (PARA PRODUCCIÓN)**
- ✅ Datos guardados en la nube
- ✅ Perfiles persistentes
- ✅ Estadísticas de jugadores
- ✅ Historial de partidas

---

## 📋 PASOS PARA CONFIGURAR SUPABASE (Opcional)

### 1️⃣ **Ir a tu proyecto Supabase**
```
https://supabase.com/dashboard
```

### 2️⃣ **Abrir SQL Editor**
- En el menú izquierdo, busca **"SQL Editor"**
- Click en **"New query"**

### 3️⃣ **Ejecutar el Script**
- Abre el archivo `SUPABASE_SETUP.sql` de este proyecto
- Copia TODO el contenido
- Pégalo en el SQL Editor
- Click en **"Run"** (esquina inferior derecha)

### 4️⃣ **Verificar que funcionó**
Ejecuta esto en SQL Editor:
```sql
SELECT * FROM profiles;
```

Si ves una tabla vacía = ✅ **¡Funcionó!**

---

## 🔧 ACTUALIZAR AUTH SERVICE (Si usas Supabase)

Si quieres que use SOLO Supabase (sin fallback local), modifica:

`lib/services/auth_service.dart`

Busca esta línea:
```dart
} catch (supabaseError) {
  print('⚠️ Supabase no disponible, usando modo local');
}
```

Y cámbiala por:
```dart
} catch (supabaseError) {
  print('❌ Error de Supabase: $supabaseError');
  rethrow; // Esto hará que falle si Supabase no funciona
}
```

---

## 🧪 CÓMO PROBAR

### **Modo Actual (Local + Supabase Opcional)**
```bash
# 1. Inicia el servidor
cd server
dart server.dart

# 2. Inicia el juego
flutter run
```

### **Verificar que funciona:**
1. Registrarte con: `test@test.com` / `123456` / `MiNombre`
2. Crear una sala multijugador
3. Si funciona = ✅ **¡Todo bien!**

---

## 📊 VENTAJAS DE CADA OPCIÓN

### **Sin Supabase (Actual)**
✅ Funciona sin internet (parcialmente)
✅ Sin configuración
✅ Rápido de probar
❌ No guarda datos entre sesiones (excepto localmente)

### **Con Supabase**
✅ Datos persistentes
✅ Sincronización entre dispositivos
✅ Estadísticas globales
❌ Requiere configuración inicial

---

## 🚨 SOLUCIÓN DE PROBLEMAS

### "Usuario no encontrado"
- **Causa**: No configuraste las tablas de Supabase
- **Solución**: Ya está arreglado, ahora usa almacenamiento local

### "Invalid login credentials"
- **Causa**: Intentas hacer login sin haberte registrado antes
- **Solución**: Usa "Registrarse" primero, luego "Iniciar Sesión"

### "Error de conexión"
- **Causa**: Supabase no está configurado
- **Solución**: Usa el modo local (ya activado) o configura Supabase con el SQL

---

## 💡 RECOMENDACIÓN

Para **probar el juego AHORA**:
1. ✅ No hagas nada, ya está listo
2. ✅ Usa "Registrarse" para crear cuenta
3. ✅ Juega normalmente

Para **poner en producción**:
1. Ejecuta `SUPABASE_SETUP.sql`
2. Prueba que funciona
3. ¡Listo!

---

## 🎮 ¿SIGUIENTE PASO?

```bash
# Terminal 1: Servidor
cd server && dart server.dart

# Terminal 2: Juego
flutter run
```

**¡PRUEBA EL JUEGO AHORA!** 🐍🎮✨





