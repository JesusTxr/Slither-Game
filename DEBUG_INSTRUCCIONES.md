# 🔍 INSTRUCCIONES DE DEBUG

## 📋 **PASO 1: Buscar los logs de registro**

En tu consola (donde ejecutaste `flutter run`), busca estos mensajes:

```
📝 Intentando registro: chuchito27tm@gmail.com / JesusTxr
🔄 Conectando a Supabase...
📩 Respuesta de Supabase recibida
```

**COPIA TODO EL BLOQUE DE LOGS** desde que dice "📝 Intentando registro" hasta donde termina.

---

## 🧪 **PASO 2: Verificar configuración de email en Supabase**

1. Ve a: https://supabase.com/dashboard/project/ppjsfszaqtreundeonsx/auth/providers
2. Busca **"Email"**
3. Toma captura de pantalla de estas opciones:
   - ✅ Enable Email provider
   - ❓ **Confirm email** (Esta debe estar EN OFF)
   - ❓ Secure email change

**Si "Confirm email" está EN ON:**
- Ponlo en **OFF**
- Click en **"Save"**

---

## 🔬 **PASO 3: Probar que el trigger funciona**

En Supabase SQL Editor, ejecuta esto para probar manualmente:

```sql
-- Test 1: Crear usuario de prueba directamente
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  confirmed_at,
  created_at,
  updated_at
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'test_manual@test.com',
  crypt('123456', gen_salt('bf')),
  now(),
  now(),
  now(),
  now()
) RETURNING id, email;

-- Test 2: Ver si se creó el perfil automáticamente
SELECT * FROM profiles WHERE id IN (
  SELECT id FROM auth.users WHERE email = 'test_manual@test.com'
);
```

**Si ves un perfil creado = ✅ El trigger funciona**
**Si NO ves perfil = ❌ El trigger NO funciona**

---

## 🗑️ **PASO 4: Limpiar datos de prueba**

Después del test, limpia:

```sql
DELETE FROM auth.users WHERE email = 'test_manual@test.com';
```

---

## 📱 **PASO 5: Limpiar caché de la app**

```bash
# Detener la app (Ctrl+C)
flutter clean
flutter pub get
flutter run
```

---

## 🔄 **PASO 6: Registrarse NUEVAMENTE**

**IMPORTANTE:** Usa un email DIFERENTE o borra el anterior primero.

Para ver usuarios existentes:
```sql
SELECT email, created_at FROM auth.users ORDER BY created_at DESC;
```

Para borrar usuario:
```sql
DELETE FROM auth.users WHERE email = 'chuchito27tm@gmail.com';
```

---

## 📊 **LO QUE NECESITO QUE ME MANDES:**

1. **LOGS completos** de cuando te registras (desde la consola)
2. **Captura** de la configuración de Email en Supabase
3. **Resultado** del Test 2 (si aparece o no el perfil)

---

**¡PRUEBA ESTO Y MÁNDAME LOS RESULTADOS!** 🚀





