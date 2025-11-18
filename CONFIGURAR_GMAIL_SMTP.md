# 📧 CONFIGURAR GMAIL PARA ENVIAR EMAILS EN SUPABASE

## 🎯 PASOS COMPLETOS

---

## 📱 PARTE 1: CONFIGURAR GMAIL (10 minutos)

### **Paso 1: Habilitar verificación en 2 pasos**

1. Ve a: https://myaccount.google.com/security
2. Busca **"Verificación en 2 pasos"**
3. Si NO está activada:
   - Click en **"Verificación en 2 pasos"**
   - Sigue los pasos para activarla
   - Usa tu teléfono para verificar

---

### **Paso 2: Crear contraseña de aplicación**

1. Ve a: https://myaccount.google.com/apppasswords

   **O manualmente:**
   - https://myaccount.google.com
   - Click en **"Seguridad"**
   - Busca **"Contraseñas de aplicaciones"** o **"App passwords"**

2. Puede pedirte que inicies sesión de nuevo

3. En **"Selecciona la app"**:
   - Elige **"Correo"** o **"Otro (nombre personalizado)"**
   - Si eliges "Otro", escribe: **"Slither Game Supabase"**

4. En **"Selecciona el dispositivo"**:
   - Elige **"Otro (dispositivo personalizado)"**
   - Escribe: **"Supabase Server"**

5. Click en **"Generar"**

6. **COPIA LA CONTRASEÑA** que aparece:
   - Son 16 caracteres sin espacios
   - Ejemplo: `abcd efgh ijkl mnop` (copia sin espacios: `abcdefghijklmnop`)
   - **¡GUÁRDALA! La necesitarás en el siguiente paso**

---

## 🗄️ PARTE 2: CONFIGURAR SUPABASE (5 minutos)

### **Paso 1: Ve a Settings en Supabase**

URL directa:
```
https://supabase.com/dashboard/project/ppjsfszaqtreundeonsx/settings/auth
```

---

### **Paso 2: Busca "SMTP Settings"**

Desplázate hacia abajo hasta encontrar la sección **"SMTP Settings"**

---

### **Paso 3: Activa SMTP personalizado**

1. Click en el toggle **"Enable Custom SMTP"**
2. Ahora aparecerán los campos para configurar

---

### **Paso 4: Llena los campos**

```
Sender name:  Slither Game
Sender email: chuchito27tm@gmail.com

Host:     smtp.gmail.com
Port:     587
Username: chuchito27tm@gmail.com
Password: [PEGA AQUÍ LA CONTRASEÑA DE APLICACIÓN]
```

**IMPORTANTE:**
- En **"Password"**: Pega la contraseña de 16 caracteres que copiaste (SIN espacios)
- Usa tu email real en **"Sender email"** y **"Username"**

---

### **Paso 5: Guardar configuración**

1. Click en **"Save"** al final de la página
2. Espera el mensaje de confirmación

---

## 🧪 PARTE 3: PROBAR QUE FUNCIONA

### **Paso 1: Borrar usuarios de prueba anteriores**

En Supabase SQL Editor:

```sql
-- Ver usuarios actuales
SELECT email, email_confirmed_at FROM auth.users;

-- Borrar usuarios de prueba
DELETE FROM auth.users WHERE email = 'chuchito27tm@gmail.com';

-- O borrar todos
-- DELETE FROM auth.users;
```

---

### **Paso 2: Asegurarte que la confirmación está ACTIVADA**

1. Ve a: https://supabase.com/dashboard/project/ppjsfszaqtreundeonsx/auth/providers

2. Click en **"Email"**

3. **VERIFICA** que esté ACTIVADO:
   - ✅ **"Enable email confirmations"** (ON)

4. Click en **"Save"**

---

### **Paso 3: Limpiar la app**

En tu terminal (PowerShell):

```bash
flutter clean
flutter pub get
flutter run
```

---

### **Paso 4: Registrarte con tu email**

1. Abre la app
2. Regístrate con:
   - Nickname: `JesusTxr`
   - Email: `chuchito27tm@gmail.com`
   - Contraseña: tu contraseña

3. Verás el diálogo: **"✅ Registro Exitoso"**

---

### **Paso 5: Revisar tu Gmail**

1. Abre Gmail: https://mail.google.com
2. Busca email de **"Slither Game"** o **"Supabase"**
3. **Si no aparece**, revisa:
   - 📧 Bandeja de **"Promociones"**
   - 📧 Bandeja de **"Spam"**
   - 📧 Espera 1-2 minutos

4. **El email se verá así:**

```
De: Slither Game <chuchito27tm@gmail.com>
Asunto: Confirm your signup

Confirm your email address:

[Botón: Confirm your mail]

Si no funciona el botón, usa este link:
https://ppjsfszaqtreundeonsx.supabase.co/auth/v1/verify?...
```

---

### **Paso 6: Confirmar tu email**

1. Click en el botón **"Confirm your mail"**
2. Te redirigirá a una página de Supabase
3. Deberías ver: **"Email confirmed successfully"** o similar

---

### **Paso 7: Iniciar sesión en la app**

1. Vuelve a la app
2. Usa **"Iniciar Sesión"**
3. Ingresa:
   - Email: `chuchito27tm@gmail.com`
   - Contraseña: tu contraseña

4. ¡Ahora SÍ te dejará entrar! ✅

---

## 🔍 VERIFICAR EN SUPABASE

```sql
-- Ver tu usuario confirmado
SELECT 
    email, 
    email_confirmed_at,
    created_at
FROM auth.users
WHERE email = 'chuchito27tm@gmail.com';

-- Ver tu perfil creado
SELECT * FROM profiles 
WHERE id = (SELECT id FROM auth.users WHERE email = 'chuchito27tm@gmail.com');
```

**Deberías ver:**
- ✅ `email_confirmed_at` con una fecha (no NULL)
- ✅ Tu perfil en la tabla `profiles`

---

## 🆘 SOLUCIÓN DE PROBLEMAS

### **❌ "No puedo crear contraseña de aplicación"**

**Causa:** No tienes verificación en 2 pasos activada

**Solución:**
1. Ve a: https://myaccount.google.com/security
2. Activa **"Verificación en 2 pasos"**
3. Luego vuelve a intentar crear la contraseña de aplicación

---

### **❌ "El email no llega después de 5 minutos"**

**Verifica:**

1. **Configuración correcta en Supabase:**
   - Host: `smtp.gmail.com`
   - Port: `587`
   - Username: tu email completo
   - Password: la de 16 caracteres (sin espacios)

2. **Revisa logs de Supabase:**
   - Ve a: Logs > Auth Logs
   - Busca errores de SMTP

3. **Prueba manualmente en Supabase:**
   - Ve a Authentication > Users
   - Click en tu usuario
   - Click en **"Send recovery email"** (para probar)

---

### **❌ "Error: Invalid login"**

**Causa:** La contraseña de aplicación está mal

**Solución:**
1. Genera una NUEVA contraseña de aplicación
2. Cópiala SIN espacios
3. Actualiza en Supabase
4. Guarda

---

### **❌ "Error: Authentication failed"**

**Causa:** Gmail bloqueó el acceso

**Solución:**
1. Ve a: https://myaccount.google.com/notifications
2. Busca notificaciones de acceso bloqueado
3. Si aparece, permite el acceso
4. O crea una nueva contraseña de aplicación

---

## 📋 RESUMEN RÁPIDO

```
1. Gmail → Activar verificación en 2 pasos
2. Gmail → Crear contraseña de aplicación (16 caracteres)
3. Supabase → Settings → Auth → Enable Custom SMTP
4. Configurar:
   - Host: smtp.gmail.com
   - Port: 587
   - Username: tu_email@gmail.com
   - Password: [contraseña de 16 caracteres]
5. Supabase → Save
6. App → flutter clean && flutter run
7. App → Registrarse
8. Gmail → Confirmar email
9. App → Iniciar sesión
10. ¡Jugar! ✅
```

---

## 📸 CAPTURAS IMPORTANTES

### **Contraseña de aplicación (se ve así):**
```
abcd efgh ijkl mnop
```
**Copia SIN espacios:** `abcdefghijklmnop`

### **Configuración en Supabase:**
```
✅ Enable Custom SMTP: ON

Sender name:  Slither Game
Sender email: chuchito27tm@gmail.com

Host:     smtp.gmail.com
Port:     587
Username: chuchito27tm@gmail.com
Password: abcdefghijklmnop  ← (ejemplo)
```

---

## ⚠️ IMPORTANTE

1. **NUNCA compartas** tu contraseña de aplicación
2. **Guárdala** en un lugar seguro
3. Si crees que está comprometida, **elimínala** y crea una nueva
4. Puedes tener **múltiples contraseñas** de aplicación

---

## 🎊 DESPUÉS DE CONFIGURAR

¡Felicidades! Ahora:
- ✅ Los emails llegarán a Gmail
- ✅ La confirmación funcionará perfectamente
- ✅ Todo estará guardado en Supabase
- ✅ Los usuarios podrán registrarse normalmente

---

**¡EMPIEZA CON LA PARTE 1!** 🚀

https://myaccount.google.com/apppasswords





