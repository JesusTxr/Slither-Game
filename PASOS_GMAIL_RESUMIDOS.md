# ⚡ CONFIGURAR GMAIL SMTP - PASOS RÁPIDOS

## 📋 LISTA DE VERIFICACIÓN

### ✅ **PASO 1: Obtener contraseña de Gmail (5 min)**

1. 🔐 Activa verificación en 2 pasos:
   - https://myaccount.google.com/security

2. 🔑 Crea contraseña de aplicación:
   - https://myaccount.google.com/apppasswords
   - App: "Correo" o "Otro (Slither Game)"
   - Dispositivo: "Otro (Supabase)"
   - **COPIA LA CONTRASEÑA** (16 caracteres sin espacios)

---

### ✅ **PASO 2: Configurar Supabase (3 min)**

1. 🌐 Ve a Settings:
   ```
   https://supabase.com/dashboard/project/ppjsfszaqtreundeonsx/settings/auth
   ```

2. 📧 Busca "SMTP Settings" y activa "Enable Custom SMTP"

3. ⚙️ Configura:
   ```
   Sender name:  Slither Game
   Sender email: chuchito27tm@gmail.com
   
   Host:     smtp.gmail.com
   Port:     587
   Username: chuchito27tm@gmail.com
   Password: [contraseña de 16 caracteres]
   ```

4. 💾 Click en **"Save"**

---

### ✅ **PASO 3: Activar confirmación de email (1 min)**

1. 🔗 Ve a:
   ```
   https://supabase.com/dashboard/project/ppjsfszaqtreundeonsx/auth/providers
   ```

2. ✅ Click en "Email"

3. ✅ ACTIVA: "Enable email confirmations"

4. 💾 Click en "Save"

---

### ✅ **PASO 4: Limpiar y probar (2 min)**

1. 🗑️ Borra usuarios viejos en Supabase SQL Editor:
   ```sql
   DELETE FROM auth.users;
   ```

2. 🧹 Limpia la app:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. 📝 Regístrate en la app

4. 📧 Revisa tu Gmail (puede tardar 1-2 minutos)

5. ✅ Click en el link de confirmación

6. 🎮 Inicia sesión y juega

---

## 🎯 VALORES EXACTOS PARA SUPABASE

Copia y pega estos valores:

```
Enable Custom SMTP: ✅ ON

Sender name:  Slither Game
Sender email: chuchito27tm@gmail.com

Host:     smtp.gmail.com
Port:     587
Username: chuchito27tm@gmail.com
Password: [TU_CONTRASEÑA_DE_16_CARACTERES]
```

---

## 🆘 SI NO FUNCIONA

### **Email no llega:**
- Revisa spam
- Espera 2-3 minutos
- Verifica que la contraseña no tenga espacios

### **Error "Invalid login":**
- Genera nueva contraseña de aplicación
- Cópiala SIN espacios
- Actualiza en Supabase

### **No puedo crear contraseña de aplicación:**
- Activa verificación en 2 pasos primero
- https://myaccount.google.com/security

---

## ⏱️ TIEMPO TOTAL: ~15 MINUTOS

1. Gmail: 5 min
2. Supabase SMTP: 3 min
3. Supabase Email: 1 min
4. Probar: 2-5 min

---

**¡EMPIEZA AHORA!** 🚀

**Link directo para contraseña:**
https://myaccount.google.com/apppasswords





