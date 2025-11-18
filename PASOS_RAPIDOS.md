# ⚡ PASOS RÁPIDOS PARA ARREGLAR SUPABASE

## 🎯 **PROBLEMA:** No se guardan datos en Supabase

### **CAUSA MÁS COMÚN:**
Supabase requiere confirmación de email por defecto, entonces aunque te registres, no puedes usar tu cuenta hasta confirmar el email.

---

## ✅ **SOLUCIÓN RÁPIDA (5 minutos):**

### **1. Desactivar confirmación de email:**

1. Ve a: https://supabase.com/dashboard
2. Abre tu proyecto: **JesusTxr's Project**
3. Click en **"Authentication"** (menú izquierdo)
4. Click en **"Settings"**
5. Click en **"Auth Providers"** o **"Email"**
6. Busca **"Enable email confirmations"**
7. **DESACTÍVALO** (toggle a OFF)
8. Click en **"Save"**

---

### **2. Verificar que el script SQL se ejecutó:**

En **SQL Editor** de Supabase, ejecuta:

```sql
-- Ver si las tablas existen
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';
```

**Deberías ver:**
- profiles
- rooms
- room_players

**Si NO aparecen**, ejecuta `SUPABASE_SETUP_CLEAN.sql` nuevamente.

---

### **3. Limpiar datos viejos de la app:**

En tu PC (PowerShell):

```powershell
# Detener la app si está corriendo
# Ctrl+C en la terminal donde corre flutter

# Limpiar caché
flutter clean
flutter pub get
```

---

### **4. Ejecutar la app con logs mejorados:**

```powershell
flutter run
```

---

### **5. Registrarte NUEVAMENTE:**

**IMPORTANTE:** Usa un **email diferente** al que ya probaste, o borra el usuario anterior en Supabase.

Para borrar usuario anterior:
1. Supabase → **Authentication** → **Users**
2. Busca tu email
3. Click en los 3 puntos **"..."**
4. Click en **"Delete user"**

Luego regístrate con:
- Email: `chuchito27tm@gmail.com` (o uno nuevo)
- Contraseña: tu contraseña
- Nickname: `JesusTxr`

---

### **6. Ver los LOGS en la consola:**

Busca estos mensajes:

**✅ SI FUNCIONA:**
```
📝 Intentando registro: chuchito27tm@gmail.com / JesusTxr
🔄 Conectando a Supabase...
📩 Respuesta de Supabase recibida
   Usuario: xxx-xxx-xxx-xxx
   Session: ✅
✅ Registro exitoso con Supabase
✅ Perfil guardado en Supabase
✅ Usuario registrado en Supabase con ID: xxx
```

**❌ SI FALLA:**
```
❌ ERROR DE SUPABASE: [aquí aparecerá el error real]
   Tipo: AuthException (o similar)
⚠️ Usando modo local como fallback
✅ Registro exitoso local con ID: xxx
```

---

### **7. Verificar en Supabase:**

En **SQL Editor**:

```sql
-- Ver usuarios registrados
SELECT email, created_at 
FROM auth.users 
ORDER BY created_at DESC;

-- Ver perfiles
SELECT * FROM profiles ORDER BY created_at DESC;
```

**Si ves tu email = ✅ ¡FUNCIONA!**

---

## 🆘 **SI SIGUE SIN FUNCIONAR:**

**Copia EXACTAMENTE el mensaje que dice:**
```
❌ ERROR DE SUPABASE: [mensaje de error]
```

Y mándamelo para saber qué está fallando.

---

## 📝 **RESUMEN:**

1. ✅ Desactivar confirmación de email en Supabase
2. ✅ `flutter clean && flutter pub get && flutter run`
3. ✅ Registrarte con email NUEVO o borrar el anterior
4. ✅ Ver los logs
5. ✅ Verificar en Supabase que aparezca tu usuario

---

**¡PRUÉBALO AHORA!** 🚀





