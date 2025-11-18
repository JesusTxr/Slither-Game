# 🔧 SOLUCIÓN: Supabase no guarda datos

## 🎯 PROBLEMA DETECTADO

Cuando te registras, el código usa Supabase PERO puede estar fallando silenciosamente por alguna de estas razones:

### ✅ **VERIFICACIONES OBLIGATORIAS EN SUPABASE**

---

## 📧 **1. VERIFICAR CONFIGURACIÓN DE EMAIL**

Supabase por defecto requiere **confirmación de email**. Esto hace que no puedas usar tu cuenta hasta confirmar.

### **Pasos para desactivar confirmación de email:**

1. Ve a tu proyecto en Supabase
2. Click en **"Authentication"** (menú izquierdo)
3. Click en **"Settings"** (dentro de Authentication)
4. Busca **"Email Auth"**
5. **DESACTIVA** estas opciones:
   - ❌ **"Enable email confirmations"**
   - ❌ **"Secure email change"** (opcional)
   - ❌ **"Enable email OTP"** (opcional)

6. Click en **"Save"**

### 📸 **Configuración correcta:**

```
Email Auth
├─ Enable email confirmations: ❌ OFF
├─ Confirm email: ❌ OFF
└─ Secure email change: ❌ OFF
```

---

## 🗄️ **2. VERIFICAR QUE LAS TABLAS EXISTEN**

Ejecuta esto en **SQL Editor** de Supabase:

```sql
-- Ver todas las tablas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';
```

**Deberías ver:**
- ✅ `profiles`
- ✅ `rooms`
- ✅ `room_players`

**Si NO aparecen:**
- Ejecuta `SUPABASE_SETUP_CLEAN.sql` nuevamente

---

## 🔍 **3. VERIFICAR EL TRIGGER**

Ejecuta esto en SQL Editor:

```sql
-- Ver triggers activos
SELECT trigger_name, event_object_table, action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public';
```

**Deberías ver:**
- ✅ `on_auth_user_created` en tabla `users`

**Si NO aparece:**
- Ejecuta esta parte del script nuevamente:

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, nickname, avatar)
  VALUES (
    new.id, 
    COALESCE(
      split_part(new.email, '@', 1),
      'Player_' || substr(new.id::text, 1, 8)
    ), 
    '🐍'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

---

## 🧪 **4. PROBAR REGISTRO MANUAL EN SUPABASE**

Para verificar que Supabase funciona, registra un usuario directamente desde el dashboard:

1. Ve a **"Authentication"** > **"Users"**
2. Click en **"Add user"** > **"Create new user"**
3. Ingresa:
   - Email: `prueba@test.com`
   - Password: `123456`
4. Click en **"Create user"**

5. Luego verifica que se creó el perfil:

```sql
SELECT * FROM profiles;
```

**Deberías ver:**
- ✅ Un registro con el email que creaste

---

## 🚀 **5. PROBAR DESDE LA APP**

Una vez configurado todo:

### **A. Limpiar datos locales de la app:**

```bash
# En tu terminal
flutter clean
flutter pub get
flutter run
```

### **B. Registrarte nuevamente:**
- Email: `chuchito27tm@gmail.com`
- Contraseña: (tu contraseña)
- Nickname: `JesusTxr`

### **C. Ver los logs:**

Busca en la consola:
```
📝 Intentando registro: chuchito27tm@gmail.com / JesusTxr
🔄 Conectando a Supabase...
📩 Respuesta de Supabase recibida
   Usuario: xxx-xxx-xxx
   Session: ✅
✅ Registro exitoso con Supabase
✅ Perfil guardado en Supabase
```

**Si ves:**
```
❌ ERROR DE SUPABASE: ...
```

**Ese es el error real que hay que arreglar.**

---

## 📊 **6. VERIFICAR EN SUPABASE**

Después de registrarte desde la app:

```sql
-- Ver usuarios registrados
SELECT id, email, created_at 
FROM auth.users 
ORDER BY created_at DESC;

-- Ver perfiles creados
SELECT * FROM profiles ORDER BY created_at DESC;
```

**Si ves tu email:**
- ✅ **¡Funciona!**

**Si NO ves tu email:**
- ❌ Hay un problema de conexión o configuración

---

## 🎯 **RESUMEN DE PASOS:**

1. ✅ Desactiva confirmación de email en Supabase
2. ✅ Verifica que las tablas existan
3. ✅ Verifica que el trigger funcione
4. ✅ Haz `flutter clean && flutter run`
5. ✅ Regístrate nuevamente
6. ✅ Revisa los logs de la consola
7. ✅ Verifica en Supabase que aparezca tu usuario

---

## 🆘 **SI SIGUE SIN FUNCIONAR:**

Ejecuta esto y mándame el resultado:

```sql
-- Test completo
SELECT 
  'Tablas creadas' as test,
  COUNT(*) as resultado
FROM information_schema.tables 
WHERE table_schema = 'public';

SELECT 
  'Usuarios registrados' as test,
  COUNT(*) as resultado
FROM auth.users;

SELECT 
  'Perfiles creados' as test,
  COUNT(*) as resultado
FROM profiles;

SELECT 
  'Trigger activo' as test,
  COUNT(*) as resultado
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';
```

---

**¡PRUEBA ESTOS PASOS Y DIME QUÉ SALE EN LA CONSOLA!** 🚀





