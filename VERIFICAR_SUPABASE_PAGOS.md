# ✅ VERIFICAR CONFIGURACIÓN DE SUPABASE PARA PAGOS

## 🎯 PASO 1: VERIFICAR QUE LA TABLA EXISTA

1. Ve a tu proyecto en Supabase:
   - https://supabase.com/dashboard/project/ppjsfszaqtreundeonsx

2. Ve a: **SQL Editor** (menú izquierdo)

3. Ejecuta esta consulta para verificar la tabla:
```sql
SELECT * FROM pagos_tienda LIMIT 5;
```

**✅ SI FUNCIONA:** Verás una tabla vacía o con datos de prueba  
**❌ SI DA ERROR:** La tabla no existe, ve al Paso 2

---

## 🔧 PASO 2: CREAR LA TABLA (si no existe)

Si la tabla no existe, ejecuta TODO el contenido del archivo:
```
SUPABASE_PAGOS_TIENDA.sql
```

### Cómo hacerlo:

1. Abre el archivo `SUPABASE_PAGOS_TIENDA.sql`
2. Copia **TODO** el contenido (desde la línea 1 hasta el final)
3. Ve a: **SQL Editor** > **New Query**
4. Pega el código
5. Presiona **RUN** (botón verde abajo a la derecha)

**Deberías ver:**
```
Success. No rows returned
```

---

## 🔍 PASO 3: VERIFICAR POLÍTICAS RLS

1. Ve a: **Authentication** > **Policies**
2. Busca la tabla `pagos_tienda`
3. Deberías ver 2 políticas:
   - ✅ **"Los usuarios pueden ver sus propias compras"** (SELECT)
   - ✅ **"Los usuarios pueden crear sus propias compras"** (INSERT)

**Si no existen:** Vuelve a ejecutar el script SQL del Paso 2

---

## 🎮 PASO 4: PROBAR EL SISTEMA

### 1. **Abrir la tienda:**
   - Abre tu juego en el emulador/dispositivo
   - Ve al menú principal
   - Presiona el botón **"🎨 Skins"**

### 2. **Filtrar skins:**
   - En la parte superior verás tabs: **Todas**, **Legendarias**, **Épicas**, **Raras**, **Comunes**
   - Presiona cada tab para filtrar
   - Verás que los filtros funcionan correctamente

### 3. **Intentar comprar una skin:**
   - Selecciona una skin **bloqueada** (con candado 🔒)
   - Aparecerá un diálogo con:
     - Icono grande de la skin
     - Nombre y rareza
     - Precio
     - Botones: "Cancelar" y "Comprar"

### 4. **Llenar el formulario de pago:**
   - Usa estos datos de prueba (tarjetas válidas según Luhn):
     
     **Visa de prueba:**
     - Número: `4532 1488 0343 6467`
     - Vencimiento: `12/25`
     - CVV: `123`
     - Nombre: `TU NOMBRE`
     
     **Mastercard de prueba:**
     - Número: `5425 2334 3010 9903`
     - Vencimiento: `01/26`
     - CVV: `321`
     - Nombre: `TU NOMBRE`
     
     **American Express de prueba:**
     - Número: `3782 822463 10005`
     - Vencimiento: `06/27`
     - CVV: `1234` (4 dígitos)
     - Nombre: `TU NOMBRE`

### 5. **Procesar el pago:**
   - Presiona **"Pagar $X.XX"**
   - Verás un loading: **"Procesando..."**
   - Espera 1-2 segundos (simulación de procesamiento)

### 6. **Ver el comprobante:**
   - Deberías ver una pantalla con:
     - ✅ **Checkmark verde gigante**
     - **"¡Pago Exitoso!"**
     - Un **ticket blanco** con todos los detalles:
       - Número de comprobante (ej: `COMP-20250125-12345678`)
       - Fecha y hora
       - Nombre de la skin
       - Método de pago (tipo de tarjeta + últimos 4 dígitos)
       - Estado: ✅ Completado
       - Total pagado
     - Preview de la skin en el footer
     - Botones: "Usar Skin Ahora" y "Volver a la Tienda"

### 7. **Verificar la compra:**
   - Presiona **"Usar Skin Ahora"**
   - Deberías volver a la tienda
   - La skin comprada ahora debería tener un ✅ **check verde**
   - Ya no aparecerá el candado
   - Puedes seleccionarla y usarla en el juego

---

## 📊 PASO 5: VERIFICAR EN SUPABASE

1. Ve a: **Table Editor** > **pagos_tienda**
2. Deberías ver tu compra registrada con:
   - `user_id`: Tu ID de usuario
   - `email`: Tu email
   - `skin_id`: ID de la skin (ej: "fire", "golden")
   - `skin_name`: Nombre de la skin
   - `precio`: Precio pagado
   - `ultimos_4_digitos`: Últimos 4 dígitos de la tarjeta
   - `tipo_tarjeta`: Tipo detectado (Visa, Mastercard, etc.)
   - `nombre_titular`: Nombre que ingresaste
   - `estado`: `completado`
   - `numero_comprobante`: Número único (ej: `COMP-20250125-abc12345`)
   - `created_at`: Fecha y hora

---

## 🐛 PROBLEMAS COMUNES

### ❌ Error: "Usuario no autenticado"
**Solución:** Asegúrate de estar logueado en el juego antes de intentar comprar.

### ❌ Error: "Número de tarjeta inválido"
**Causa:** El número no pasa el algoritmo de Luhn.  
**Solución:** Usa uno de los números de prueba que te proporcioné arriba.

### ❌ Error: "Error al procesar el pago"
**Posibles causas:**
1. La tabla no existe → Ve al Paso 2
2. Las políticas RLS están mal → Ve al Paso 3
3. No tienes conexión a internet

### ❌ La skin no aparece como comprada después del pago
**Solución:**
1. Cierra la tienda completamente
2. Vuelve a abrirla
3. Si persiste, reinicia la app

### ❌ No puedo ver mis compras anteriores
**Verificar:**
1. Estás logueado con el mismo usuario
2. Las políticas RLS están activas (Paso 3)
3. Ejecuta en SQL Editor:
```sql
SELECT * FROM pagos_tienda WHERE user_id = auth.uid();
```

---

## 📈 CONSULTAS ÚTILES DE SUPABASE

### Ver todas tus compras:
```sql
SELECT 
    skin_name,
    precio,
    tipo_tarjeta,
    ultimos_4_digitos,
    created_at
FROM pagos_tienda 
WHERE user_id = auth.uid()
ORDER BY created_at DESC;
```

### Ver estadísticas de ventas (todas las skins):
```sql
SELECT * FROM stats_compras;
```

### Ver cuántas veces se ha comprado cada skin:
```sql
SELECT 
    skin_id,
    skin_name,
    COUNT(*) as total_ventas,
    SUM(precio) as ingresos
FROM pagos_tienda
WHERE estado = 'completado'
GROUP BY skin_id, skin_name
ORDER BY total_ventas DESC;
```

### Buscar comprobante específico:
```sql
SELECT * FROM pagos_tienda 
WHERE numero_comprobante = 'COMP-20250125-12345678';
```

---

## ✨ MEJORAS IMPLEMENTADAS

### 🎨 **Tienda de Skins:**
- ✅ Grid de **3 columnas** (más compacto)
- ✅ **Filtros por rareza**: Todas, Legendarias, Épicas, Raras, Comunes
- ✅ **Badges de rareza** con iconos
- ✅ **Indicadores visuales**: 
  - 🔓 Gratis
  - ✅ Comprada
  - 🔒 Bloqueada con precio
  - ⚡ En uso
- ✅ **Header mejorado** con estadísticas:
  - Número de skins poseídas
  - % de completado
- ✅ **Diálogo de compra mejorado**:
  - Icono grande animado
  - Badge de rareza
  - Precio destacado
  - Botones mejorados

### 💳 **Sistema de Pagos:**
- ✅ **Validación de tarjeta** (Algoritmo de Luhn)
- ✅ **Detección automática** del tipo de tarjeta
- ✅ **Formateo automático**: `XXXX XXXX XXXX XXXX`
- ✅ **Validación de fecha** de expiración
- ✅ **Validación de CVV** (3 o 4 dígitos)
- ✅ **Simulación de procesamiento** (1.5 segundos)
- ✅ **Registro en Supabase**

### 📄 **Comprobante:**
- ✅ **Diseño profesional** tipo ticket
- ✅ **Número único** de comprobante
- ✅ **Todos los detalles** de la transacción
- ✅ **Preview de la skin** comprada
- ✅ **Botones de acción**

---

## 🎯 RESUMEN DE VERIFICACIÓN

| Paso | Qué verificar | ✅ OK | ❌ Error |
|------|--------------|------|----------|
| 1 | Tabla existe en Supabase | | |
| 2 | Políticas RLS activas | | |
| 3 | Tienda se abre correctamente | | |
| 4 | Filtros de rareza funcionan | | |
| 5 | Diálogo de compra aparece | | |
| 6 | Formulario de pago valida correctamente | | |
| 7 | Tarjetas de prueba son aceptadas | | |
| 8 | Procesamiento tarda 1-2 segundos | | |
| 9 | Comprobante se muestra correctamente | | |
| 10 | Skin aparece como comprada | | |
| 11 | Puedo usar la skin comprada | | |
| 12 | Registro aparece en Supabase | | |

---

## 🚀 TODO LISTO

Si todos los pasos funcionan correctamente, **¡tu sistema de pagos está 100% operativo!** 🎉

**Próximos pasos opcionales:**
1. Agregar más skins al catálogo
2. Implementar descuentos o promociones
3. Agregar un historial de compras en la app
4. Implementar devoluciones (si es necesario)

---

**¿Necesitas ayuda?** 
- Revisa los logs de la consola de Flutter
- Verifica los logs de Supabase en: **Logs** > **API**

