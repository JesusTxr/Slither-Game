# 📧 PROBLEMA: EMAIL NO LLEGA

## 🎯 CAUSA PRINCIPAL:

**Supabase en modo desarrollo** limita el envío de emails. Por defecto, Supabase **NO envía emails reales** a menos que:

1. ✅ Configures SMTP personalizado (complejo)
2. ✅ **O DESACTIVES la confirmación de email** (simple)

---

## 🔧 SOLUCIÓN RÁPIDA (RECOMENDADA):

### **DESACTIVAR CONFIRMACIÓN DE EMAIL**

Para que el juego funcione inmediatamente sin esperar emails:

#### **1. Ve a Supabase:**
```
https://supabase.com/dashboard/project/ppjsfszaqtreundeonsx/auth/providers
```

#### **2. Desactiva la confirmación:**
1. Busca **"Email"**
2. Click en **"Email"**
3. ❌ **DESACTIVA**: "Enable email confirmations"
4. ✅ **DESACTIVA**: "Confirm email"
5. Click en **"Save"**

#### **3. Limpia datos:**

En Supabase SQL Editor:
```sql
-- Borrar usuarios pendientes de confirmación
DELETE FROM auth.users WHERE email_confirmed_at IS NULL;

-- O borrar TODOS los usuarios de prueba
DELETE FROM auth.users;
```

#### **4. Limpia la app:**
```bash
flutter clean
flutter pub get
flutter run
```

#### **5. Regístrate nuevamente:**
- Ahora se registrará SIN necesitar confirmación
- Podrás jugar inmediatamente ✅

---

## 🌐 SOLUCIÓN AVANZADA (SI QUIERES EMAILS REALES):

### **CONFIGURAR SMTP PERSONALIZADO EN SUPABASE**

#### **Opción A: Usar Gmail**

1. Ve a: https://supabase.com/dashboard/project/ppjsfszaqtreundeonsx/settings/auth

2. Busca **"SMTP Settings"**

3. Configura:
   ```
   Host: smtp.gmail.com
   Port: 587
   Username: tu_email@gmail.com
   Password: [App Password de Google]
   Sender email: tu_email@gmail.com
   Sender name: Slither Game
   ```

4. **Crear App Password en Google:**
   - Ve a: https://myaccount.google.com/apppasswords
   - Crea una contraseña de aplicación
   - Úsala en el campo "Password"

#### **Opción B: Usar SendGrid (Gratis hasta 100 emails/día)**

1. Crea cuenta en: https://sendgrid.com
2. Obtén tu API Key
3. Configura en Supabase:
   ```
   Host: smtp.sendgrid.net
   Port: 587
   Username: apikey
   Password: [Tu SendGrid API Key]
   ```

#### **Opción C: Usar Resend (Recomendado, 3000 emails/mes gratis)**

1. Crea cuenta en: https://resend.com
2. Obtén tu API Key
3. Usa el servicio de SMTP de Resend

---

## 🎮 PARA TU JUEGO, TE RECOMIENDO:

### **✅ DESACTIVAR CONFIRMACIÓN DE EMAIL**

**¿Por qué?**
1. Es un juego casual
2. Los usuarios quieren jugar YA
3. No necesitas verificar emails reales
4. Más simple y funciona siempre

**¿Cuándo SÍ usar confirmación?**
- Si necesitas enviar notificaciones importantes
- Si es una app de pagos/dinero
- Si necesitas verificar identidad real

---

## 📋 PASO A PASO PARA ARREGLARLO AHORA:

### **1. Ve a Supabase Auth Providers:**
https://supabase.com/dashboard/project/ppjsfszaqtreundeonsx/auth/providers

### **2. Click en "Email"**

### **3. DESACTIVA estas opciones:**
- ❌ Enable email confirmations
- ❌ Confirm email

### **4. Guarda y borra usuarios:**
```sql
DELETE FROM auth.users;
```

### **5. Reinicia la app:**
```bash
flutter run
```

### **6. Regístrate de nuevo:**
- ¡Funcionará instantáneamente!

---

## 🔍 VERIFICAR QUE FUNCIONA:

Después de registrarte, ejecuta en Supabase SQL Editor:

```sql
-- Ver usuarios
SELECT 
    email, 
    email_confirmed_at,
    created_at
FROM auth.users
ORDER BY created_at DESC;

-- Ver perfiles
SELECT * FROM profiles ORDER BY created_at DESC;
```

**Deberías ver:**
- ✅ Tu usuario con `email_confirmed_at` con fecha (ya confirmado)
- ✅ Tu perfil en la tabla `profiles`

---

## 💡 RESUMEN:

**Problema:** Supabase no envía emails en modo desarrollo

**Solución Simple:** Desactivar confirmación de email

**Solución Avanzada:** Configurar SMTP personalizado

**Recomendación:** Para tu juego, usa la solución simple

---

**¡DESACTIVA LA CONFIRMACIÓN DE EMAIL Y LISTO!** 🚀





