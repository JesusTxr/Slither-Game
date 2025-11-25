# 🚨 ERROR: TABLA 'pagos_tienda' NO CONFIGURADA

## ❌ **EL PROBLEMA:**

```
Error: Could not find the 'email' column of 'pagos_tienda'
```

**Esto significa que:**
- ❌ NO ejecutaste el script SQL en Supabase
- ❌ La tabla `pagos_tienda` no existe o está incompleta

---

## ✅ **SOLUCIÓN: EJECUTAR EL SCRIPT SQL**

### **📋 PASO 1: COPIAR EL SCRIPT**

Ve al archivo **`SUPABASE_PAGOS_TIENDA.sql`** en tu proyecto y copia TODO su contenido (147 líneas).

O copia este script directamente:

```sql
-- ============================================================
-- SCRIPT: SISTEMA DE PAGOS PARA TIENDA DE SKINS
-- ============================================================

-- 1. Crear tabla de pagos_tienda
CREATE TABLE IF NOT EXISTS public.pagos_tienda (
    -- Identificador único del pago
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Usuario que realizó la compra (referencia a auth.users)
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    
    -- Email del usuario (para comprobantes)
    email TEXT NOT NULL,
    
    -- Skin comprada
    skin_id TEXT NOT NULL,
    skin_name TEXT NOT NULL,
    
    -- Precio de la compra
    precio DECIMAL(10, 2) NOT NULL,
    
    -- Información de la tarjeta (últimos 4 dígitos para comprobante)
    ultimos_4_digitos TEXT NOT NULL,
    tipo_tarjeta TEXT NOT NULL,
    
    -- Información del titular
    nombre_titular TEXT NOT NULL,
    
    -- Estado del pago
    estado TEXT DEFAULT 'completado' CHECK (estado IN ('completado', 'pendiente', 'fallido')),
    
    -- Número de comprobante único
    numero_comprobante TEXT UNIQUE NOT NULL DEFAULT 'COMP-' || to_char(NOW(), 'YYYYMMDD') || '-' || substring(md5(random()::text) from 1 for 8),
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Crear índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_pagos_user_id ON public.pagos_tienda(user_id);
CREATE INDEX IF NOT EXISTS idx_pagos_created_at ON public.pagos_tienda(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_pagos_comprobante ON public.pagos_tienda(numero_comprobante);
CREATE INDEX IF NOT EXISTS idx_pagos_skin_id ON public.pagos_tienda(skin_id);

-- 3. Habilitar Row Level Security (RLS)
ALTER TABLE public.pagos_tienda ENABLE ROW LEVEL SECURITY;

-- 4. Política: Los usuarios solo pueden ver sus propias compras
DROP POLICY IF EXISTS "Los usuarios pueden ver sus propias compras" ON public.pagos_tienda;
CREATE POLICY "Los usuarios pueden ver sus propias compras"
    ON public.pagos_tienda
    FOR SELECT
    USING (auth.uid() = user_id);

-- 5. Política: Los usuarios pueden insertar sus propias compras
DROP POLICY IF EXISTS "Los usuarios pueden crear sus propias compras" ON public.pagos_tienda;
CREATE POLICY "Los usuarios pueden crear sus propias compras"
    ON public.pagos_tienda
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 6. Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. Trigger para actualizar updated_at
DROP TRIGGER IF EXISTS set_updated_at ON public.pagos_tienda;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.pagos_tienda
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 8. Crear vista para estadísticas de compras
CREATE OR REPLACE VIEW public.stats_compras AS
SELECT 
    skin_id,
    skin_name,
    COUNT(*) as total_compras,
    SUM(precio) as ingresos_totales,
    AVG(precio) as precio_promedio
FROM public.pagos_tienda
WHERE estado = 'completado'
GROUP BY skin_id, skin_name
ORDER BY total_compras DESC;
```

---

### **🌐 PASO 2: ABRIR SUPABASE**

1. Ve a: **https://supabase.com/dashboard**
2. Inicia sesión
3. Selecciona tu proyecto: **`ppjsfszaqtreundeonsx`**

---

### **📝 PASO 3: ABRIR SQL EDITOR**

1. En el menú lateral izquierdo, busca **"SQL Editor"**
2. Click en **"+ New query"** (botón verde)

---

### **📋 PASO 4: PEGAR EL SCRIPT**

1. **Borra** cualquier contenido que esté en el editor
2. **Pega** TODO el script que copiaste
3. Verifica que se vea completo (debe tener ~80 líneas)

---

### **▶️ PASO 5: EJECUTAR**

1. Click en el botón **"RUN"** (esquina inferior derecha)
2. Espera unos segundos
3. Deberías ver: ✅ **"Success. No rows returned"**

---

### **✅ PASO 6: VERIFICAR**

Verifica que la tabla se creó correctamente:

#### **Opción A: En Table Editor**
1. Ve a **"Table Editor"** en el menú lateral
2. Busca la tabla **`pagos_tienda`**
3. Deberías ver la tabla con estas columnas:
   - `id`
   - `user_id`
   - **`email`** ← Esta es la que falta
   - `skin_id`
   - `skin_name`
   - `precio`
   - `ultimos_4_digitos`
   - `tipo_tarjeta`
   - `nombre_titular`
   - `estado`
   - `numero_comprobante`
   - `created_at`
   - `updated_at`

#### **Opción B: Con SQL**
Ejecuta este query en SQL Editor:
```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'pagos_tienda' 
ORDER BY ordinal_position;
```

Deberías ver todas las columnas listadas.

---

### **🔒 PASO 7: VERIFICAR RLS (Row Level Security)**

1. Ve a **"Authentication" > "Policies"**
2. Busca la tabla **`pagos_tienda`**
3. Deberías ver 2 políticas:
   - ✅ "Los usuarios pueden ver sus propias compras"
   - ✅ "Los usuarios pueden crear sus propias compras"

---

## 🎮 **PASO 8: PROBAR EN LA APP**

Ahora que la tabla está creada:

1. **Reinicia la app** (Hot restart: `r` en terminal)
2. **Ve a 🎨 Skins**
3. **Selecciona una skin bloqueada**
4. **Ingresa los datos:**
   ```
   Número: 1111 1111 1111 1111
   Fecha: 12/25
   CVV: 111
   Nombre: JESUS TORRES
   ```
5. **Presiona "Pagar $9.99"**
6. **Debería funcionar!** ✅

---

## 🔍 **VERIFICAR LA COMPRA EN SUPABASE**

Después de comprar:

1. Ve a **"Table Editor" > pagos_tienda**
2. Deberías ver tu compra:

| id | user_id | email | skin_id | precio | estado |
|----|---------|-------|---------|--------|--------|
| ... | tu-id | tu@email | royal | 9.99 | completado |

---

## ⚠️ **ERRORES COMUNES:**

### **Error 1: "relation pagos_tienda already exists"**
✅ **Solución:** Esto es normal si ya existía. El script usa `CREATE TABLE IF NOT EXISTS`.

### **Error 2: "permission denied"**
❌ **Problema:** No tienes permisos de admin en Supabase
✅ **Solución:** Verifica que estás logueado como owner del proyecto

### **Error 3: "syntax error"**
❌ **Problema:** El script está incompleto o mal copiado
✅ **Solución:** Copia TODO el script desde el inicio (línea 1) hasta el final

### **Error 4: Sigue saliendo "Could not find email column"**
❌ **Problema:** La tabla no se creó o se creó sin la columna
✅ **Solución:** 
1. Elimina la tabla vieja:
   ```sql
   DROP TABLE IF EXISTS public.pagos_tienda CASCADE;
   ```
2. Vuelve a ejecutar el script completo

---

## 🆘 **SI SIGUE SIN FUNCIONAR:**

### **Opción 1: Eliminar y Recrear**

Ejecuta esto en SQL Editor:

```sql
-- 1. Eliminar tabla vieja (si existe)
DROP TABLE IF EXISTS public.pagos_tienda CASCADE;

-- 2. Eliminar función vieja (si existe)
DROP FUNCTION IF EXISTS public.handle_updated_at CASCADE;

-- 3. Eliminar vista vieja (si existe)
DROP VIEW IF EXISTS public.stats_compras CASCADE;

-- 4. Ahora pega TODO el script original de nuevo
```

### **Opción 2: Agregar solo la columna faltante**

Si la tabla existe pero le falta la columna `email`:

```sql
ALTER TABLE public.pagos_tienda 
ADD COLUMN IF NOT EXISTS email TEXT NOT NULL DEFAULT 'sin-email@test.com';
```

---

## 📊 **RESUMEN:**

**¿Qué hace el script?**
1. ✅ Crea la tabla `pagos_tienda` con 13 columnas
2. ✅ Crea índices para búsquedas rápidas
3. ✅ Activa seguridad (RLS)
4. ✅ Crea políticas para que cada usuario solo vea sus compras
5. ✅ Crea función para actualizar timestamps
6. ✅ Crea vista para estadísticas

**¿Por qué es necesario?**
- ❌ Sin este script, la tabla no existe
- ❌ Sin la columna `email`, el sistema no puede guardar compras
- ❌ Sin RLS, cualquiera podría ver las compras de otros

---

## ✅ **CHECKLIST:**

- [ ] Copié TODO el script (80+ líneas)
- [ ] Abrí Supabase Dashboard
- [ ] Fui a SQL Editor
- [ ] Pegué el script completo
- [ ] Presioné "RUN"
- [ ] Vi "Success. No rows returned"
- [ ] Verifiqué en Table Editor que `pagos_tienda` existe
- [ ] Verifiqué que tiene la columna `email`
- [ ] Reinicié la app
- [ ] Probé hacer una compra
- [ ] ✅ Funcionó!

---

## 🎯 **SIGUIENTE PASO:**

Una vez que ejecutes el script y veas ✅ **"Success"** en Supabase:

1. **Cierra la app** completamente
2. **Vuelve a abrirla**
3. **Ve a Skins**
4. **Intenta comprar de nuevo**
5. **Debería funcionar!**

---

## 📞 **¿NECESITAS AYUDA?**

Si después de ejecutar el script sigue sin funcionar:

1. **Toma screenshot** de:
   - El SQL Editor mostrando el resultado del script
   - La Table Editor mostrando la tabla `pagos_tienda`
   - El error en la app (si sigue apareciendo)

2. **Copia el error completo** que sale en la app

3. **Comparte** esos detalles para diagnosticar el problema

---

**¡EJECUTA EL SCRIPT AHORA!** 🚀

