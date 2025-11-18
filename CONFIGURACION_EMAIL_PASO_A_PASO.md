# ✉️ CONFIGURACIÓN DE CONFIRMACIÓN DE EMAIL - PASO A PASO

## 📋 PARTE 1: CONFIGURAR SUPABASE (5 minutos)

### **Paso 1: Activar confirmación de email**

1. Ve a: https://supabase.com/dashboard/project/ppjsfszaqtreundeonsx/auth/providers
2. Busca **"Email"** en la lista
3. Click en **"Email"**
4. **ACTIVA** estas opciones:
   - ✅ **"Enable email confirmations"**
5. Click en **"Save"**

---

### **Paso 2: Configurar redirect URLs**

1. Ve a: https://supabase.com/dashboard/project/ppjsfszaqtreundeonsx/auth/url-configuration
2. En **"Site URL"**, pon:
   - `http://localhost:3000` (para pruebas)
3. En **"Redirect URLs"**, agrega:
   - `http://localhost:3000/**`
   - `com.slithergame://login-callback/**` (para móvil, opcional)
4. Click en **"Save"**

---

### **Paso 3: Personalizar el email (Opcional)**

1. Ve a: https://supabase.com/dashboard/project/ppjsfszaqtreundeonsx/auth/templates
2. Selecciona **"Confirm signup"**
3. Personaliza el mensaje (o déjalo como está)
4. Click en **"Save"**

---

## 📱 PARTE 2: PROBAR QUE FUNCIONA

### **Test rápido con tu email real:**

1. Ve a: https://supabase.com/dashboard/project/ppjsfszaqtreundeonsx/auth/users
2. Click en **"Add user"** → **"Create new user"**
3. Ingresa:
   - **Email:** tu email real (chuchito27tm@gmail.com)
   - **Password:** una contraseña temporal
   - **Auto Confirm User:** ❌ **DESACTIVADO** (para probar el flujo completo)
4. Click en **"Create user"**
5. **Revisa tu email** (puede tardar 1-2 minutos)
6. Si NO llega el email, revisa:
   - Carpeta de spam
   - Configuración de SMTP (puede estar en modo desarrollo)

---

## 🔧 PARTE 3: MODIFICAR EL CÓDIGO

Ahora voy a modificar la app para que maneje correctamente el flujo de confirmación.

---

## ✅ ¿QUÉ VA A PASAR DESPUÉS?

1. Usuario se registra → Ve mensaje "Revisa tu email"
2. Usuario revisa su email → Click en el link
3. Se confirma la cuenta → Ya puede iniciar sesión
4. Si intenta iniciar sesión sin confirmar → Ve mensaje claro

---

**¡EJECUTA LOS PASOS 1, 2 Y 3 DE SUPABASE AHORA!**
Luego yo modifico el código. 🚀





